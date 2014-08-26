################################################################################
# Copyright (c) 2011, Mak Kolybabi
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

class TestContainsRegistrationSection < Test::Unit::TestCase
  include Pedant::Test

  def test_does
    check(
      :pass,
      :CheckContainsRegistrationSection,
      %q|if (description) { exit(0); }|
    )
  end

  def test_does_not
    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q||
    )
  end

  def test_unexpected
    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) ;|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) {}|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { ; }|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { foo(); }|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { exit(); }|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { exit(foo:1); }|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { exit(foo, bar); }|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { exit(1); }|
    )

    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { exit(0, foo); }|
    )
  end

  def test_indexed_description
    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description["foo"]) { exit(0); }|
    )
  end

  def test_indexed_exit
    check(
      :fail,
      :CheckContainsRegistrationSection,
      %q|if (description) { exit[foo](0); }|
    )
  end
end
