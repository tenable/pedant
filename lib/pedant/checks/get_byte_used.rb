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
  class CheckGetByteUsed < Check
    def self.requires
      super + [:main, :trees]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      tree = @kb[:trees][@kb[:main]]

      tree.all(:Call).each do |node|
        next unless [
          "get_byte",
          "get_word",
          "get_dword"
        ].include? node.name.ident.name

        # error if we are also using set_byte_order()
        if tree.all(:Call).any? { |node2| node2.name.ident.name == "set_byte_order" }
          report(:error, "Plugin is using #{node.name.ident.name}(), which does not respect set_byte_order(). Since this plugin also uses set_byte_order(), we should be using the set_byte_order() respecting function #{node.name.ident.name.tr("_","")}() from byte_func.inc instead, as #{node.name.ident.name}() will always operate as if the byte order is set to little endian.")
          report(:error, node.context())
          return fail
        end

        # just warn otherwise
        report(:warn, "Plugin is using #{node.name.ident.name}(), which does not respect set_byte_order(). Consider using the set_byte_order() respecting function #{node.name.ident.name.tr("_","")}() from byte_func.inc instead, as #{node.name.ident.name}() will always operate as if the byte order is set to little endian.")
        report(:warn, node.context())
        return fail
      end
      report(:info, "Plugin is not using any of get_byte(), get_word(), or get_dword(), which can be problematic as they do not respect set_byte_order().")
      pass
    end
  end
end
