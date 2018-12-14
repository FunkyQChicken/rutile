require_relative "nfa.rb"
require_relative "lang.rb"

require "test-unit"
require 'pry'


class Test_FSM < Test::Unit::TestCase
    # nfa of the regex "((ab)*aba)" :aba  and "\n" :newline

    def test_nfa
        aba = NFA::to_nfa "((ab)*aba)", :aba
        newline = NFA::to_nfa "\n", :newline
        aba.or newline
        files = ["./testfiles/aba.test"]

        parser_a = Parser.new(aba, files)

        a = parser_a.parse.to_a
        
        assert(a.shift.type == [:aba])
        assert(a.shift.type == [:aba])
        assert(a.shift.type == [:aba])
        assert(a.shift.type == [:aba])
        assert(a.shift.type == [:aba])
        assert(a.shift.type == [:newline])
        assert(a.shift.type == [:aba])
        assert(a.shift.type == [:newline])
    end




    def test_lang
        # test a basic polish notation calculator
       
        lang = Lang.new 
        files = ["./testfiles/math.test"]
        
        @stack = []
        @results = []

        lang.tok("[\\d]+", :num) do |x|
            @stack << x.to_i
        end

        lang.tok("\\+", :plu) do |x|
            @stack << @stack.pop + @stack.pop
        end

        lang.tok("\\-", :sub) do |x|
            @stack << @stack.pop - @stack.pop
        end

        lang.tok("\\/", :div) do |x|
            @stack << @stack.pop / @stack.pop
        end

        lang.tok("\\*", :mul) do |x|
            @stack << @stack.pop * @stack.pop
        end

        lang.tok("\\^", :exp) do |x|
            @stack << @stack.pop ** @stack.pop
        end

        lang.tok("\n", :eol) do |x|
            throw Exception.new("malformed line, current @stack is :#{@stack}") if @stack.size > 1
            @results << @stack.pop if !@stack.empty?
        end

        lang.tok("[\\w]+", :white_space) {|x|}

        lang.parse files

        assert(@results.shift == 10)
        assert(@results.shift == 256)
        assert(@results.shift == 0)
        assert(@results.shift == 16)
        
    end
    

    def test_question
        # test a small number parser, matches 'binary' strings and adds them to 
        # results
        lang = Lang.new 
        files = ["./testfiles/question.test"]

        @results = []
        
        lang.tok("\n", :eol){|x|}
        lang.tok("-?[10]+", :num) {|x| @results << x.to_i}

        lang.parse files

        assert(@results.shift == -1000)
        assert(@results.shift == 1000)
        assert(@results.shift == -1010011)
        assert(@results.shift == -1)
        assert(@results.shift == -101111)
    end
end


