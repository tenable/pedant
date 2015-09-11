################################################################################
# Copyright (c) 2015, Tenable Network Security
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
  class CheckUsesOctalIntegers < Check
    def self.requires
      super + [:trees]
    end

    def check(file, tree)
      tree.all(:Integer).select { |i| i.tokens.first.type == :INT_OCT }.each do |i|
        next if i.value == 0 # Lots of plugins use '00' or '0000', which is ok.
        warn
        report(:warn, "NASL integers beginning with '0' with all digits between 0-7 are octal.")
        report(:warn, "This integer will have decimal value '#{i.value}'.")
        report(:warn, i.context(i))
      end

      tree.all(:Integer).select { |i| i.tokens.first.type == :INT_DEC }.each do |i|
        next if i.value == 0 # Lots of plugins use '00' or '0000', which is ok.
        next if not i.tokens.first.body =~ /^0[0-9]/
        warn
        report(:warn, "This integer appears to be octal, but will be interpreted as decimal.")
        report(:warn, "NASL integers beginning with '0' with all digits between 0-7 are octal.")
        report(:warn, "Remove the leading '0' to make it clear this integer should be decimal.")
        report(:warn, i.context(i))
      end
    end

    def run
      # This check will pass by default.
      pass

      # Run this check on the tree from every file.
      @kb[:trees].each { |file, tree| check(file, tree) }
    end
  end
end
