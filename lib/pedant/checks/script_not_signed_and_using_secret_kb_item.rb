################################################################################
# Copyright (c) 2016, Andrew Orr
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
  class CheckScriptNotSignedAndUsingSecretKBItem < Check
    def self.requires
      super + [:main, :trees, :codes]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      tree = @kb[:trees][@kb[:main]]
      codes = @kb[:codes][@kb[:main]]

      tree.all(:Call).each do |node|
	next unless [
	  "get_kb_item",
          "rm_kb_item",
          "get_kb_list",
          "replace_kb_item",
          "set_kb_item",
          "script_require_keys",
          "set_global_kb_item",
          "get_global_kb_item",
          "get_fresh_kb_item",
          "get_global_kb_list",
          "get_kb_item_or_exit"
	].include? node.name.ident.name
      	next if node.args.empty?

        # one case where we check all arguments
        if node.name.ident.name == "script_require_keys"
	  node.args.each { |arg|
            arg = arg.expr
            next unless arg.text.index("Secret") == 0
            next if codes.index("#TRUSTED") == 0
	    report(
              :warn,
              "Plugin is accessing the secret KB item #{arg.text} and needs to be signed."
            )
            return fail
          }
        end

        # every other function we need to check the first argument, or if the arguments are named, the 'name' argument
	arg = node.args.first.expr
	if node.args.first.name.respond_to? :name
	  arg = node.args[1].expr if node.args[1].name.name == "name"
        end
  
        if arg.text.index("Secret") == 0
          next if codes.index("#TRUSTED") == 0
          report(
            :warn,
            "Plugin is accessing the secret KB item #{arg.text} and needs to be signed."
          )
          return fail
        end
      end
      report(:info, "Plugin is not using an secret KB items without being signed.")
      pass
    end
  end
end
