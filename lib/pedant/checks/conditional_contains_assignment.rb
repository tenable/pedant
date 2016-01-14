################################################################################
# Copyright (c) 2014, Tenable Network Security
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
  class CheckConditionalContainsAssignment < Check
    def self.requires
      super + [:trees]
    end

    def check(file, tree)
      def walk(node, root)
        # Assignments of literals are the most likely to be bugs (determined empirically).
        literals = [
          Nasl::String,
          Nasl::Integer,
          Nasl::Identifier,
          Nasl::Ip,
        ]

        # Recursively descend into the right-hand and left-hand sides of each expression.
        if node.is_a? Nasl::Expression
          [:lhs, :rhs].each { |side| walk(node.send(side), root) }
        end

        if node.is_a?(Nasl::Assignment)
          # A bit of a kludge, here. Because assignment has such a low precedence, we can see two
          # different scenarios: the simpler scenario, where the Assignment's expr is the literal
          # being assigned. Example:
          #   if (a = 5) { ... }  ->  node.expr == <Nasl::Integer>:5
          #
          # In the other scenario, the literal being assigned gets "absorbed" into an Expression
          # with the higher-precedence operators. Example:
          #   if (a = 5 && foo == bar) { ... }  ->  node.expr     == <Nasl::Expression>
          #                                         node.expr.lhs == <Nasl::Integer>:5
          #
          # In this second case, we can look for the literal in the Expression's left-hand side.
          if literals.include?(node.expr.class) or
             node.expr.is_a?(Nasl::Expression) && literals.include?(node.expr.lhs.class)

            fail
            report(:error, "A conditional statement contains an assignment operation.")
            report(:error, node.op.context(root))
          end
        end
      end

      cond_stmts = [:For, :Repeat, :While, :If].map { |cls| tree.all(cls) }.flatten
      cond_stmts.each { |cond_stmt| walk(cond_stmt.cond, cond_stmt) }
    end

    def run
      # This check will pass by default.
      pass

      # Run this check on the tree from every file.
      @kb[:trees].each { |file, tree| check(file, tree) }
    end
  end
end
