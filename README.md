# Contextuable
# This gem has been renamed to Dystruct
# the new repo is: https://github.com/arturictus/dystruct

[![Build Status](https://travis-ci.org/ryanfox1985/contextuable.svg?branch=master)](https://travis-ci.org/ryanfox1985/contextuable)
[![Gem Version](https://badge.fury.io/rb/contextuable.svg)](http://badge.fury.io/rb/contextuable)
[![](https://img.shields.io/gem/dt/contextuable.svg?style=flat)](https://rubygems.org/gems/contextuable)
[![Coverage Status](https://coveralls.io/repos/github/ryanfox1985/contextuable/badge.svg?branch=master)](https://coveralls.io/github/ryanfox1985/contextuable?branch=master)
[![Code Climate](https://codeclimate.com/github/arturictus/contextuable/badges/gpa.svg)](https://codeclimate.com/github/arturictus/contextuable)


Better Structs for many applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'contextuable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install contextuable

## Usage

__Extended OpenStruct:__

```ruby
  context = Contextuable.new(name: 'John', surname: 'Doe')
  context.name # => 'John'
  context.name_provided? # => true
  context.surname # => 'Doe'
  context.foo_provided? # => false
  context.foo_not_provided? # => true
  context.foo = :bar
  context.foo_provided? # => true
  context.foo_not_provided? # => false
  context.foo # => :bar
  context.to_h # => {:name=>"John", :surname=>"Doe", :foo=>:bar}
```

_more complex example_
```ruby
class Input < Contextuable
  permit  :name, :city, :address, :phone_number, :free_text, :country_code,
    :country, :zip, :types
  defaults types: ['lodging']
  aliases :name, :hotel_name
  aliases :phone_number, :telephone

  def long_name
    [name, address, city].join(', ')
  end

  def types
    Array.wrap(args[:types])
  end
end

i = Input.new(name: 'Hotel', city: 'Barcelona', address: 'Happy street', not_permitted: 'dangerous')
i.types
# => ["lodging"]
i.long_name
# => "Hotel, Happy street, Barcelona"
i.name
# => "Hotel"
i.hotel_name
# => "Hotel"
i.phone_number_provided?
# => false
i.not_permitted
# => NoMethodError: undefined method
```

### Building better Structs

**no_method_error**
```ruby
class Example < Contextuable
  no_method_error false
end

Example.new(foo: :bar).hello # => nil
```

```ruby
class Example < Contextuable
  no_method_error
end

Example.new(foo: :bar).hello # => => NoMethodError: undefined method
```

**required**
```ruby
class Example < Contextuable
  required :required_arg
end

Example.new(foo: :bar)
#=> Error Contextuable::RequiredFieldNotPresent
```

**aliases**
```ruby
class Example < Contextuable
  aliases :hello, :greeting, :welcome
end
ex = Example.new(hello: 'Hey!')
# => #<Example:0x007fd88ba30398 @args={:hello=>"Hey!"}>
ex.hello
# => "Hey!"
ex.greeting
# => "Hey!"
ex.welcome
# => "Hey!"
```

**defaults**
```ruby
class Example2 < Contextuable
  defaults foo: :bar, bar: :foo
end
ex = Example2.new
ex.foo
# => :bar
ex.bar
# => :foo
ex.foo = :hello
ex.foo
# => :hello

ex2 = Example2.new(foo: 'something', bar: true)
ex2.foo
# => 'something'
ex2.bar
# => true
```

**ensure_presence**
```ruby
class EnsurePresence < Contextuable
  ensure_presence :foo
end
EnsurePresence.new(hello: 'asdf')
#=> Error: Contextuable::PresenceRequired

EnsurePresence.new(foo: nil)
#=> Error: Contextuable::PresenceRequired

EnsurePresence.new(foo: '').foo #=> ""
```

**permit**
```ruby
per = Permit.new(foo: :bar, hello: 'Hey!', bar: 'bla', yuju: 'dangerous')
 => #<Permit:0x007fd88b9dd878 @args={:foo=>:bar, :hello=>"Hey!"}>
per.foo #=> :bar
per.yuju #=> nil
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arturictus/contextuable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
