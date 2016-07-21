################################################################################
# Copyright (c) 2011-2014, Tenable Network Security
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

require 'rainbow'

module Pedant
  class CheckContainsNoTabs < Check
    def self.requires
      super + [:codes]
    end

    def check(file, code)
      tab_lines = Hash.new
      code.split("\n").each_with_index do |line, linenum|
        tab_lines[linenum + 1] = line if line =~ /\t/
      end

      return if tab_lines.length == 0

      # Make the consecutive sequences friendlier to read
      ranges = self.class.chunk_while(tab_lines.keys.sort) { |i, j| i + 1 == j }.map do |group|
        if group.length == 1
          group.first.to_s
        else
          "#{group.first.to_s}-#{group.last.to_s}"
        end
      end

      report(:warn, "Tabs were found in #{file}, on these lines: #{ranges.join(', ')}")
      report(:warn, "Showing up to five lines:")
      tab_lines.keys.sort.first(5).each do |linenum|
        report(:warn, "#{linenum}: #{tab_lines[linenum].gsub(/\t/, Rainbow("    ").background(:red))}")
      end

      warn
    end

    def run
      # This check will pass by default.
      pass

      # Run this check on the code in every file.
      @kb[:codes].each { |file, code| check(file, code) }
    end

    # Enumerable#chunk_while in Ruby 2.3 would remove the need for this
    def self.chunk_while enumerable
      # If we're passed an array or something...
      enumerable = enumerable.to_enum unless enumerable.respond_to? :next

      chunks = [[enumerable.next]] rescue [[]]
      loop do
        elem = enumerable.next
        if yield chunks.last.last, elem
          chunks[-1] << elem
        else
          chunks << [elem]
        end
      end
      return chunks
    end
  end
end
