################################################################################
# Copyright (c) 2011, Mak Kolybabi
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
  class CheckContainsRegistrationSection < Check
    def self.requires
      super + [:main, :trees]
    end

    def run
      # This check only applies to plugins.
      return skip unless @kb[:main].extname == '.nasl'

      # This check will pass by default.
      pass

      tree = @kb[:trees][@kb[:main]]

      # Find the registration If statement.
      regs = tree.all(:If).select do |node|
        (node.cond.is_a?(Nasl::Lvalue) && node.cond.ident.name == 'description')
      end

      # Ensure there's a registration section.
      if regs.empty?
        report(:error, "No registration section was found.")
        report(:error, "This will cause the plugin to be run twice in both Nessus interface and nasl with the -M flag.")
        return fail
      end

      # Ensure that there is only one registration section.
      unless regs.length == 1
        report(:error, "Multiple registration sections were found.")
        regs.each { |reg| report(:error, reg.context) }
        return fail
      end

      # Ensure that the registration section is a block.
      reg = regs.first
      branch = reg.true
      unless branch.is_a? Nasl::Block
        report(:error, "The registration section is a #{branch.class.name}, but a Block was expected.")
        report(:error, branch.context(reg))
        return fail
      end

      # Ensure that the registration section is not empty.
      if branch.body.empty?
        report(:error, "The registration section is empty.")
        report(:error, branch.context(reg))
        return fail
      end

      # Ensure that the description section ends with a call to exit.
      statement = branch.body.last
      unless statement.is_a? Nasl::Call
        report(:error, "The registration section ends with a #{statement.class.name}, not a Call as expected.")
        report(:error, statement.context(reg))
        return fail
      end

      unless statement.name.name == 'exit'
        report(:error, "The registration section ends with a call to #{statement.name.name}, not exit as expected.")
        report(:error, statement.context(reg))
        return fail
      end

      # Ensure that the call to exit is a success without a message.
      args = statement.args
      if args.empty?
        report(:error, "The registration ends with a call to exit with no arguments.")
        report(:error, statement.context)
        return fail
      end

      arg = args.first
      if args.length != 1 || arg.type != :anonymous || !arg.expr.is_a?(Nasl::Integer) || arg.expr.value != 0
        report(:error, "The registration section does not end with a call to exit(0).")
        report(:error, arg.context(statement))
        return fail
      end
    end
  end
end
