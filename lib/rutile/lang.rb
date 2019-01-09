require_relative "./nfa.rb"
require_relative "./lexer.rb"

module Rutile
    class Lang
        def initialize
            @tokens = []
            @nfas = []
            @symbols = []
            @id = 0
            @nfa = nil
        end
    
        # add a new token to the language
        #
        # regex:  regular expression for the token
        # symbol: name of the token when passed to parser
        # block:  process the match into a value and return it
        def tok(regex, symbol = :ignore, &block)
            if block.nil?
                block = Proc.new {|x|}
            end
            new_nfa = NFA::to_nfa(regex, @id)
            @symbols << symbol
            @nfas << new_nfa
            @tokens.append(block)
            @id += 1
        end
        
        # parse the given files
        #
        # files: list of file names and objects to be parsed in the given order
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
    
        # add a file to be parsed by the language
        # can be called mid-parse for things like imports
        #
        # file: file object or path to be parsed
        # back: if true, add the file to the end of the list of files to be parsed
        #       else, pause parsing of current file and start this one
        def add_file(file, back = false)
            if back
                @parser.file_stack.unshift file
            else
                @parser.inc_stack file
            end
        end
    
        # generic run function for the language.
        # parse files passed as arguments
        # if none are passed, read from stdin.
        #
        # files: list of file objects or paths to be parsed
        #        if it is "[]" then it will be set to stdin
        #        before parsing.
        def run(files = ARGV)
            if files.nil? || files == []
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
end
