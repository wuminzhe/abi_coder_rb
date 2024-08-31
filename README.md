# AbiCoderRb

This is a ruby implementation of the Ethereum ABI codec. It passes all the codec tests in [web3.js].

## Why I write this gem

Originally, I just wanted to gain a deeper understanding of the Ethereum ABI codec by studying this [code](https://github.com/rubycocos/blockchain/tree/8885cc1f6e3ff5c3f1a42809499b1641aa78f171/abicoder). 

When I read the code, I found that the code is not easy to read and understand. So I decided to rewrite it. This gem is the result.

## Features

1. Clear files and code structure.
2. Use string to describe any abi type. This is for compatibility with other abi libs.
3. Pre- encoding and post- decoding callbacks to facilitate transforming data before encoding and after decoding. See [1](https://github.com/wuminzhe/abi_coder_rb/blob/main/spec/transform_before_encode_spec.rb#L4C1-L12C4) [2](https://github.com/wuminzhe/abi_coder_rb/blob/main/spec/web3_js_abitests_spec.rb#L27C1-L49C4)
4. Passed all web3.js tests in [encodeDecodeParams.test.ts](https://github.com/web3/web3.js/blob/c490c1814da646a83c6a5f7fee643e35507c9344/packages/web3-eth-abi/test/unit/encodeDecodeParams.test.ts). That is about 1024 unit tests from fixture [abitestsdata.json](https://github.com/web3/web3.js/blob/c490c1814da646a83c6a5f7fee643e35507c9344/packages/web3-eth-abi/test/fixtures/abitestsdata.json).
5. support packed encoding similar to `abi.encodePacked`. See [test](./spec/packed_encoding_spec.rb)
6. Clear and robust ABI parser which parses the ABI string to an AST tree. See [abi_parser](lib/abi_coder_rb/parser/abi_parser.rb)
7. Can be compiled to wasm. Try it online: https://wuminzhe.github.io/abi.html

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add abi_coder_rb

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install abi_coder_rb

## Usage

### Way 1: extend AbiCoderRb

```ruby
require 'abi_coder_rb'

module ABI
  extend AbiCoderRb
end

type = "(bytes4)"
value = ["\x124Vx"] # or ABI.hex "0x12345678"
data = ABI.hex "1234567800000000000000000000000000000000000000000000000000000000"
ABI.decode(type, data) == value # => true
ABI.encode(type, value) == data # => true
```

You can transform the value according to the type before encoding it. For example, you can convert the hex string to bytes before encoding it. Here is same example but the value for "bytes4" is a hex string. 
```ruby
require 'abi_coder_rb'

module ABI
  extend AbiCoderRb

  before_encoding ->(type, value) { 
    if type.start_with?("bytes")
      hex(value)
    else
      value
    end
  }
end

type = "(bytes4)"
value = ["0x12345678"]
data = ABI.hex "1234567800000000000000000000000000000000000000000000000000000000"
ABI.encode(type, value) == data # => true
```

### Way 2: include AbiCoderRb
```ruby
class Hello
  include AbiCoderRb

  def world
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "000000000000000000000000000000000000000000000000000000000000000b" \
               "48656c6c6f20576f726c64000000000000000000000000000000000000000000"
    decode("(string)", data)
  end
end

Hello.new.world # => ["Hello World"]
```

### Encode packed

```ruby
# encodePacked
type = "int64"
value = 17

encode(type, value, true) # => "0x0000000000000011"
```

### Encode values one by one

It is similar to `abi.encode(v1, v2, ..)` or `abi.encodePacked(v1, v2, ..)` in solidity.

```ruby
types = ["int32", "uint64"]
values = [17, 17]

# abi.encode(v1, v2)
encode(types, values) # => "0x00000000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000011"

# abi.encodePacked(v1, v2)
encode(types, values, true) # => "0x000000110000000000000011"
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wuminzhe/abi_coder_rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/abi_coder_rb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AbiCoderRb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/abi_coder_rb/blob/main/CODE_OF_CONDUCT.md).
