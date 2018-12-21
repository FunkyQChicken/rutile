module Rutile
    class NFA
        class Node
            attr_accessor :value, :pos, :on_stack, :not, :edges, :default
            def initialize(pos)
                @pos = pos
                @edges = {}
                @value = :transition_state
                @on_stack = false
                @default = nil
            end
    
            def next(char)
                ret = @edges[char]
                return @default if !@default.nil? && ret.nil?
                return  ret ? ret : []
            end
    
            def add(char, pos)
                if @edges[char] == nil
                    @edges[char] = []
                end
                @edges[char] << pos
            end
    
            def empty(char)
                @edges[char] = []
            end
    
            def update_pos(offset)
                @edges.keys.each do |k|
                    @edges[k] = @edges[k].map {|n| (n == :not) ? :not : n + offset}.to_a
                end
                @pos += offset
                @default = @default.map {|x| x + offset} if @default
            end
    
            def set_not(pos)
                @default = pos
            end
    
    
            def dup
                dupl = Node.new @pos 
    
                dupl.value = @value
                dupl.default = @default
                dupl.on_stack = @on_stack
                dupl.edges = Marshal.load(Marshal.dump(@edges))
    
                return dupl
            end
    
            def mark
                @on_stack = true
            end
    
            def unmark
                @on_stack = false
            end
    
            def marked?
                @on_stack
            end
        end
        
        attr_accessor :nodes, :start, :end, :new_stack, :old_stack
    
        def initialize(str = [], opp = false, value = :transition_state, dummy: false)
            if !(dummy)
                @nodes = Array.new(2) {|x| Node.new x }
                @start = @nodes.first.pos
                @end = @nodes.last.pos
    
                val = opp ? :not : @end
    
                if opp
                    @nodes[@start].set_not [@end]
                end
                
                str.each do |char|
                    if char == :dot
                        throw Exception.new ("can't be not AND dot.") if val == :not
                        @nodes[@start].set_not([val])
                        @nodes[@start].empty("\n")
                    else
                        @nodes[@start].add(char, val)
                    end
                end
            end
    
            @new_stack = []
            @old_stack = []
        end
    
        def feed(char)
            move(char)
            finalize
            return val
        end
    
        def reset
            @new_stack = []
            @old_stack = []
            e_closure(@start)
            finalize
            return val
        end
    
        def and a
            a.nodes.each {|node| node.update_pos @nodes.size}
            @nodes[@end].add("", a.start + @nodes.size)
            @end = a.end + @nodes.size
            @nodes += a.nodes
        end
    
        def or a
            total_size = a.nodes.size + @nodes.size
            new_start = Node.new(total_size)
            new_end = Node.new(total_size + 1)
    
            a.nodes.each {|node| node.update_pos @nodes.size}
    
            new_start.add("",@start)
            new_start.add("",a.start + @nodes.size)
    
            @nodes[@end].add("", new_end.pos)
            a.nodes[a.end].add("", new_end.pos)
    
            @nodes += a.nodes
            @nodes += [new_start, new_end]
    
    
            @start = new_start.pos
            @end   = new_end.pos
        end
    
        def asterix
            @nodes[@end].add("", @start)
            @nodes[@start].add("", @end)
        end 
    
        def question
            @nodes[@start].add("", @end)
        end
    
        def plus
            clone = self.dup
            clone.asterix
            self.and(clone)
        end
    
        def dup
            dupl = NFA.new(dummy: true)
    
            dupl.nodes = (@nodes.map {|node| node.dup}).to_a
            dupl.start = @start
            dupl.end   = @end
    
            return dupl
        end
    
        def set_val value
            @nodes[@end].value = value
        end
    
    
        def val
            return @old_stack.map do |ind| 
                @nodes[ind].value
            end.to_a.uniq
        end
    
        private
        
        def e_closure(ind)
            return if @nodes[ind].marked?
            @new_stack << ind
            node = @nodes[ind]
            node.mark
            node.next("").each do |edge|
                e_closure(edge)
            end
        end
    
        def move(char)
            @old_stack.each do |ind|
                @nodes[ind].next(char).each do |edge|
                    if !@nodes[edge].marked? 
                        e_closure(edge)
                    end
                end
            end
            @old_stack = []
        end
    
        def finalize
            @new_stack.each do |ind|
                @nodes[ind].unmark
                old_stack << ind
            end
            @new_stack = []
        end
    
        public
        def self::to_nfa(regex_raw, value)
            regex_raw = regex_raw.chars
            regex = []
            brackets = false
            while (!regex_raw.empty?)
                char = regex_raw.shift
                if brackets
                    case char
                    when "]"
                        regex << :clb
                        brackets = false
                    when "\\"
                        ch = regex_raw.shift
                        case ch
                        when 'd'
                            regex += "1234567890".chars
                        when 'a'
                            regex += "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".chars
                        when 'w'
                            regex += " \t".chars
                        else
                            regex << ch
                        end
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
                        regex << :clp
                    when "*"
                        regex << :ast
                    when "+"
                        regex << :plu
                    when "?"
                        regex << :que
                    when "["
                        brackets = true
                        regex << :opb
                    when "|"
                        regex << :pip
                    when "\\"
                        regex << regex_raw.shift
                    else
                        regex << char
                    end
                end
            end
    
            ret = create_nfa(regex)
    
            if (regex != [])
                throw Exception.new "malformed regex."
            end
    
            ret.set_val value
    
            return ret
        end
        
        private
        def self::create_nfa(regex)
            ret = NFA.new([""])
            while !regex.empty?
                case regex.first
    
                # parens first
                when :opp
                    sub_regex = []
                    count = 1
                    regex.shift
                    while count > 0
                        curr = regex.shift
                        if curr.nil?
                            throw Exception.new "malformed regex: unmatched parenthases"
                        end
                        if curr == :opp
                            count += 1
                        elsif curr == :clp
                            count -= 1
                        end
                        sub_regex.append(curr)
                    end
                    sub_regex.pop
                    ret.and create_nfa(sub_regex)
    
                # brackets
                when :opb
                    chars = []
                    regex.shift
                    opp = (regex.first == :not)
                    regex.shift if opp
    
                    while ((curr = regex.shift) != :clb)
                        chars.append(curr)
                    end
    
                    segment = NFA.new(chars, opp)
    
                    case (ch = regex.shift)
                    when :plu
                        segment.plus
                    when :que
                        segment.question
                    when :ast
                        segment.asterix
                    else
                        regex.unshift ch
                    end
                    
                    ret.and segment
    
                # or
                when :pip
                    regex.shift
                    ret.or create_nfa(regex)
                    break
    
                # lastly asterix plus and question
                when :ast
                    regex.shift
                    ret.asterix
    
                when :plu
                    regex.shift
                    ret.plus
    
                when :que
                    regex.shift
                    ret.question
                 
                # otherwise it is just a char
                else
                    char = NFA.new([regex.shift]) 
    
                    case x = regex.shift 
                    when :plu
                        char.plus
                    when :ast
                        char.asterix
                    when nil
                    else
                        regex.unshift x
                    end
                    ret.and char
                end
            end
            return ret
        end
    end
end
