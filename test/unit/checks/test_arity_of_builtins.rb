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

class TestArityOfBuiltins < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :pass,
      :CheckConditionalContainsAssignment,
      %q||
    )
  end

  def test_correct
    check(
      :pass,
      :CheckArityOfBuiltins,
      %q|get_kb_item("hello");|
    )
  end

  def test_no_args
    check(
      :fail,
      :CheckArityOfBuiltins,
      %q|get_kb_item();|
    )
  end

  def test_named
    check(
      :fail,
      :CheckArityOfBuiltins,
      %q|get_kb_item(key:"hello");|
    )
  end

  def test_two_anon
    check(
      :fail,
      :CheckArityOfBuiltins,
      %q|get_kb_item("service/", port);|
    )
  end

  def test_three_anon
    check(
      :fail,
      :CheckArityOfBuiltins,
      %q|get_kb_item("hello/", port, "/property");|
    )
  end

  def test_one_anon_one_named
    check(
      :fail,
      :CheckArityOfBuiltins,
      %q|get_kb_item("hello/", index:index);|
    )
  end

  def test_make_array_odd
    check(
      :fail,
      :CheckArityOfBuiltins,
      %q|make_array(1, 2, 3);|
    )
  end

  def test_make_array_even
    check(
      :pass,
      :CheckArityOfBuiltins,
      %q|make_array(1, 2, 3, 4);|
    )
  end
end
