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

module Pedant
  class CheckScriptNotSignedAndUsingTrustedFunction < Check
    def self.requires
      super + [:main, :trees, :codes]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      tree = @kb[:trees][@kb[:main]]
      codes = @kb[:codes][@kb[:main]]

      tree.all(:Call).each do |node|
        # builtin trusted functions
        next unless [
          "bind_sock_tcp",
          "bind_sock_tcp6",
          "bind_sock_udp",
          "bind_sock_udp6",
          "can_query_report",
          "cfile_open",
          "cfile_stat",
          "db_open",
          "db_open2",
          "db_open_ex",
          "db_query",
          "db_query_foreach",
          "dsa_do_sign",
          "dump_interfaces",
          "file_close",
          "file_fstat",
          "file_is_signed",
          "file_md5",
          "file_mkdir",
          "file_mtime",
          "file_open",
          "file_read",
          "file_rename",
          "file_seek",
          "file_stat",
          "file_write",
          "find_in_path",
          "fork",
          "fread",
          "fwrite",
          "gc",
          "get_preference_file_content",
          "get_preference_file_location",
          "get_tmp_dir",
          "inject_packet",
          "is_user_root",
          "kb_ssh_certificate",
          "kb_ssh_login",
          "kb_ssh_password",
          "kb_ssh_privatekey",
          "kb_ssh_publickey",
          "kb_ssh_realm",
          "kb_ssh_transport",
          "kill",
          "load_db_master_key_cli",
          "mkdir",
          "mkdir_ex",
          "mutex_lock",
          "mutex_unlock",
          "nessus_get_dir",
          "open_sock2",
          "open_sock_ex",
          "pem_to_dsa",
          "pem_to_dsa2",
          "pem_to_pub_rsa",
          "pem_to_rsa",
          "pem_to_rsa2",
          "pread",
          "query_report",
          "readdir",
          "recvfrom",
          "rename",
          "resolv",
          "rmdir",
          "rsa_sign",
          "same_host",
          "schematron_validate",
          "script_get_preference_file_content",
          "script_get_preference_file_location",
          "sendto",
          "set_mem_limits",
          "socket_accept",
          "ssl_accept3",
          "ssl_accept4",
          "syn_scan",
          "tcp_scan",
          "thread_create",
          "udp_scan",
          "unlink",
          "untar_plugins",
          "xmldsig_sign",
          "xmldsig_verify",
          "xmlparse",
          "xsd_validate",
          "xslt_apply_stylesheet",
          "xslt_filter",
          # trusted functions from includes
          # cisco_kb_cmd_func.inc
          "cisco_command_kb_item",
          # macosx_func.inc
          "exec_cmd",
          "exec_cmds",
          "get_users_homes",
          # ssh_func.inc
          "ssh_cmd",
          # ssh1_func.inc
          "ssh_cmd1",
          # functions that can call open_sock2()
          "enable_keepalive",
          "http_is_dead",
          "http_keepalive_enabled",
          "http_open_soc_err",
          "http_open_socket_ka",
          "http_recv_body",
          "http_recv_headers3",
          "http_recv3",
          "http_reopen_socket",
          "http_send_recv_req",
          "http_send_recv3",
          "http_set_error"
        ].include? node.name.ident.name

        if [
          # functions that can call open_sock2()
          "enable_keepalive",
          "http_is_dead",
          "http_keepalive_enabled",
          "http_open_soc_err",
          "http_open_socket_ka",
          "http_recv_body",
          "http_recv_headers3",
          "http_recv3",
          "http_reopen_socket",
          "http_send_recv_req",
          "http_send_recv3",
          "http_set_error"
        ].include? node.name.ident.name
          # check if we use the named argument 'target'
          next unless node.args.any? { |arg|
            arg.respond_to? :name and arg.name.respond_to? :name and arg.name.name == "target" 
          }
          next if codes.index("#TRUSTED") == 0
          report(
            :warn,
            "Plugin is using the function #{node.name.ident.name}() with the 'target' argument, which makes it call open_sock2(), a trusted function, and may need to be signed."
          )
          report(:warn, node.context())
          return fail
        end

        next if codes.index("#TRUSTED") == 0
        report(
          :warn,
          "Plugin is using the trusted function #{node.name.ident.name}() and may need to be signed."
        )
        report(:warn, node.context())
        return fail
      end
      report(:info, "Plugin is not using a trusted function.")
      pass
    end
  end
end
