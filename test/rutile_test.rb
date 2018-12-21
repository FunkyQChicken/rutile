require "test_helper"
require 'pry'

# These tests work fairly well, but they are by no means comprehensive.
class RutileTest < Minitest::Test

    def test_that_it_has_a_version_number
      refute_nil ::Rutile::VERSION
    end
  

    def test_nfa
        aba = Rutile::NFA::to_nfa "((ab)*aba)", :aba
        newline = Rutile::NFA::to_nfa "\n", :newline
        aba.or newline
        files = get_test_files ["aba.test"]

        parser_a = Rutile::Parser.new(aba, files)

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


    def test_dot
        nfa = Rutile::NFA::to_nfa "\\(.\\)", :par    
        newline = Rutile::NFA::to_nfa "\n", :newline
        nfa.or newline
        
        files = get_test_files ["dot.test"]

        parser_a = Rutile::Parser.new(nfa, files)

        @n = nfa
        a = parser_a.parse.to_a
        
        a = a.select {|t| t.type == [:par]}
        a = a.map {|t| t.string}

        assert(a.shift == "(1)")
        assert(a.shift == "(3)")
        assert(a.shift == "(a)")
        assert(a.shift == "(A)")
        assert(a.shift == "(.)")
        assert(a.shift == "(9)")
    end


    def test_lang
        # test a basic polish notation calculator
       
        lang = Rutile::Lang.new 
        files = get_test_files ["math.test", "math_a.test"]
        
        @stack = []
        @results = []

        lang.tok('-?[\d]+', :num) do |x|
            @stack << x.to_i
        end

        lang.tok('\+', :plu) do |x|
            @stack << @stack.pop + @stack.pop
        end

        lang.tok('\-', :sub) do |x|
            @stack << @stack.pop - @stack.pop
        end

        lang.tok('\/', :div) do |x|
            @stack << @stack.pop / @stack.pop
        end

        lang.tok('\*', :mul) do |x|
            @stack << @stack.pop * @stack.pop
        end

        lang.tok('\^', :exp) do |x|
            @stack << @stack.pop ** @stack.pop
        end

        lang.tok("\n") do |x|
            throw Exception.new("malformed line, current @stack is :#{@stack}") if @stack.size > 1
            @results << @stack.pop if !@stack.empty?
        end

        lang.tok('[\w]+')

        lang.tok("#.*")
        
        @l = lang
        lang.parse files

        assert(@results.shift == 10)
        assert(@results.shift == 256)
        assert(@results.shift == 0)
        assert(@results.shift == 16)
        assert(@results.shift == -4)
        assert(@results.shift == 16)
        assert(@results.shift == -1)
        assert(@results.shift == 1)
        
    end
    

    def test_question
        # test a small number parser, matches 'binary' strings and adds them to 
        # results
        lang = Rutile::Lang.new 
        files = get_test_files ["question.test"]

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
