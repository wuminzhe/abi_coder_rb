class AbiTokenizer
  def initialize(abi)
    @abi = abi
    @index = 0
  end

  def next_token
    skip_whitespace

    return nil if @index >= @abi.length

    char = @abi[@index]

    case char
    when '(', ')', ',', '[', ']'
      @index += 1
      char
    else
      read_identifier
    end
  end

  private

  def skip_whitespace
    while @index < @abi.length && @abi[@index].match?(/\s/)
      @index += 1
    end
  end

  def read_identifier
    start_index = @index
    while @index < @abi.length && !@abi[@index].match?(/[\(\),\[\]\s]/)
      @index += 1
    end
    @abi[start_index...@index]
  end
end

def _print_tokens(abi)
  tokenizer = AbiTokenizer.new(abi)

  tokens = []
  while token = tokenizer.next_token
    tokens << token
  end

  puts tokens.map { |t| "'#{t}'" }.join(", ")
end

# abi1 = "bool"
# abi2 = "string[3]"
# abi3 = " ( (address,  uint256),bool[  ] ) "
#
# puts "tokenizing abi1: '#{abi1}'"
# _print_tokens(abi1) # => 'bool'
#
# puts "\ntokenizing abi2: '#{abi2}'"
# _print_tokens(abi2) # => 'string', '[', '3', ']'
#
# puts "\ntokenizing abi3: '#{abi3}'"
# _print_tokens(abi3) # => '(', '(', 'address', ',', 'uint256', ')', ',', 'bool', '[', ']', ')'
