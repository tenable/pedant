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

require 'set'

module Pedant
  class CheckNonsenseComparison < Check
    def self.requires
      super + [:trees]
    end

    def check(file, tree)
      literals = Set.new [
        Nasl::Array,
        Nasl::List,
        Nasl::Integer,
        Nasl::String,
        Nasl::Ip
      ]

      comparisons = Set.new [ "==", "!=", "=~", "!~", "><", ">!<", "<", ">", "<=", ">=" ]

      # isnull() with a literal (never FALSE).
      tree.all(:Call).each do |call|
        next if call.name.ident.name != "isnull"
        next if call.name.indexes != []
        next if call.args.length != 1
        next if not literals.include? call.args.first.expr.class
        fail
        report(:error, "isnull() is called with a literal, which can never be FALSE.")
        report(:error, call.args.first.context(call))
      end

      # Comparing a literal to another literal (either TRUE or FALSE, but pointless).
      tree.all(:Expression).each do |expr|
        next if not literals.include? expr.lhs.class
        next if not literals.include? expr.rhs.class
        next if not comparisons.include? expr.op.to_s
        fail
        report(:error, "Comparing two literals is always TRUE or FALSE.")
        report(:error, expr.op.context(expr))
      end

      # Comparing something against itself.
      tree.all(:Expression).each do |expr|
        next if not comparisons.include? expr.op.to_s
        next if not expr.lhs.is_a? Nasl::Lvalue
        next if not expr.rhs.is_a? Nasl::Lvalue
        # Compare the XML representations of the two Lvalues.
        # Handles integer keys nicely, so these two are the same: a[0x01] == a[1]
        xmls = [:lhs, :rhs].map do |side|
          expr.send(side).to_xml(Builder::XmlMarkup.new)
        end
        next if xmls[0] != xmls[1]
        fail
        report(:error, "Comparing two identical Lvalues. This will always be TRUE.")
        report(:error, expr.op.context(expr))
      end
    end

    def run
      # This check will pass by default.
      pass

      # Run this check on the tree from every file.
      @kb[:trees].each { |file, tree| check(file, tree) }
    end
  end
end
