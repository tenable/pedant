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

module Pedant
  class CheckFilesParseWithoutErrors < Check
    def self.requires
      super + [:file_mode, :base, :main]
    end

    def self.provides
      super + [:codes, :trees]
    end

    def run
      def import(path)
        # All files should be relative to the main file's base in practice.
        path = @kb[:base] + path

        # Since there are potentially several ways to write the path leading to
        # a file, we'll use the basename as the key for hashes. This will
        # prevent parsing the same file multiple times.
        file = path.basename

        # Mark a placeholder key in the KB for this file. This will prevent us
        # from trying to parse a library more than once if there is a failure.
        @kb[:codes][file] = :pending
        @kb[:trees][file] = :pending

        begin
          contents = File.open(path, "rb").read
          @kb[:codes][file] = contents
          report(:info, "Read contents of #{path}.")
        rescue
          report(:error, "Failed to read contents of #{path}.")
          return fatal
        end

        begin
          tree = Nasl::Parser.new.parse(contents, path)
          @kb[:trees][file] = tree
          report(:info, "Parsed contents of #{path}.")
        rescue
          # XXX-MAK: Incorporate the error from the parser, as it gives full,
          # coloured context.
          report(:error, "Failed to parse #{path}.")
          return fatal
        end
      end

      # This check will pass by default.
      pass

      # Initialize the keys written by this check.
      @kb[:codes] = {}
      @kb[:trees] = {}

      # Load up the main file.
      import(@kb[:main])

      return

      while true
        # Get the list of all Includes, and prune any that have already had the
        # files they reference parsed.
        libs = Nasl::Include.all.map do |inc|
          (@kb[:base] + inc.filename.text).basename
        end

        libs.delete_if { |lib| lib == @kb[:main] || @kb[:trees].has_key?(lib) }

        break if libs.empty?

        # Try and parse each library, continuing on failures.
        libs.each { |lib| import(lib) }
      end
    end
  end
end
