################################################################################
# Copyright (c) 2012, Mak Kolybabi
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

class TestScriptFamilyNotSpecified < Test::Unit::TestCase
  include Pedant::Test

  def test_none
    check(
      :fail,
      :CheckScriptFamilyNotSpecified,
      %q||
    )
  end

  def test_one
    check(
      :pass,
      :CheckScriptFamilyNotSpecified,
      %q|script_family("Windows");|
    )
  end

  def test_many
    check(
      :fail,
      :CheckScriptFamilyNotSpecified,
      %q|script_family("Windows");| +
      %q|script_family("FTP");|
    )
  end

  def test_valid
    [
          "AIX Local Security Checks",
          "Backdoors",
          "Brute force attacks",
          "CentOS Local Security Checks",
          "CGI abuses",
          "CGI abuses : XSS",
          "CISCO",
          "Databases",
          "Debian Local Security Checks",
          "Default Unix Accounts",
          "Denial of Service",
          "DNS",
          "Fedora Local Security Checks",
          "Firewalls",
          "FreeBSD Local Security Checks",
          "FTP",
          "Gain a shell remotely",
          "General",
          "Gentoo Local Security Checks",
          "HP-UX Local Security Checks",
          "Junos Local Security Checks",
          "MacOS X Local Security Checks",
          "Mandriva Local Security Checks",
          "Misc.",
          "Mobile Devices",
          "Netware",
          "Peer-To-Peer File Sharing",
          "Policy Compliance",
          "Port scanners",
          "Red Hat Local Security Checks",
          "RPC",
          "SCADA",
          "Scientific Linux Local Security Checks",
          "Service detection",
          "Settings",
          "Slackware Local Security Checks",
          "SMTP problems",
          "SNMP",
          "Solaris Local Security Checks",
          "SuSE Local Security Checks",
          "Ubuntu Local Security Checks",
          "VMware ESX Local Security Checks",
          "Web Servers",
          "Windows",
          "Windows : Microsoft Bulletins",
          "Windows : User management"
    ].each do |type|
      check(
        :pass,
        :CheckScriptFamilyNotSpecified,
        %Q|script_family("#{type}");|
      )
    end
  end

  def test_invalid
    check(
      :fail,
      :CheckScriptFamilyNotSpecified,
      %q|script_family("foo bar");|
    )
  end

  def test_indexed
    check(
      :fail,
      :CheckScriptFamilyNotSpecified,
      %q|script_family.foo("Windows");|
    )
  end
end
