# AbiCoderRb

modified from https://github.com/rubycocos/blockchain/blob/master/abicoder

for better readability code and deep learning abi codec.

## Head/Tail mechanism

在 Ethereum 的 ABI（Application Binary Interface）编码中，"head/tail mechanism" 是一种用于编码和解码数据的策略，尤其是在处理包含静态和动态类型数据的复杂结构时。这种机制的核心在于如何安排和访问数据的不同部分，以便能够有效地编码和解码各种类型的数据。

### Head/Tail 机制的工作原理

* 静态类型（Head）

  静态类型的数据（如固定大小的整数、固定长度的字节数组等）直接在数据的头部（head）部分按顺序编码。这些数据的大小是已知且固定的，因此可以直接按顺序存放。

  另外，头部还会放置动态类型数据的指针（动态数据在整个数据中的位置，或者说偏移量）。

* 动态类型（Tail）

  动态类型的数据（如字符串、变长字节数组、数组等）不是直接在头部编码的。头部仅存放一个指针，指向数据实际存储的位置，即“尾部”（tail）。
动态数据的**长度**和**实际内容**被放置在所有静态数据之后，按照它们出现的顺序依次排列。
 
  这里动态数据的长度是，1. 实际内容的数据长度, 2. 在Array时，是元素个数。 

### 例子

假设有一个智能合约函数，它接受以下参数：

1. `uint256 id` - 静态类型
2. `string firstName` - 动态类型
3. `string lastName` - 动态类型

#### 编码过程

1. **静态类型（Head）**:
   - `id` 作为静态类型，直接编码在数据的头部。
2. **动态类型（Head）**:
   - 在头部，`firstName` 和 `lastName` 不会直接存储它们的内容，而是分别存储两个指向它们内容的起始位置的偏移量。
3. **动态类型（Tail）**:
   - 在尾部，按顺序存储 `firstName` 和 `lastName` 的实际内容，包括它们的长度和数据本身。

#### 编码的数据结构示例

假设 `id = 100`，`firstName = "Alice"`，`lastName = "Smith"`，编码后的数据结构可能如下：

- 头部:
  - `id` 的值
  - `firstName` 的偏移量
  - `lastName` 的偏移量
- 尾部:
  - `firstName` 的长度和内容
  - `lastName` 的长度和内容

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
