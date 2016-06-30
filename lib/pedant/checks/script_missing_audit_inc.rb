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

module Pedant
  class CheckScriptDoesNotUseAuditDotInc < Check
    def self.requires
      super + [:main, :trees, :codes]
    end

    def run
      args = []
      tree = @kb[:trees][@kb[:main]]

      tree.all(:Include).each do |node|
        next unless node.filename.text == 'audit.inc'
        report(:info, "#{node.filename.text}")
        args << node
      end # each

      audit_calls = []
      tree.all(:Call).each do |node|
        next unless node.name.ident.name == "audit"
        next if node.args.empty?
        audit_calls << node
      end

      if args.length == 0
        report(:warn, "Plugin does not include audit.inc. Should it?")
        return warn
      elsif args.length == 1
        if audit_calls.length == 0
          report(:warn, "Plugin includes audit.inc but does not make a direct audit call")
          return warn
        end
        pass
      elsif args.length > 1
        report(:error, "Plugin specifies multiple audit.inc:")
        args.each { |call| report(:error, call.context()) }
        return fail
      end

    end # def run
  end #class
end #module
