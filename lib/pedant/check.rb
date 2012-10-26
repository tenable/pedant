################################################################################
# Copyright (c) 2011, Mak Kolybabi
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################

module Pedant
  class Check
    attr_reader :result

    @@statuses = {
      :died => 'DIED'.color(:red),
      :fail => 'FAIL'.color(:red),
      :pass => 'PASS'.color(:green),
      :skip => 'SKIP'.color(:green),
      :warn => 'WARN'.color(:yellow),
      :void => 'VOID'.color(:magenta)
    }

    @@levels = [:error, :warn, :info]

    def self.initialize!
      Dir.glob(Pedant.lib + 'pedant/checks/*.rb').each { |f| load(f) }
    end

    def initialize(kb)
      @report = []
      @result = :void

      @kb = kb

      # Run all the dependencies for this check if we're in test mode.
      return unless @kb[:test_mode]
      self.class.depends.each do |cls|
        chk = cls.new(@kb)
        chk.run
      end
    end

    def self.list
      all.map{ |cls| cls.friendly_name }
    end

    def self.all
      (@_all ||= [])
    end

    def self.inherited(cls)
      all << cls
    end

    def self.provides
      return []
    end

    def self.requires
      return []
    end

    def self.ready?(kb)
      self.requires.reduce(true) do |stat, req|
        stat && kb.has_key?(req)
      end
    end

    def self.depends
      keys = self.requires

      Check.all.reject do |cls|
        (cls.provides & keys).empty?
      end
    end

    def report(level, text=nil)
      if !text.nil?
        @report << [level, text]
        return
      end

      # Convert level from symbol to an array index.
      level = @@levels.index(level) if level.is_a?(Symbol)

      # Format all components of a report at or below the specified level.
      msg = @report.select { |l, t| @@levels.index(l) <= level }.map { |l, t| t }.join("\n")
      msg << "\n" unless msg.empty?

      # Format the check's result.
      msg = "[#{@@statuses[@result]}] #{self.class.friendly_name}\n#{msg}"

      return msg
    end

    def self.friendly_name
      # Mangle the class name to be more user-friendly.
      self.name.gsub(/.*::/, '').gsub(/^Check/, '').gsub(/([A-Z][^A-Z]*)/, ' \1').strip
    end

    def fail
      @result = :fail
    end

    def fatal
      report(:error, "This is a fatal error.")
      @result = :died
    end

    def pass
      @result = :pass
    end

    def skip
      @result = :skip
    end

    def warn
      @result = :warn
    end
  end
end
