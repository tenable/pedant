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
  class CheckEqualityWithRegex < Check
    def self.requires
      super + [:trees]
    end

    def check(file, tree)
      def walk(node, root)
        # Recursively descend into the right-hand and left-hand sides of each expression.
        if node.is_a? Nasl::Expression
          [:lhs, :rhs].each { |side| walk(node.send(side), root) }

          return unless node.op.is_a?(Nasl::Token)
          return unless ["==", "!="].include?(node.op.body)
          return unless node.rhs.is_a?(Nasl::String)
          str = node.rhs.text
          return unless str.length > 2
          return unless str[0] == "^" and str[-1] == "$"

          fail
          report(:error, "An equality comparison is being made with what appears to be a regex.")
          report(:error, "This might be a typo in the operator.")
          report(:error, node.op.context(node))
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
