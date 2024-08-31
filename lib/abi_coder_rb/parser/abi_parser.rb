require_relative 'abi_tokenizer'

module AbiCoderRb
  class AbiParser
    def initialize(abi)
      @tokenizer = AbiTokenizer.new(abi)
      @current_token = @tokenizer.next_token
    end

    def parse
      element =
        case @current_token
        when "string", "address", "bool" then parse_simple_type
        when "uint", "int" then parse_numeric_type
        when "bytes" then parse_bytes
        when "(" then parse_tuple
        else
          raise ParseError, "Unexpected token: #{@current_token}"
        end

      @current_token == "[" ? parse_array(element) : element
    end

    private

    def parse_bytes
      result =
        if @tokenizer.peek_token =~ /^\d+$/
          @current_token = @tokenizer.next_token
          { type: 'bytes', length: @current_token.to_i }
        else
          { type: 'bytes' }
        end
      @current_token = @tokenizer.next_token
      result
    end

    def parse_numeric_type
      type = @current_token
      result =
        if @tokenizer.peek_token =~ /^\d+$/
          @current_token = @tokenizer.next_token
          { type: type, bits: @current_token.to_i }
        else
          { type: type, bits: 256 }
        end
      @current_token = @tokenizer.next_token
      result
    end

    def parse_simple_type
      type = @current_token
      @current_token = @tokenizer.next_token
      { type: type }
    end

    def parse_tuple
      inner_types = []

      expect("(")
      until @current_token == ")"
        inner_types << parse
        expect(",") if @current_token != ")"
      end
      expect(")")

      { type: "tuple", inner_types: inner_types }
    end

    def parse_array(element)
      arr = { type: 'array', inner_type: element, length: parse_array_length }
      @current_token == "[" ? parse_array(arr) : arr
    end

    def parse_array_length
      expect("[")
      if @current_token == "]"
        length = nil
      elsif @current_token =~ /^\d+$/
        length = @current_token.to_i
        @current_token = @tokenizer.next_token
      else
        raise ParseError, "Expected array length or closing ']'"
      end
      expect("]")

      length
    end

    def expect(token)
      raise "Expected #{token}, got #{@current_token}" unless @current_token == token

      @current_token = @tokenizer.next_token
    end
  end
end