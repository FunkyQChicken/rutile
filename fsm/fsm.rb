class FSM
    attr_reader :start
    def initialize()
        @start = Node.new(nil)
    end
end

class Node
    attr_reader :value
    def initialize(val)
        @value   = val
        @default = nil
        @edges   = {}
    end

    def next(char)
        ret =  @edges[char]
        if ret == nil
            return @default
        else 
            return ret
        end
    end

    def add(str, node) 
        str.chars.each do |char|
            if @edges[char] == nil
                @edges[char] =  []
            end
            @edges[char] << node
        end
    end

    def remove(str)
        str.chars.each do |char|
            @edges[char] = nil
        end
    end

    def set_default(node)
        @default = node
    end

    def Node::e_closure(to_visit)
        to_visit = to_visit.to_a
        visited  = Set.new
        to_visit.each {|x| visited.add x}  
        
        while !to_visit.empty?
            curr = to_visit.pop
            next_nodes = curr.next "" 
            next_nodes.each do |node|
                if visited.add? node
                    to_visit << node
                end
            end
        end

        return visited
    end

    def Node::move(nodes, str)
        str = str.chars
        ret = Set.new

        nodes.each do |node|
            str.each do |char|
                temp = nodes.next char
                if temp 
                    temp.each do |r|
                        ret.add r
                    end
                end
            end
        end

        return ret
    end
end 



