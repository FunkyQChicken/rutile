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
        if (str == nil)
            @default = node
            return
        end

        if (str == "")
            str = [""]  
        else
            str = str.chars
        end

        str.each do |char|
            if @edges[char] == nil
                @edges[char] =  []
            end
            @edges[char] << node
        end
    end

    def remove(str)
        if (str == nil)
            @default = nil
            return
        end

        if (str == "")
            str = [""]  
        else
            str = str.chars
        end
        
        str.each do |char|
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
        if str == ""
            str = [""]
        else
            str = str.chars
        end

        ret = Set.new
        if (str == nil) 
            return Set.new(nodes.map {|node| node.default})
        end
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

    def Node::transitions(nodes)
        ret =  Set.new(
            (nodes.map {|n| n.edges.keys}).flatten
        ).delete ""
        if nodes.any? {|n| n.default}
            ret.add(nil)
        end
        return ret
    end

    def Node::state_name(nodes)
        syms = Set.new(nodes.map {|n| n.value})
        if syms.contains? nil
            return nil
        end
        syms.delete :transition_state
        if syms.size > 1
            throw "ehh, error, don't want to deal with this...."
        end
        return syms.first
end 



