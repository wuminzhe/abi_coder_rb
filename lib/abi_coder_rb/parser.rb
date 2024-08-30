require_relative './parser/abi_parser'

module AbiCoderRb
  class Type
    class ParseError < StandardError; end

    class Parser
      class << self
        def parse(abi_type_str)
          abi_type = AbiCoderRb::AbiParser.new(abi_type_str).parse
          create_type(abi_type)
        end

        private

        def create_type(abi_type)
          case abi_type[:type]
          when 'string' then String.new
          when 'address' then Address.new
          when 'bool' then Bool.new
          when 'uint', 'int' then create_numeric_type(abi_type)
          when 'bytes' then create_bytes_type(abi_type)
          when 'tuple' then create_tuple_type(abi_type)
          when 'array' then create_array_type(abi_type)
          else
            raise ParseError, "Unknown type: #{abi_type}"
          end
        end

        def create_tuple_type(abi_type)
          Tuple.new(abi_type[:inner_types].map { |t| create_type(t) })
        end

        def create_numeric_type(abi_type)
          abi_type[:type] == 'uint' ? Uint.new(abi_type[:bits]) : Int.new(abi_type[:bits])
        end

        def create_bytes_type(abi_type)
          abi_type[:length] ? FixedBytes.new(abi_type[:length]) : Bytes.new
        end

        def create_array_type(abi_type)
          inner_type = create_type(abi_type[:inner_type])
          abi_type[:length] ? FixedArray.new(inner_type, abi_type[:length]) : Array.new(inner_type)
        end
      end
    end
  end
end