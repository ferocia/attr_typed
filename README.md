# AttrTyped

A way to add strong typing support to your ruby attributes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attr_typed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attr_typed

## Usage

Include the `AttrTyped` module in your class then declare your types like this:

```
  attr_typed name: :string,
             amount: :money,
             created_at: :time

```

The currently supported types are:

```
:string, :money, :time, :big_decimal, :date, :integer, :boolean, :date_time
```

The parsing behaves in a very predictable way, the only exception is when
parsing a string of `"y"` (i.e. yes) to a boolean it will be true.

If you want to log parsing failures, use `AttrTyped.logger = MyLogger`.

If you want to use `:time` parsing you need to use `ActiveSupport` and have a
default time zone setup.

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ferocia/attr_typed.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

