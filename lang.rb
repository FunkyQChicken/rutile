require_relative "./nfa.rb"
require_relative "./lexer.rb"

class Lang
    def initialize
        @tokens = {}
        @nfas = []
        @priority = 0
        @nfa = nil
    end

    def tok(regex, symbol, &block)
        new_nfa = NFA::to_nfa(regex, symbol)
        @nfas << new_nfa
        @tokens[symbol] = [@priority, block]
        @priority += 1
    end

    def parse(files)
        construct_nfa if @nfa.nil?
        Parser.new(@nfa, files).parse.each do |token|
            type  = get_type(token.type)
            value = @tokens[type][1].call(token.string)
        end
    end

    private
    def get_type(types)
        types.max {|val| @tokens[val].first} 
    end

    def construct_nfa
        @nfa = @nfas.shift
        @nfas.each {|n| @nfa.or n}
        @nfas = nil
    end

end
