

class FSM
    attr_reader :start
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
                @edges[char] = node
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
    end 

    def initialize(info)
        @start = Node.new(nil)
        @curr  = @start
    end
    
    def feed(char)
        @curr = @curr.next(char)
        if @curr == nil
            @curr = @start
        end
    end

    def val
        return @curr.value
    end
end
