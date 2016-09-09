################################################################################
# Copyright (c) 2016, Tenable Network Security
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
  class CheckContainsNoDuplicateWords < Check
    def self.requires
      # Don't run on local checks, since those are auto-generated and their text
      # is beyond our direct control.
      super + [:trees, :plugin_type_remote]
    end

    def check(file, tree)
      def check_string(s)
        # Clone the string so we don't alter the original.
        text = String.new(s.text)

        # Remove extra whitespace, including newlines.
        text.gsub!(/\s+/, " ")

        # Other removals may be good here, but they'll need large scale testing
        # to avoid false alarms.

        # Check for any words that are duplicated.
        text.match(/\b(\w+)\b \b\1\b/) do |phrase|
          word = phrase[1]

          # Numbers are tricky to reason about, ignore them.
          next if word =~ /^\d+$/

          # Next we need to find the original phrase in the original text.
          # This needs to be able to jump across whitespace and newlines.
          real_phrase = s.text.match(/#{word}\s+#{word}/m)
          next if not real_phrase

          # Access the context object for this code.
          ctx = s.ctx

          # Calculate the region the phrase spans, for the message.
          loc = s.region.begin + real_phrase.begin(0) .. s.region.begin + real_phrase.end(0) + 1
          bol = ctx.bol(s.region.begin + real_phrase.begin(0))
          eol = ctx.eol(s.region.begin + real_phrase.end(0))
          report(:error, "Phrase with repeated word found: #{ctx.context(loc, bol..eol)}")
          fail
        end
      end

      tree.all(:String).each { |s| check_string(s) }
    end

    def run
      # This check will pass by default.
      pass

      # Run this check on the tree of every file.
      @kb[:trees].each { |file, tree| check(file, tree) }
    end
  end
end
