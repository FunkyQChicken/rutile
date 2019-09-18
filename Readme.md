# Rutile
This is an attempt to make an arbitrary language interpreter in ruby.
Currently under heavy developement.

## Plan
There are many different layers needed to complete this project,  
* Tokenizer  
* Semantic Analyzer  
* AST Constructor  
* etc  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rutile'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rutile

## Usage

### Tokenizer
The tokenizer allows pattern matching via regex and code execution
on the matched strings. code for a language that adds up all ints fed to it
would look like so:

```ruby
# create a new language, 'l'
l = Rutile::Lang.new

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`
, which will create a git tag for the version,push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FunkyQChicken/rutile.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
