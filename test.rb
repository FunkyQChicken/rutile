require "./fsm.rb"
require "./lexer.rb"

fsm = FSM.new(nil)

start = fsm.start
fin   = FSM::Node.new(:aba)
trans = FSM::Node.new(:transition_state)
ign_ws = FSM::Node.new(:whitespace)

start.add("a", fin)
fin  .add("b", trans)
trans.add("a", fin)

#ignore whitespace
start.add("\n", ign_ws)
start.add(" ", ign_ws)
start.add("\t", ign_ws)
ign_ws.add("\n", ign_ws)
ign_ws.add(" ", ign_ws)
ign_ws.add("\t", ign_ws)

parser = Parser.new(fsm, ["aba.test"])
parser.parse.each do |curr|
    p curr
end
