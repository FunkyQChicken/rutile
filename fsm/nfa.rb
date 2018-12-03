require "./fsm.rb"
require "./dfa.rb"

def NFA
    def initialize
        super()
    end

    def add(regex, symbol)
        
    end

    def to_dfa
        states = {}
        start = Node::e_closure(@start)
        to_visit = [start]
        states[start] = Node.new(nil)
        

        while !to_visit.empty?
            visiting = to_visit.pop
            curr = states[visiting]
            Node::transitions(visiting).each do |char|
                next_set = Node::e_closure(Node::move(visiting, char))
                next_node = states[next_set]
                if !next_node
                    next_node = Node.new(:transition_state)
                    states[next_set] = next_node
                    to_visit << next_set
                end
                curr.add(char, next_node)
            end
        end

        return DFA.new(start) 
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

