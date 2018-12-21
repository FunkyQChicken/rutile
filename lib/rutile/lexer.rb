

module Rutile
    class Parser
        class Token 
            attr_accessor :type, :string
            def initialize(type, string)
                if type == [:transition_state]
                    throw Exception.new("Malformed token: #{string}")
                end
                type.delete :transition_state
                @type = type
                @string = string
            end
        end
        attr_accessor  :file_stack

        def initialize(fsm, files)
            @fsm  = fsm
            @file_stack = []
            @next_files = files.reverse
            @curr_file = nil
            dec_stack
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
                        dec_stack
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
        
        # decrease the file stack 
        def dec_stack()
            @curr_file.close if @curr_file
            file = @next_files.pop
            if (file == nil)
               @curr_file = nil
            elsif file.class == String
                @curr_file = open(file)
            else
                @curr_file = file
            end
        end

        # increase the file stack
        def inc_stack(new_file)
            @file_stack.append(@curr_file)
            if new_file.class == String
                @curr_file = open(file)
            else
                @curr_file = file
            end
        end
    end
end


