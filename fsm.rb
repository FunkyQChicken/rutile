
class FSM
    
    def initialize(info)
    end

    def feed(char)
        @val = :E if char == "e"
    end

    def val()
        if @val == nil
            return  @val
        else
            temp = @val 
            @val= nil
            return temp
        end
    end

    def reset()
    end

end
