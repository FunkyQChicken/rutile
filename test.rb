require "./fsm.rb"
require "./lexer.rb"

fsm = FSM.new(nil)
parser = Parser.new(fsm, ["parser","lexer.rb"])
while curr = parser.next
    p curr
end
