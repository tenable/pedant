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

require 'test/unit'

module Pedant
  module Test
    def self.initialize!(args=[])
      # Run all tests by default.
      args = ['unit/**/*'] if args.empty?

      # Run each test or category of tests specified on the command line.
      args.each do |path|
        Dir.glob(Pedant.test + (path + '.rb')).each { |f| load(f) }
      end

      Check.initialize!
    end

    def setup
      Check.initialize!
    end

    def check(result, cls, code)
      # Create a knowledge base.
      kb = KnowledgeBase.new(:test_mode)

      # Put test code into the knowledge base.
      kb[:codes] = {}
      kb[:codes][kb[:main]] = code

      # Create a new instance of the check, which will execute all dependencies.
      chk = Pedant.const_get(cls).new(kb)

      # Run the test and ensure we got the expected result.
      chk.run
      assert_equal(result, chk.result)
    end
  end
end
