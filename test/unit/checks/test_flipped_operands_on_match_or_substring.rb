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

class TestFlippedOperandsOnMatchOrSubstring < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :pass,
      :CheckFlippedOperandsOnMatchOrSubstring,
      %q||
    )
  end

  def test_no_op
    check(
      :pass,
      :CheckFlippedOperandsOnMatchOrSubstring,
      %q|if (a == b) exit(0);|
    )
  end

  def test_simple_substring
    check(
      :warn,
      :CheckFlippedOperandsOnMatchOrSubstring,
      %q|if (a >< 'woo') exit(0);|
    )
  end

  def test_simple_substring_indexed
    check(
      :pass,
      :CheckFlippedOperandsOnMatchOrSubstring,
      %q|if (a[i] >< 'woo') exit(0);|
    )
  end

  def test_simple_match
    check(
      :warn,
      :CheckFlippedOperandsOnMatchOrSubstring,
      %q|if ('woo' =~ a) exit(0);|
    )
  end

  def test_complex_match
    check(
      :warn,
      :CheckFlippedOperandsOnMatchOrSubstring,
      %q|if ('woo' >< a && 'woo' =~ a) exit(0);|
    )
  end
end
