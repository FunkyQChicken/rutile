require "./fsm/fsm.rb"

class DFA < FSM
    def initialize(fsm)
        if fsm
            @start = fsm 
        else
            super()
        end
        @curr  = @start
    end 
    
    def feed(char)
        @curr = @curr.next(char)
        if @curr == nil
            @curr = @start
        else
            @curr = @curr.first
        end
    end 
    
    def val
        return @curr.value
    end 
end
