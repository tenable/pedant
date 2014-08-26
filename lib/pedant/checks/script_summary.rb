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
  class CheckScriptSummary < Check
    def self.requires
      super + [:main, :trees]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      ss_nodes = []
      tree = @kb[:trees][@kb[:main]]

      tree.all(:Call).each do |node|
        next unless node.name.ident.name == 'script_summary'
        next unless node.name.indexes == []
        ss_nodes << node
      end

      if ss_nodes.length == 0
        report(:error, "Plugin does not call script_summary() in the description.")
        return fail
      elsif ss_nodes.length > 1
        report(:error, "Plugin calls script_summary() multiple times:")
        ss_nodes.each { |call| report(:error, call.context()) }
        return fail
      end

      ss_node = ss_nodes.first

      if ss_node.args.empty?
        report(:error, "script_summary() was called with no arguments:\n#{ss_node.context()}")
        return fail
      end

      if ss_node.args.length > 1
        report(:error, "script_summary() was called with too many arguments:\n#{ss_node.context()}")
        return fail
      end
        
      # Pull out argument
      type = ss_node.args.first.type
      param = ss_node.args.first.name
      arg = ss_node.args.first.expr

      if type == :anonymous
        report(
          :error,
          "script_summary() was called using a positional parameter.\n" +
          "It requires using an argument to the 'english' named parameter.\n" +
          arg.context(ss_node)
        )
        return fail
      end

      if param.name != "english"
        report(
          :error,
          "script_summary() was called using an invalid named parameter.\n" +
          "The 'english' named parameter must be used.\n" +
          param.context(ss_node)
        )
        return fail
      end
       
      unless arg.is_a? Nasl::String
        report(
          :error,
          "script_summary() was called with the wrong type of argument. A string is required.\n" +
          arg.context(ss_node)
        )
        return fail
      end

      if arg.text.length == 0
        report(
          :error,
          "script_summary() was called with an empty string.\n" +
          arg.context(ss_node)
        )
        return fail
      end

      if arg.text.slice(0) == " " && arg.text.slice(-1) == " "
        ws_error = "Script summary has leading and trailing whitespace:\n"
      elsif arg.text.slice(0) == " "
        ws_error = "Script summary has leading whitespace:\n"
      elsif arg.text.slice(-1) == " "
        ws_error = "Script summary has trailing whitespace:\n"
      else
        ws_error = nil
      end
 
      unless ws_error.nil?
        report(
          :error,
          ws_error +
          arg.context(ss_node)
        )
        return fail
      end

      if arg.text.include? "\n"
        report(
          :error,
          "Script summary includes newline characters:\n" +
          arg.context(ss_node)
        )
        return fail
      end

      report(:info, "Plugin has a script summary of '#{arg.text}':\n#{arg.context(ss_node)}")
      pass
    end
  end
end
