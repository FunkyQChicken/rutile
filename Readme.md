# RubyParser
This is an attempt to make an arbitrary language compiler in ruby.
Currently under heavy developement.

## Plan
There are many different layers needed to complete this project,
* Tokenizer  
* Semantic Analyzer  
* AST Constructor  
* etc  

Everything as it is built will be intigrated to the lang.rb file
Currently the only major completed part is the Tokenizer.

## Tokenizer
The tokenizer allows pattern matching via regex and code execution
on the matched strings. code for a language that adds up all ints fed to it
would look like so:
```ruby
# create a new language, 'l'
l = Lang.new

# keep a running total of numbers
@total = 0

# match the regex "-?[\d]+" and give it the label ':number'
l.tok("-?[\d]+", :number) do |x|
    # upon match, parse it to an int and add it to the total
    @total += x.to_i
end


# match the regex "[\n \t]" and give it the label ':whitespace'
l.tok("[\n \t]", :whitespace) do |x|
    # don't do anything for whitespace
end

# parse the file "input_file"
l.parse(["input_file"])

# print out the result
puts @total
```

