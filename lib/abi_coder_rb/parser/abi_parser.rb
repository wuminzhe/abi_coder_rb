require_relative 'abi_tokenizer'

class AbiParser
  def initialize(abi)
    @tokenizer = AbiTokenizer.new(abi)
    @current_token = @tokenizer.next_token
  end

  def parse
    parse_element
  end

  private

  def parse_tuple
    elements = []

    expect('(')
    until current_token == ')'
      elements << parse_element
      expect(',') if current_token != ')'
    end
    expect(')')

    { type: 'tuple', elements: elements }
  end

  def parse_element
    if current_token == '('
      parse_tuple
    else
      parse_type
    end
  end

  def parse_type
    base_type = current_token
    @current_token = @tokenizer.next_token

    if current_token == '['
      parse_array(base_type)
    else
      { type: base_type }
    end
  end

  def parse_array(base_type)
    sizes = []

    while current_token == '['
      expect('[')
      size = parse_array_size
      expect(']')
      sizes << size
    end

    { type: base_type, sizes: sizes }
  end

  def parse_array_size
    size_token = current_token
    if size_token&.match?(/\d+/)
      size = size_token.to_i
      @current_token = @tokenizer.next_token
      size
    else
      nil  # Dynamic array if no size specified
    end
  end

  def expect(token)
    raise "Expected #{token}, got #{@current_token}" unless @current_token == token
    @current_token = @tokenizer.next_token
  end

  def current_token
    @current_token
  end
end

# abi1 = "bool"
# abi2 = "string[3]"
# abi3 = "bytes32[3][2]"
# abi4 = "string[]"
# abi5 = "((address,uint256),bool[])"
# abi6 = "(bool[3], (uint256, string[]))"
#
# puts "parsing abi1: #{abi1}"
# parser1 = AbiParser.new(abi1)
# puts parser1.parse.inspect  # => {:type=>"bool"}
#
# puts "\nparsing abi2: #{abi2}"
# parser2 = AbiParser.new(abi2)
# puts parser2.parse.inspect  # => {:type=>"string", :sizes=>[3]}
#
# puts "\nparsing abi3: #{abi3}"
# parser3 = AbiParser.new(abi3)
# puts parser3.parse.inspect  # => {:type=>"bytes32", :sizes=>[3, 2]}
#
# puts "\nparsing abi4: #{abi4}"
# parser4 = AbiParser.new(abi4)
# puts parser4.parse.inspect  # => {:type=>"string", :sizes=>[nil]}
#
# puts "\nparsing abi5: #{abi5}"
# parser5 = AbiParser.new(abi5)
# puts parser5.parse.inspect  # => {:type=>"tuple", :elements=>[{:type=>"tuple", :elements=>[{:type=>"address"}, {:type=>"uint256"}]}, {:type=>"bool", :sizes=>[nil]}]}
#
# puts "\nparsing abi6: #{abi6}"
# parser6 = AbiParser.new(abi6)
# puts parser6.parse.inspect  # => {:type=>"tuple", :elements=>[{:type=>"bool", :sizes=>[3]}, {:type=>"tuple", :elements=>[{:type=>"uint256"}, {:type=>"string", :sizes=>[nil]}]}]}
