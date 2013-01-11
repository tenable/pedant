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

module Pedant
  class CheckScriptName < Check
    def self.requires
      super + [:main, :trees]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      sn_nodes = []
      tree = @kb[:trees][@kb[:main]]

      tree.all(:Call).each do |node|
        next unless node.name.name == 'script_name'
        sn_nodes << node
      end

      if sn_nodes.length == 0
        report(:error, "Plugin does not call script_name() in the description.")
        return fail
      elsif sn_nodes.length > 1
        report(:error, "Plugin calls script_name() multiple times:")
        sn_nodes.each { |call| report(:error, call.context()) }
        return fail
      end

      sn_node = sn_nodes.first

      if sn_node.args.empty?
        report(:error, "script_name() was called with no arguments:\n#{sn_node.context()}")
        return fail
      end

      if sn_node.args.length > 1
        report(:error, "script_name() was called with too many arguments:\n#{sn_node.context()}")
        return fail
      end
        
      # Pull out argument
      type = sn_node.args.first.type
      param = sn_node.args.first.name
      arg = sn_node.args.first.expr

      if type == :anonymous
        report(
          :error,
          "script_name() was called using a positional parameter.\n" +
          "It requires using an argument to the 'english' named parameter.\n" +
          arg.context(sn_node)
        )
        return fail
      end

      if param.name != "english"
        report(
          :error,
          "script_name() was called using an invalid named parameter.\n" +
          "The 'english' named parameter must be used.\n" +
          param.context(sn_node)
        )
        return fail
      end
       
      unless arg.is_a? Nasl::String
        report(
          :error,
          "script_name() was called with the wrong type of argument.\n" +
          "An integer literal between 10001 and 999999 inclusive is required:\n" +
          arg.context(sn_node)
        )
        return fail
      end

      if arg.text.length == 0
        report(
          :error,
          "script_name() was called with an empty string.\n" +
          arg.context(sn_node)
        )
        return fail
      end

      if arg.text.slice(0) == " " && arg.text.slice(-1) == " "
        ws_error = "Script name has leading and trailing whitespace:\n"
      elsif arg.text.slice(0) == " "
        ws_error = "Script name has leading whitespace:\n"
      elsif arg.text.slice(-1) == " "
        ws_error = "Script name has trailing whitespace:\n"
      else
        ws_error = nil
      end
 
      unless ws_error.nil?
        report(
          :error,
          ws_error +
          arg.context(sn_node)
        )
        return fail
      end

      # Ensure that the script id is valid.
      if arg.text.slice(-1) == " "
        report(
          :error,
          "Script name has trailing whitespace:\n" +
          arg.context(sn_node)
        )
        return fail
      end

      report(:info, "Plugin has a script name of '#{arg.text}':\n#{arg.context(sn_node)}")
      pass
    end
  end
end
