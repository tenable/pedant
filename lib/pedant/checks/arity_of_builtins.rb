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

require 'set'

module Pedant
  class CheckArityOfBuiltins < Check
    @@anon_arity_of_one = Set.new [
      "isnull",
      # Sockets
      "get_port_state",
      "get_tcp_port_state",
      "get_udp_port_state",
      "close",
      # String functions
      "strlen",
      "int",
      "uint",
      "chomp",
      "ord",
      "hex",
      "hexstr",
      "tolower",
      "toupper",
      "xmlparse",
      # Time
      "usleep",
      "sleep",
      # Arrays and lists
      "keys",
      "max_index",
      "sort",
      # Runtime checks
      "typeof",
      "typeof_ex",
      "defined_func",
      # Bignum functions
      "bn_dec2raw",
      "bn_raw2dec",
      "bn_hex2raw",
      "bn_raw2hex",
      "bn_sqr",
      # File system
      "fread",
      "unlink",
      "readdir",
      "mkdir",
      "rmdir",
      # Unkeyed hashes (crypto)
      "SHA",
      "SHA1",
      "SHA224",
      "SHA256",
      "SHA384",
      "SHA512",
      "RIPEMD160",
      "MD2",
      "MD4",
      "MD5",
      # Knowledge base
      "get_kb_item",
      "get_kb_list",
      "get_global_kb_item",
      "get_global_kb_list",
    ]

    def self.requires
      super + [:trees]
    end

    def check(file, tree)
      tree.all(:Call).each do |call|
        next unless call.name.indexes == []
        name = call.name.ident.name

        if @@anon_arity_of_one.include? name
          next if call.args.length == 1 and call.args.first.type == :anonymous
          fail
          report(:error, "The builtin function '#{name}' takes a single anonymous argument.")
          # Pick the right thing to highlight.
          if call.args.length == 0
            report(:error, call.context(call))
          elsif call.args.first.type != :anonymous
            report(:error, call.args[0].context(call))
          elsif call.args.length > 1
            report(:error, call.args[1].context(call))
          end
        end

        if name == "make_array"
          next if call.args.length.even?
          fail
          report(:error, "The builtin function 'make_array()' takes an even number of arguments.")
          report(:error, call.context(call))
        end
      end
    end

    def run
      # This check will pass by default.
      pass

      # Run this check on the tree from every file.
      @kb[:trees].each { |file, tree| check(file, tree) }
    end
  end
end
