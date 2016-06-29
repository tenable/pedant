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

class TestGetByteUsed< Test::Unit::TestCase
  include Pedant::Test

  def test_get_byte_used
    check(
      :fail,
      :CheckGetByteUsed,
      %q|get_byte(blob:blah, pos:10);|
    )
  end

  def test_get_word_used
    check(
      :fail,
      :CheckGetByteUsed,
      %q|get_word(blob:blah, pos:10);|
    )
  end

  def test_get_dword_used
    check(
      :fail,
      :CheckGetByteUsed,
      %q|get_dword(blob:blah, pos:10);|
    )
  end

  def test_getbyte_used
    check(
      :pass,
      :CheckGetByteUsed,
      %q|getbyte(blob:blah, pos:10);|
    )
  end

  def test_getword_used
    check(
      :pass,
      :CheckGetByteUsed,
      %q|getword(blob:blah, pos:10);|
    )
  end

  def test_getdword_used
    check(
      :pass,
      :CheckGetByteUsed,
      %q|getdword(blob:blah, pos:10);|
    )
  end

  def test_get_byte_used_with_set_byte_order
    check(
      :fail,
      :CheckGetByteUsed,
      %q|set_byte_order(BYTE_ORDER_LITTLE_ENDIAN);| +
      %q|get_byte(blob:blah, pos:10);|
    )
  end

  def test_get_word_used_with_set_byte_order
    check(
      :fail,
      :CheckGetByteUsed,
      %q|set_byte_order(BYTE_ORDER_LITTLE_ENDIAN);| +
      %q|get_word(blob:blah, pos:10);|
    )
  end

  def test_get_dword_used_with_set_byte_order
    check(
      :fail,
      :CheckGetByteUsed,
      %q|set_byte_order(BYTE_ORDER_LITTLE_ENDIAN);| +
      %q|get_dword(blob:blah, pos:10);|
    )
  end

end
