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

require 'optparse'

module Pedant
  class Cli
    @@optparse = nil

    def self.run
      options = {
        input_mode: :filesystem,
        output_mode: :terminal,
        verbosity: 0
      }

      Command.initialize!

      @@optparse = OptionParser.new do |opts|
        opts.banner = "Usage: pedant [global-options] [command [command-options] [args]]"

        opts.separator ""
        opts.separator "Global settings:"

        opts.separator ""
        opts.separator "Common operations:"

        opts.on('-h', '--help', 'Display this help screen.') do
          puts opts
          exit 1
        end

        opts.on('-l', '--list', 'Display the list of available commands.') do
          puts Command.list
          exit 1
        end

        opts.on('-v') do
          puts "The -v argument now comes after the `check` subcommand. Like so:"
          puts "  pedant check -v file.nasl"
          puts "For the version, do -V or --version."
          exit 1
        end

        opts.on('-V', '--version', 'Display the version of Pedant.') do
          puts "#{Pedant::VERSION}"
          exit
        end
      end

      @@optparse.order!

      # Sanity check the command.
      usage("No command was specified.") if ARGV.empty?
      cmd = ARGV.shift
      cls = Command.find(cmd)
      usage("Command '#{cmd}' not supported.") if cls.nil?

      # Run the command.
      cls.run(options, ARGV)
    end

    def self.usage(msg)
      puts Rainbow(msg).color(:red)
      puts
      puts @@optparse
      exit 1
    end
  end
end
