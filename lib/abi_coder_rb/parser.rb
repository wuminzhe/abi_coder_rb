require_relative './parser/abi_parser'

module AbiCoderRb
  class Type
    class ParseError < StandardError; end

    class Parser
      class << self
        def parse(abi_type_str)
          abi_type = AbiCoderRb::AbiParser.new(abi_type_str).parse
          _create(abi_type)
        end

        private
        def _create(abi_type)
          case abi_type[:type]
          when 'string' then String.new
          when 'address' then Address.new
          when 'bool' then Bool.new
          when 'uint' then Uint.new(abi_type[:bits])
          when 'int' then Int.new(abi_type[:bits])
          when 'bytes' then abi_type[:length] ? FixedBytes.new(abi_type[:length]) : Bytes.new
          when 'tuple' then Tuple.new(abi_type[:inner_types].map { |t| _create(t) })
          when 'array'
            abi_type[:length] ?
              FixedArray.new(_create(abi_type[:inner_type]), abi_type[:length]) :
              Array.new(_create(abi_type[:inner_type]))
          else
            raise ParseError, "Unknown type: #{abi_type}"
          end
        end
      end
    end
  end
end
