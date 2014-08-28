################################################################################
# Copyright (c) 2014, Tenable Network Security
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

class TestConditionalContainsAssignment < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :pass,
      :CheckConditionalContainsAssignment,
      %q||
    )
  end

  def test_literal_integer
    check(
      :fail,
      :CheckConditionalContainsAssignment,
      %q|if (a = 5) { exit(); }|
    )
  end

  def test_literal_integer_while
    check(
      :fail,
      :CheckConditionalContainsAssignment,
      %q|while (a = 5) { exit(); }|
    )
  end

  def test_literal_string
    check(
      :fail,
      :CheckConditionalContainsAssignment,
      %q|if (a = "foo") { exit(); }|
    )
  end

  def test_complex_literal_rhs
    check(
      :fail,
      :CheckConditionalContainsAssignment,
      %q|if (((foobar > 2 && (a = 1 && b < 2)) && foo.bar == bar.foo) && baz == 2) { exit(); }|
    )
  end

  def test_complex_literal_lhs
    check(
      :fail,
      :CheckConditionalContainsAssignment,
      %q|if (((foobar > 2 && (c == 2 && a = 1 && b < 2)) && foo.bar == bar.foo) && baz == 2) { exit(); }|
    )
  end

  def test_complex_non_literal
    check(
      :pass,
      :CheckConditionalContainsAssignment,
      %q|if (((foobar > 2 && (a = one && b < 2)) && foo.bar == bar.foo) && baz == 2) { exit(); }|
    )
  end

  def test_non_literal
    check(
      :pass,
      :CheckConditionalContainsAssignment,
      %q|if ((a = get_oracle_homes()) == "somestring") { exit(); }|
    )
  end
end
