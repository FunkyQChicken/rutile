
class Token 
    def initialize(type, string)
        @type = type
        @string = string
    end
end

class Parser
    def initialize(fsm, files)
        @fsm  = fsm
        @file_stack = []
        @next_files = files.reverse
        @curr_file  = open(@next_files.pop())

        @char = nil
        @string = ""
    end

    def next()
        return_val  = nil
        while @curr_file
            if (@curr_file.eof)
                rev_stack
                @fsm.reset
                next
            end
            @char = @curr_file.readchar

            @fsm.feed @char
            temp_val = @fsm.val

            if (temp_val == nil && return_val != nil)
                ret = Token.new(return_val, @string)
                @fsm.reset
                @fsm.feed @char
                @string = @char
                return ret
            elsif (temp_val != nil)
                return_val = temp_val
            end
            @string += @char
        end
        return nil
    end

    # revive the stack 
    def rev_stack()
        @curr_file.close
        file = @next_files.pop
        if (file == nil)
           @curr_file = nil
        else
            @curr_file = open(file)
        end
    end

    # decrement the file stack
    def dec_stack()
        if (@file_stack.size == 0)
            rev_stack
        else
            @curr_file.close
            @curr_file = @file_stack.pop 
        end
    end
    
    # increase the file stack
    def inc_stack()
        @file_stack.append(@curr_file)
        rev_stack
    end

end


