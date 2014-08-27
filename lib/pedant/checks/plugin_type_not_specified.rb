################################################################################
# Copyright (c) 2011-2014, Tenable Network Security
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
  class CheckPluginTypeNotSpecified < Check
    def self.requires
      super + [:main, :trees]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      args = []

      tree = @kb[:trees][@kb[:main]]

      tree.all(:Call).each do |node|
        next unless node.name.ident.name == 'script_set_attribute'
        next unless node.name.indexes == []
        next unless node.arg.has_key? 'attribute'

        # Pull out the attribute argument.
        arg = node.arg['attribute']
        next if !arg.is_a? Nasl::String
        next if arg.text != 'plugin_type'

        # Pull out the value argument.
        arg = node.arg['value']
        next if !arg.is_a? Nasl::String

        # Ensure that the plugin type is valid.
        unless ['combined', 'local', 'reputation', 'remote', 'settings', 'summary', 'thirdparty'].include? arg.text
          report(:info, "Plugin is of unknown type #{arg.text}:\n#{arg.context(node)}")
          return fail
        end

        args << [arg, node]
      end

      case args.length
      when 0
        report(:error, "Plugin does not specify a type.")
        fail
      when 1
        arg = args.first[0]
        call = args.first[1]
        report(:info, "Plugin is of type #{arg.text}:\n#{arg.context(call)}")
        pass
      else
        report(:error, "Plugin specifies multiple types.")
        args.each { |arg, call| report(:error, arg.context(call)) }
        fail
      end
    end
  end
end
