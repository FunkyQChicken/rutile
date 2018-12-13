require 'pry'


require_relative "./nfa.rb"
require_relative "lexer.rb"
require "test-unit"


class Test_FSM < Test::Unit::TestCase
    # nfa of the regex "((ab)*aba)" :aba  and "\n" :newline
    def set_nfa
        aba = NFA::to_nfa "((ab)*aba)", :aba
        newline = NFA::to_nfa "\n", :newline
        aba.or newline

        @nfa = aba
    end

    def test_to_fsm
        set_nfa

        files = ["./testfiles/aba.test"]
        parser_a = Parser.new(@nfa, files)
        pry
        a = parser_a.parse.to_a
        
        a.each {|t| p t}
    end
end
