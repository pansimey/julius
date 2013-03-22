# Julius [![Build Status](https://travis-ci.org/hadzimme/julius.png)](https://travis-ci.org/hadzimme/julius)

Get results from module mode Julius.

## Installation

Add this line to your application's Gemfile:

    gem 'julius'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install julius

## Usage

```ruby
require 'julius'

julius = Julius.new
julius.each_message do |message, prompt|
  prompt.terminate
  case message.name
  when :RECOGOUT
    puts message.sentence
  end
  prompt.resume
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
