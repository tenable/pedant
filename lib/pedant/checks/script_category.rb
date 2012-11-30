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
  class CheckScriptCategory < Check
    def self.requires
      super + [:main, :trees]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      sc_nodes = []
      tree = @kb[:trees][@kb[:main]]

      tree.all(:Call).each do |node|
        next unless node.name.name == 'script_category'
        sc_nodes << node
      end

      if sc_nodes.length == 0
        report(:error, "Plugin does not specify a script_category.")
        return fail
      elsif sc_nodes.length > 1
        report(:error, "Plugin specifies multiple script categories:")
        sc_nodes.each { |call| report(:error, call.context()) }
        return fail
      end

      sc_node = sc_nodes.first

      if sc_node.args.empty?
        report(:error, "script_category() was called with no arguments:\n#{sc_node.context()}")
        return fail
      end

      if sc_node.args.length > 1
        report(:error, "script_category() was called with too many arguments:\n#{sc_node.context()}")
        return fail
      end
        
      # Pull out argument
      arg = sc_node.args.first.expr
       
      unless sc_node.args.first.expr.is_a? Nasl::Lvalue
        report(
          :error,
          "script_category() was called with the wrong type of argument\n" +
          "(a variable starting with ACT_ must be provided):\n" +
          arg.context(sc_node)
        )
        return fail
      end

      # Ensure that the script category is valid.
      unless [
        "ACT_INIT",
        "ACT_SCANNER",
        "ACT_SETTINGS",
        "ACT_GATHER_INFO",
        "ACT_ATTACK",
        "ACT_MIXED",
        "ACT_DESTRUCTIVE_ATTACK",
        "ACT_COMPLIANCE_CHECK",
        "ACT_PATCH_SETUP",
        "ACT_PATCH_APPLY",
        "ACT_PATCH_POST_APPLY",
        "ACT_THIRD_PARTY_INFO",
        "ACT_DENIAL",
        "ACT_KILL_HOST",
        "ACT_FLOOD",
        "ACT_END"
      ].include? arg.ident.name
        report(
          :error,
          "Plugin belongs to unknown category #{arg.ident.name}:\n" +
          arg.context(sc_node)
        )
        return fail
      end

      report(:info, "Plugin belongs to script category #{arg.ident.name}:\n#{arg.context(sc_node)}")
      pass
    end
  end
end
