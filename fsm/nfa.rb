require "./fsm.rb"

def NFA
    def initialize
        super()
    end

    def add(regex, symbol)
        
    end

    def to_dfa
       states = {}

    end
end

def add(regex_raw, symbol)
    regex_raw = regex_raw.chars.reverse
    regex = []
    brackets = false
    while (!regex_raw.empty?)
        char = regex_raw.pop
        if brackets
            case char
            when "]"
                regex << :clb
                brackets = false
            when "\\"
                regex << regex_raw.pop
            else
                regex << char
            end
        else
            case char
            when "."
                regex << :dot
            when "("
                regex << :opp
            when ")"
                regex << :opc
            when "*"
                regex << :ast
            when "+"
                regex << :plu
            when "["
                brackets = true
                regex << :opb
            when "|"
                regex << :pip
            when "\\"
                regex << regex_raw.pop
            else
                regex << char
            end
        end
    end
    p regex
end

