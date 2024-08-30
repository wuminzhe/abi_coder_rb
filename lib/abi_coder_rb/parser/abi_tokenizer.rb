module AbiCoderRb
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

      # if the first character is a digit, read the whole number
      if @abi[@index].match?(/\d/)
        while @index < @abi.length && @abi[@index].match?(/\d/)
          @index += 1
        end
      else
        # Move the index until a non-identifier character or digit is found
        while @index < @abi.length && !@abi[@index].match?(/[\(\),\[\]\s\d]/)
          @index += 1
        end
      end
      @abi[start_index...@index]
    end

  end
end

def _print_tokens(abi)
  tokenizer = AbiCoderRb::AbiTokenizer.new(abi)

  tokens = []
  while token = tokenizer.next_token
    tokens << token
  end

  puts tokens.map { |t| "'#{t}'" }.join(", ")
end

abi1 = "bool"
abi2 = "string[3]"
abi3 = "bytes3"
abi4 = "int8"
abi5 = " ( (address,  uint256[ 3]),bool[  ] ) "

puts "tokenizing abi1: '#{abi1}'"
_print_tokens(abi1) # => 'bool'

puts "\ntokenizing abi2: '#{abi2}'"
_print_tokens(abi2) # => 'string', '[', '3', ']'

puts "\ntokenizing abi3: '#{abi3}'"
_print_tokens(abi3) # => 'bytes', '3'

puts "\ntokenizing abi4: '#{abi4}'"
_print_tokens(abi4) # => 'int', '8'

puts "\ntokenizing abi5: '#{abi5}'"
_print_tokens(abi5) # => '(', '(', 'address', ',', 'uint', '256', '[', '3', ']', ')', ',', 'bool', '[', ']', ')'
