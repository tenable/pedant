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

class TestSockLeak < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :pass,
      :CheckSocketLeak,
      %q||
    )
  end
  
  def test_simple_no_close
    check(
      :warn,
      :CheckSocketLeak,
      %q|soc = open_sock_tcp(8080); exit(0);|
    )
  end
  
  def test_good_close
    check(
      :pass,
      :CheckSocketLeak,
      %q|soc = open_sock_tcp(8080); close(soc);|
    )
  end
  
   def test_wrong_handle_close
    check(
      :warn,
      :CheckSocketLeak,
      %q|soc = open_sock_tcp(8080); close(sock);|
    )
  end

   def test_local_var_no_close
    check(
      :warn,
      :CheckSocketLeak,
      %q|local_var soc = open_sock_tcp(8080); exit(0);|
    )
  end
  
  def test_local_var_close
    check(
      :pass,
      :CheckSocketLeak,
      %q|local_var soc = open_sock_tcp(8080); close(soc);|
    )
  end

  def test_local_var_close_wrong_handle
    check(
      :warn,
      :CheckSocketLeak,
      %q|local_var soc = open_sock_tcp(8080); close(sock);|
    )
  end
  
  # This is an example of what this parser can't handle.
  #def test_local_var_close_wrong_handle
  #  check(
  #    :pass,
  #    :CheckSocketLeak,
  #    %q|local_var soc = open_sock_tcp(8080); if (soc) close(soc); exit(0);|
  #  )
  #end

end
