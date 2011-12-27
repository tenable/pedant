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

class TestConditionalOrLoopIsEmpty < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :pass,
      :CheckConditionalOrLoopIsEmpty,
      %q||
    )
  end

  def test_for
    check(
      :fail,
      :CheckConditionalOrLoopIsEmpty,
      %q|for (;1;) ;|
    )

    check(
      :pass,
      :CheckConditionalOrLoopIsEmpty,
      %q|for (;1;) {}|
    )
  end

  def test_foreach
    check(
      :fail,
      :CheckConditionalOrLoopIsEmpty,
      %q|foreach foo (bar) ;|
    )

    check(
      :pass,
      :CheckConditionalOrLoopIsEmpty,
      %q|foreach foo (bar) {}|
    )
  end

  def test_if
    check(
      :fail,
      :CheckConditionalOrLoopIsEmpty,
      %q|if (1) ;|
    )

    check(
      :fail,
      :CheckConditionalOrLoopIsEmpty,
      %q|if (1) ; else {}|
    )

    check(
      :fail,
      :CheckConditionalOrLoopIsEmpty,
      %q|if (1) {} else ;|
    )

    check(
      :pass,
      :CheckConditionalOrLoopIsEmpty,
      %q|if (1) {}|
    )

    check(
      :pass,
      :CheckConditionalOrLoopIsEmpty,
      %q|if (1) {} else {}|
    )
  end

  def test_repeat
    check(
      :fail,
      :CheckConditionalOrLoopIsEmpty,
      %q|repeat ; until 1;|
    )

    check(
      :pass,
      :CheckConditionalOrLoopIsEmpty,
      %q|repeat {} until 1;|
    )
  end

  def test_while
    check(
      :fail,
      :CheckConditionalOrLoopIsEmpty,
      %q|while (1) ;|
    )

    check(
      :pass,
      :CheckConditionalOrLoopIsEmpty,
      %q|while (1) {}|
    )
  end
end
