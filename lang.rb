require_relative "./nfa.rb"
require_relative "./lexer.rb"

class Lang
    def initialize
        @tokens = []
        @nfas = []
        @symbols = []
        @id = 0
        @nfa = nil
    end

    def tok(regex, symbol = :ignore, &block)
        new_nfa = NFA::to_nfa(regex, @id)
        @symbols << symbol
        @nfas << new_nfa
        @tokens.append(block)
        @id += 1
    end

    def parse(files)
        construct_nfa if @nfa.nil?
        @parser = Parser.new(@nfa, files)
        @parser.parse.each do |token|
            id     = token.type.min
            value  = @tokens[id].call(token.string)
            symbol = @symbols[id]
            if symbol != :ignore
                #feed it to the grammar thing
            end
        end
    end

    def add_file(file, back = false)
        if back
            @parser.file_stack.unshift file
        else
            @parser.inc_stack file
        end
    end

    def run
        files = ARGV
        if files.nil?
            files = [STDIN]
        end
        parse files
    end

    private
    
    def construct_nfa
        @nfa = @nfas.shift
        @nfas.each {|n| @nfa.or n}
        @nfas = nil
    end

end
