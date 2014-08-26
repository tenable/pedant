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
  class CheckScriptId < Check
    def self.requires
      super + [:main, :trees]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      si_nodes = []
      tree = @kb[:trees][@kb[:main]]

      tree.all(:Call).each do |node|
        next unless node.name.ident.name == 'script_id'
        next unless node.name.indexes == []
        si_nodes << node
      end

      if si_nodes.length == 0
        report(:error, "Plugin does not call script_id() in the description.")
        return fail
      elsif si_nodes.length > 1
        report(:error, "Plugin specifies multiple script IDs:")
        si_nodes.each { |call| report(:error, call.context()) }
        return fail
      end

      si_node = si_nodes.first

      if si_node.args.empty?
        report(:error, "script_id() was called with no arguments:\n#{si_node.context()}")
        return fail
      end

      if si_node.args.length > 1
        report(:error, "script_id() was called with too many arguments:\n#{si_node.context()}")
        return fail
      end
        
      # Pull out argument
      type = si_node.args.first.type
      arg = si_node.args.first.expr

      if type != :anonymous
        report(
          :error,
          "script_id() was called using a named parameter.  It requires using one positional parameter.\n" +
          arg.context(si_node)
        )
        return fail
      end
       
      unless arg.is_a? Nasl::Integer
        report(
          :error,
          "script_id() was called with the wrong type of argument.\n" +
          "An integer literal between 10001 and 999999 inclusive is required:\n" +
          arg.context(si_node)
        )
        return fail
      end

      # Ensure that the script id is valid.
      if arg.value < 10001 or arg.value > 999999
        report(
          :error,
          "script_id() was called with an invalid argument.\n" +
          "An integer literal between 10001 and 999999 inclusive is required:\n" +
          arg.context(si_node)
        )
        return fail
      end

      # Ensure that the script id is valid.
      if arg.value >= 900001 and arg.value <= 999999
        report(
          :warn,
          "Uses a script id reserved for custom plugins / plugins in development.\n" +
          arg.context(si_node)
        )
        return warn
      end

      report(:info, "Plugin has script id #{arg.value}:\n#{arg.context(si_node)}")
      pass
    end
  end
end
