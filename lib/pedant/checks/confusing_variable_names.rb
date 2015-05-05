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

require 'set'

module Pedant
  class CheckConfusingVariableNames < Check
    def self.requires
      super + [:trees]
    end

    def check(file, tree)
      # Two identifiers with the same normalization are likely to be confused.
      # E.g.: CA_list and ca_list, certlist and cert_list
      def normalize name
        name.gsub(/_/, '').downcase
      end

      # Set of all declared and assigned-to names in the source.
      names = Set.new

      # Handle all local_var and global_var occurrences (both assignments and declarations).
      (tree.all(:Global) + tree.all(:Local)).each do |decl|
        decl.idents.each do |node|
          names << node.name      if node.is_a? Nasl::Identifier
          names << node.lval.name if node.is_a? Nasl::Assignment
        end
      end

      # Add every identifier from every assigned-to Nasl::Lvalue to the set of names.
      tree.all(:Assignment).map(&:lval).each do |lval|
        # Generate a nested array of Nasl::Identifier, representing the tree structure
        # of a Nasl::Lvalue.
        def lval_to_arr(lval)
          return lval if not lval.is_a?(Nasl::Lvalue)
          return [lval.ident, lval.indexes.map { |lval| lval_to_arr(lval)} ]
        end

        if lval.is_a?(Nasl::Lvalue)
          lval_to_arr(lval).flatten.each do |node|
            names << node.name if node.is_a?(Nasl::Identifier)
          end
        end

        if lval.is_a?(Nasl::Identifier)
          names << lval.name
        end
      end

      # Group names together that have the same normalized form.
      confusable_name_groups = {}
      names.each do |name|
        key = normalize(name)
        confusable_name_groups[key] ||= Set.new
        confusable_name_groups[key] << name
      end

      # Throw away the normalized forms, all we care about now is the groups.
      confusable_name_groups = confusable_name_groups.values

      # We only care about groups with more than one name in them.
      confusable_name_groups.map!(&:to_a).select! { |group| group.length > 1 }

      return if confusable_name_groups.length == 0

      warn
      report(:warn, "These sets of names differ only by capitalization or underscores:")
      confusable_name_groups.each do |names|
        report(:warn, "  #{names.join(', ')}")
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
