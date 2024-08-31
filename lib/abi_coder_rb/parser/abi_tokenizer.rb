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

    def peek_token
      original_index = @index
      token = next_token
      @index = original_index
      token
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