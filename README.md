# AbiCoderRb

modified from https://github.com/rubycocos/blockchain/blob/master/abicoder

for better readability code and deep learning abi codec.

The most significant difference from the original code is that 'data' to decode in every decode_* function is no longer exact but now includes both the data needed for decoding and the remaining data. This change means that in the entry point('AbiCoderRb.decode'), there's no longer a need to calculate the precise data required for decoding for each type. This simplification streamlines the code.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add abi_coder_rb

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install abi_coder_rb

## Usage

See tests

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wuminzhe/abi_coder_rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/abi_coder_rb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AbiCoderRb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/abi_coder_rb/blob/main/CODE_OF_CONDUCT.md).
