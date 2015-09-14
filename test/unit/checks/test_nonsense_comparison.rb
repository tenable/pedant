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

class TestNonsenseComparison < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :pass,
      :CheckNonsenseComparison,
      %q||
    )
  end

  def test_isnull_call
    check(
      :pass,
      :CheckNonsenseComparison,
      %q|isnull(recv());|
    )
  end

  def test_isnull_identifier
    check(
      :pass,
      :CheckNonsenseComparison,
      %q|isnull(some_variable);|
    )
  end

  def test_isnull_literal_string
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|isnull("hello");|
    )
  end

  def test_isnull_literal_integer
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|isnull(6);|
    )
  end

  def test_literal_comparison_eq
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if ("hello" == 5) {};|
    )
  end

  def test_literal_comparison_substr
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if ("he" >< "hello") {};|
    )
  end

  def test_literal_comparison_regex
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if ("name" =~ "pedant") {};|
    )
  end

  def test_different_simple
    check(
      :pass,
      :CheckNonsenseComparison,
      %q|if (a == b) {};|
    )
  end

  def test_same_simple
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if (a == a) {};|
    )
  end

  def test_different_indexes
    check(
      :pass,
      :CheckNonsenseComparison,
      %q|if (a[1] == a[2]) {};|
    )
  end

  def test_same_indexes
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if (a[1] == a[1]) {};|
    )
  end

  def test_same_indexes_with_different_base
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if (a[1] == a[0x01]) {};|
    )
  end

  def test_multiple_index_types
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if (a[1]["hello"][b] == a[1]["hello"][b]) {};|
    )
  end

  def test_indexes_with_other_lvalues
    check(
      :fail,
      :CheckNonsenseComparison,
      %q|if (a[1]["hello"][b.hello["woo"].yay] == a[1]["hello"][b.hello["woo"].yay]) {};|
    )
  end

  def test_calls
    check(
      :pass,
      :CheckNonsenseComparison,
      %q|if (a[1] == a[0x01]()) {};|
    )
  end
end
