################################################################################
# Copyright (c) 2016, Tenable Network Security
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

##
# This module can identify simple socket leaks (socket was opened
# but never closed). Unfortunately, this implementation only works
# in immediate block scope (ie doesn't search up a block or down
# a block for the close). As such, false positives/negatives can
# occur. Which is why this uses the "warning" report
##
module Pedant
  class CheckSocketLeak < Check
    def self.requires
      super + [:trees]
    end

    ##
    # Breaks the tree up into blocks and feeds them into block_parser
    # @param file the current file being examined
    # @param tree the entire file tree
    ##
    def check(file, tree)
      ##
      # Examines a single passed in node and tries to appropriately handle it
      # based on the type.
      #
      # @param bnode the node to examine
      # @param found a set of active "open_sock_tcp" items
      # @return the new list of open_sock_tcp items
      ##
      def node_parser(bnode, found)
          if bnode.is_a?(Nasl::Call)
            if (bnode.name.ident.name == "open_sock_tcp")
              found.add("")
            elsif (bnode.name.ident.name == "close")
              # Check that this is an Lvalue. It could be a call or something
              # which is just too complicated to handle and doesn't really work
              # with our variable tracking system
              if bnode.args[0].expr.is_a?(Nasl::Lvalue)
                found = found - [bnode.args[0].expr.ident.name]
              end
            end
          elsif bnode.is_a?(Nasl::Assignment)
            name = ""
            if bnode.lval.is_a?(Nasl::Lvalue)
              name = bnode.lval.ident.name;
            end
            if bnode.expr.is_a?(Nasl::Call)
              if (bnode.expr.name.ident.name == "open_sock_tcp")
                found.add(name)
              end
            end
          elsif bnode.is_a?(Nasl::Local)
            bnode.idents.each do |idents|
              if idents.is_a?(Nasl::Assignment)
                name = ""
                if idents.lval.is_a?(Nasl::Lvalue)
                  name = idents.lval.ident.name
                elsif idents.lval.is_a?(Nasl::Identifier)
                  name = idents.lval.name
                end
                if idents.expr.is_a?(Nasl::Call)
                  if (idents.expr.name.ident.name == "open_sock_tcp")
                    found.add(name)
                  end
                end
              end
            end
          elsif bnode.is_a?(Nasl::Return)
            # if the socket we are tracking gets returned then never mark it as
            # a leak
            if bnode.expr.is_a?(Nasl::Lvalue)
                found = found - [bnode.expr.ident.name]
            end
          elsif bnode.is_a?(Nasl::If)
            # the if statement provides us with a block we can peak down to.
            # However, it isn't always enumerable so handle accordingly
            if (bnode.true.is_a?(Enumerable))
              found = block_parser(bnode.true, found)
            else
              found = node_parser(bnode.true, found);
            end
            if (bnode.false.is_a?(Enumerable))
              found = block_parser(bnode.false, found)
            else
              found = node_parser(bnode.false, found);
            end
          end
          return found
        end

      ##
      # Iterates over the blocks and hands individual nodes up to the node_parser
      # @param block the current Block node to examine
      # @param found the current list of found open_sock_tcp
      # @param all the found open_sock_tcp that haven't been closed
      ##
      def block_parser(block, found)
        block.each do |node|
          found = node_parser(node, found);
        end
        return found;
      end

      # Extract by the block. Will help us since we don't dive down into all
      # blocks as of yet (only if statements)
      allFound = Set.new
      tree.all(:Block).each do |node|
        allFound.merge(block_parser(node.body, Set.new))
      end
      
      # The main body of a file is not a Block, so it must be considered
      # separately.
      allFound.merge(block_parser(tree, Set.new))

      if allFound.size() > 0
        warn
        output = ""
        allFound.each do |handle|
          if !output.empty?
            output += ", "
          end
          if handle == ""
            handle = "<unassigned>"
          end
          output += handle
        end
        report(:warn, "Possibly leaked socket handle(s): " + output)
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
