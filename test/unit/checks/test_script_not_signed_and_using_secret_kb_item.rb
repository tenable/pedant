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

class TestScriptNotSignedAndUsingSecretKBItem < Test::Unit::TestCase
  include Pedant::Test

  def test_get_kb_item_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|get_kb_item("Secret/SSH/Username");|
    )
  end

  def test_get_kb_item_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|get_kb_item("Secret/SSH/Username");|
    )
  end

  def test_rm_kb_item_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|rm_kb_item("Secret/SSH/Username");|
    )
  end

  def test_rm_kb_item_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|rm_kb_item("Secret/SSH/Username");|
    )
  end

  def test_get_kb_list_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|get_kb_list("Secret/SSH/Username");|
    )
  end

  def test_get_kb_list_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|get_kb_list("Secret/SSH/Username");|
    )
  end

  def test_replace_kb_item_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|replace_kb_item(name:"Secret/SSH/Username", value:"yoda");|
    )
  end

  def test_replace_kb_item_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|replace_kb_item(name:"Secret/SSH/Username", value:"yoda");|
    )
  end

  def test_set_kb_item_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|set_kb_item(name:"Secret/SSH/Username", value:"yoda");|
    )
  end

  def test_set_kb_item_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|set_kb_item(name:"Secret/SSH/Username", value:"yoda");|
    )
  end

  def test_script_require_keys_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|script_require_keys("Secret/SSH/Username");|
    )
  end

  def test_script_require_keys_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|script_require_keys("Secret/SSH/Username");|
    )
  end

  def test_set_global_kb_item_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|set_global_kb_item(name:"Secret/SSH/Username", value:"yoda");|
    )
  end

  def test_set_global_kb_item_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|set_global_kb_item(name:"Secret/SSH/Username", value:"yoda");|
    )
  end

  def test_get_global_kb_item_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|get_global_kb_item("Secret/SSH/Username");|
    )
  end

  def test_get_global_kb_item_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|get_global_kb_item("Secret/SSH/Username");|
    )
  end

  def test_get_global_kb_list_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|get_global_kb_list("Secret/SSH/Username");|
    )
  end

  def test_get_global_kb_list_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|get_global_kb_list("Secret/SSH/Username");|
    )
  end

  def test_get_kb_item_or_exit_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|get_kb_item_or_exit("Secret/SSH/Username");|
    )
  end

  def test_get_kb_item_or_exit_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|get_kb_item_or_exit("Secret/SSH/Username");|
    )
  end

  def test_get_fresh_kb_item_and_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|get_fresh_kb_item("Secret/SSH/Username");|
    )
  end

  def test_get_fresh_kb_item_and_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|get_fresh_kb_item("Secret/SSH/Username");|
    )
  end

  def test_set_kb_item_value_first_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|set_kb_item(value:20, name:"Secret/SSH/Username");|
    )
  end

  def test_set_kb_item_value_first_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|set_kb_item(value:20, name:"Secret/SSH/Username");|
    )
  end

  def test_get_kb_item_name_expr_signed
    check(
      :pass,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|#TRUSTED blah| +
      %q|get_kb_item(name:"Secret/"+var+"lol");|
    )
  end

  def test_get_kb_item_name_expr_not_signed
    check(
      :fail,
      :CheckScriptNotSignedAndUsingSecretKBItem,
      %q|get_kb_item(name:"Secret/"+var+"lol");|
    )
  end

end
