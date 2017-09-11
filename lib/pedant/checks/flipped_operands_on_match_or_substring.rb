################################################################################
# Copyright (c) 2015, Tenable Network Security
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
  class CheckFlippedOperandsOnMatchOrSubstring < Check
    def self.requires
      super + [:trees]
    end

    def check(file, tree)
      def walk(node, root)
        def is_get_kb_item_with_literal? node
          # Is this a call to get_kb_item with just one literal string?
          return true if node.is_a?(Nasl::Call) and
            node.name.ident.name == 'get_kb_item' and
            node.name.indexes == [] and
            node.args.length == 1 and
            node.args.first.expr.is_a?(Nasl::String)

          return false
        end
        # Recursively descend into the right-hand and left-hand sides of each expression.
        if node.is_a? Nasl::Expression
          [:lhs, :rhs].each { |side| walk(node.send(side), root) }

          return unless node.op.is_a?(Nasl::Token)

          # We have four operators we examine here:
          # The regex operators, and the substring operators. One operand is the "needle" and the other is the "haystack".
          # For substring (><, >!<), the operands go: "needle" >< "the needle in the haystack"
          # For regex, it's the opposite: "the needle in the haystack" =~ "needle"
          # It's a common error to flip these by accident.

          # For the regex operators, the left side is what is being tested and
          # the right side is the pattern to match.
          if ["=~", "!~"].include?(node.op.body)
            side = :lhs
            opposite = :rhs
          end

          # The substring operators have their operands reversed from the regex
          # operators; the right side is the thing we are testing and the left
          # side is the pattern.
          if ["><", ">!<"].include?(node.op.body)
            side = :rhs
            opposite = :lhs
          end

          # If the operator isn't one of the four we check
          return if side.nil?

          # The check for no indexes is to account for this uncommon-but-in-use
          # pattern, to check that a character falls into a certain subset of
          # acceptable characters:
          #
          #   tolower(xml[index]) >< "abcdefghijklmnopqrstuvwxyz:_"
          #
          if node.send(side).is_a?(Nasl::String) && (node.send(opposite).is_a?(Nasl::Lvalue) && node.send(opposite).indexes == []) or is_get_kb_item_with_literal?(node.send(opposite))
            warn
            report(:error, "A '#{node.op.body}' operator has a literal string on the #{if side == :lhs then 'left' else 'right' end}-hand side.")
            report(:error, "The operands may be accidentally swapped.")
            report(:error, node.send(side).context(node))
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
