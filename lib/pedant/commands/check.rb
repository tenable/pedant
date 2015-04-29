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

require 'set'

module Pedant
  class CommandCheck < Command
    def self.binding
      'check'
    end

    def self.help
      @@optparse.to_s
    end

    def self.optparse(options, args)
      options[:checks] = Set.new

      @@optparse = OptionParser.new do |opts|
        opts.banner = "Usage: pedant [global-options] #{binding} [command-options] [args]"

        opts.separator ""
        opts.separator "Input formats:"

        opts.on('-f', '--filesystem', 'Read input from the filesystem.') do
          options[:input_mode] = :filesystem
        end

        opts.on('-g', '--git', 'Read input from a Git repository.') do
          options[:input_mode] = :git
        end

        opts.separator ""
        opts.separator "Output formats:"

        opts.on('-e', '--email', 'Output in a form suitable for an email.') do
          options[:output_mode] = :email
        end

        opts.on('-t', '--terminal', 'Output in a form suitable for a terminal.') do
          options[:output_mode] = :terminal
        end

        opts.separator ""
        opts.separator "Common operations:"

        opts.on('-c=NAME', '--check=NAME', 'Run only the check named, and its dependencies.') do |name|
          # Unmangle class name and be very forgiving.
          name = "Check" + name.gsub(/[-._ ]/, '')

          begin
            cls = Pedant.const_get(name)
          rescue NameError => e
            usage(e.message)
          end

          ([cls] + cls.depends).each { |cls| options[:checks] << cls }
        end

        opts.on('-h', '--help', 'Display this help screen.') do
          puts opts
          exit 1
        end

        opts.on('-l', '--list', 'List the available checks.') do
          puts Check.list
          exit 0
        end
      end

      # Load all of the checks.
      Check.initialize!

      @@optparse.order!(args)

      return options, args
    end

    def self.run_all(opts, args)
      # Separate plugins and libraries from the rest of the arguments.
      paths = args.select { |a| a =~ /(\/|\.(inc|nasl))$/ }
      args -= paths

      # If we have paths that aren't acceptable, there's a problem.
      usage("One or more unacceptable files were specified.") unless args.empty?

      # If we have no paths to process, there's a problem.
      usage("No directories (/), libraries (.inc), or plugins (.nasl) were specified.") if paths.empty?

      # Collect all the paths together, recursively.
      dirents = []
      paths.each do |path|
        begin
          Pathname.new(path).find do |dirent|
            if dirent.file? && dirent.extname =~ /inc|nasl/
              dirents << dirent
            end
          end
        rescue SystemCallError => e
          usage(e.message)
        end
      end

      dirents.each { |d| run_one(opts, d) }
    end

    def self.run_one(opts, path)
      puts Rainbow("CHECKING: #{path}").cyan
      # Get a list of the checks we're going to be running.
      if not opts[:checks].empty?
        pending = opts[:checks].to_a
      else
        pending = Array.new(Check.all)
      end

      # Initialize the knowledge base where checks can store information for
      # other checks.
      kb = KnowledgeBase.new(:file_mode, path)

      Check.run_checks_in_dependency_order(kb, pending) do |chk|
        puts chk.report(opts[:verbosity])
      end

      # Notify the user if any checks did not run due to unsatisfied
      # dependencies or a fatal error occurring before they had the chance to
      # run.
      pending.each do |cls|
        # Special case. This check is a shim to set things up for unit tests.
        next if cls == CheckParseTestCode
        puts cls.new(kb).report(opts[:verbosity])
      end
      puts
    end
  end
end
