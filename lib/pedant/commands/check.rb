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
  class CommandCheck < Command
    def self.binding
      'check'
    end

    def self.analyze(cfg, path, args)
      Check.initialize!

      # Create an instance of every registered check.
      pending = Check.all.map &:new

      # Initialize the knowledge base where checks can store information for
      # other checks.
      kb = {
        :base => path.dirname,
        :main => path.basename
      }

      # Try to run each pending check, until we've run all our checks or
      # deadlocked.
      fatal = false
      until pending.empty? || fatal
        # Find all of the checks that can run right now.
        ready = pending.select { |chk| chk.ready?(kb) }
        break if ready.empty?

        # Run all of the checks that are ready.
        ready.each do |chk|
          pending.delete(chk)
          chk.run(kb)

          # Fatal errors mean that no further checks should be processed.
          if chk.result == :fatal
            fatal = true
            break
          end

          # Display the results of the check.
          puts chk.result
          report = chk.report(cfg[:verbose])
          puts report if !report.empty?
        end
      end

      # Notify the user if any checks did not run due to unsatisfied
      # dependencies or a fatal error occurring before they had the chance to
      # run.
      pending.each { |chk| puts chk.result }
    end
  end
end
