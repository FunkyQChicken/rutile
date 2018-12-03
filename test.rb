require "./fsm/dfa.rb"
require "./lexer.rb"

fsm = DFA.new(nil)

start  = fsm.start
p start
fin    = Node.new(:aba)
trans  = Node.new(:transition_state)
ign_ws = Node.new(:whitespace)

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
