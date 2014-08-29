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

class TestScratchpadQueriesUseConcatenation < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :pass,
      :CheckScratchpadQueriesUseConcatenation,
      %q||
    )
  end

  # We only flag queries that explicitly have the '+' sign in them, because
  # those generally have no good excuse for being that way.
  # Anything that uses a variable/call is probably by design.
  def test_var
    check(
      :pass,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad(foo);|
    )
  end

  def test_concatenation
    check(
      :fail,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad("foo" + bar);|
    )

    check(
      :fail,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad(foo + "bar");|
    )

    check(
      :fail,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad(foo + "bar" + baz);|
    )

    check(
      :fail,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad(foo + bar + "baz");|
    )

    check(
      :fail,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad('SELECT * FROM whatever WHERE id = ' + get_id());|
    )
  end

  def test_literal
    check(
      :pass,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad("");|
    )

    check(
      :pass,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad("SELECT * FROM whatever;");|
    )
  end

  def test_call
    check(
      :pass,
      :CheckScratchpadQueriesUseConcatenation,
      %q|query_scratchpad(foo(""));|
    )
  end
end
