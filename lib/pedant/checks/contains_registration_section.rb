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
    def initialize
      super

      @requires << :main
      @requires << :trees
    end

    def run(kb)
      # This check only applies to plugins.
      return skip if kb[:main] !~ /.nasl$/

      # This check will pass by default.
      pass

      tree = kb[:trees][kb[:main]]

      # Find the registration If statement.
      reg = []
      tree.all(:If).each do |node|
        next if !node.cond.is_a? Nasl::Lvalue
        next if node.cond.ident.name != 'description'
        reg << node
      end

      # Ensure there's a registration section.
      if reg.empty?
        report(:error, "No registration section was found.")
        report(:error, "This will cause the plugin to be run twice in both Nessus interface and nasl with the -M flag.")
        return fail
      end

      # Ensure that there is only one registration section.
      if reg.length != 1
        report(:error, "#{reg.length} registration sections were found.")
        return fail
      end

      # Ensure that the registration section is a block.
      reg = reg.first.true
      if !reg.is_a? Nasl::Block
        report(:error, "The registration section is a #{reg.class.name}, but a Block was expected.")
        return fail
      end

      # Ensure that the registration section is not empty.
      if reg.body.empty?
        report(:error, "The registration section is empty.")
        return fail
      end

      # Ensure that the description section ends with a call to exit.
      last = reg.body.last
      if !last.is_a?(Nasl::Call)
        report(:error, "The registration section ends with a #{last.class.name}, not a Pedant::Nasl::Call as expected.")
        return fail
      elsif last.name.name != "exit"
        report(:error, "The registration section ends with a call to #{last.name.name}, not exit as expected.")
        return fail
      end

      # Ensure that the call to exit doesn't indicate an error.
      arg = last.args.first
      if arg.nil? || arg.type != :anonymous || !arg.expr.is_a?(Nasl::Integer) || arg.expr.value != 0
        report(:error, "The registration section does not end with a call to exit(0).")
        return fail
      end
    end
  end
end
