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

class TestConfusingVariableNames < Test::Unit::TestCase
  include Pedant::Test

  def test_does
    check(
      :pass,
      :CheckConfusingVariableNames,
      %q||
    )
  end

  def test_does_not
    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|local_var CA_list; calist = 1;|
    )
  end

  def test_var_types
    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|local_var ca_list; CA_list = 1;|
    )

    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|global_var ca_list; CA_list = 1;|
    )

    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|global_var ca_list; function foo() { local_var CA_list; }|
    )
  end

  def test_underscores
    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|global_var ca_list; calist = 1;|
    )

    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|global_var ca__list; calist = 1;|
    )
  end

  def test_capitalization
    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|global_var calist; CAlist = 1;|
    )

    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|global_var CA_list; ca_list = 1;|
    )
  end

  def test_lvalue_idents
    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|ca_list.CA_list = 1;|
    )

    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|ca_list[foo.bar[CA_list]] = 1;|
    )

    check(
      :warn,
      :CheckConfusingVariableNames,
      %q|ca_list[foo.CA_list[10 + "woo"]] = 1;|
    )
  end
end
