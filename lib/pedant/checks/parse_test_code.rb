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
  class CheckParseTestCode < Check
    def self.requires
      super + [:codes, :main, :test_mode]
    end

    def self.provides
      super + [:trees]
    end

    def run
      def import(path)
        # Since there are potentially several ways to write the path leading to
        # a file, we'll use the basename as the key for hashes. This will
        # prevent parsing the same file multiple times.
        file = path.basename

        # Mark a placeholder key in the KB for this file. This will prevent us
        # from trying to parse a library more than once if there is a failure.
        @kb[:trees][file] = :pending

        tree = Nasl::Parser.new.parse(@kb[:codes][file], path)
        @kb[:trees][file] = tree
        report(:info, "Parsed contents of #{path}.")
      end

      # This check will pass by default.
      pass

      # Initialize the keys written by this check.
      @kb[:trees] = {}

      # Load up the main file.
      import(@kb[:main])
    end
  end
end
