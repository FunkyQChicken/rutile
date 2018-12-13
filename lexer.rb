
class Token 
    def initialize(type, string)
        if @type == [:transition_state]
            throw Exception.new("Malformed token: #{string}")
        end
        type.delete :transition_state
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
    end

    def parse()
        @fsm.reset
        Enumerator.new do |out|
            char = nil
            string = ""
            recovery_string = ""
            return_val = @fsm.val
            buffer = []
            while @curr_file
                # reached the end of the file
                if (@curr_file.eof && buffer.empty?)
                    rev_stack
                    ret = Token.new(return_val, string)
                    @fsm.reset
                    string = ""
                    out << ret
                else
                    # advance the scanner
                    if buffer.empty?
                        char = @curr_file.readchar
                    else
                        char = buffer.pop
                    end
                    temp_val = @fsm.feed char
                    if (temp_val == [] && return_val == [])
                        throw "unexpected char '#{char}' following string '#{string}'"
                    end
                end

                # hit a match
                if (temp_val == [] && return_val != [])
                    ret = Token.new(return_val, string)
                    string = ""
                    recovery_string += char
                    buffer = recovery_string.chars + buffer                        
                    return_val = []
                    out << ret
                    @fsm.reset
                    next
                elsif (temp_val == :transition_state)
                    recovery_string += char
                elsif (temp_val != [])
                    recovery_string = ""
                    return_val = temp_val
                end

                # extend the match string
                string += char
            end
        end
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
    def inc_stack(new_file)
        @next_files.append(new_file)
        @file_stack.append(@curr_file)
        rev_stack
    end

end


