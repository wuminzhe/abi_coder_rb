require_relative "decode_tuple"

module AbiCoderRb
  class Decoder
    def decode(types, data)
      decode_tuple(types, data)
    end

    private

    def decode_type(type, data)
      return nil if data.nil? || data.empty?

      if type.is_a?(Tuple) ## todo: support empty (unit) tuple - why? why not?
        decode_tuple(type.types, data)
      elsif type.is_a?(FixedArray) # static-sized arrays
        l = type.dim
        subtype = type.subtype
        if subtype.dynamic?
          start_positions = (0...l).map { |i| decode_uint256(data[32 * i, 32]) }
          start_positions.push(data.size)

          outputs = (0...l).map { |i| data[start_positions[i]...start_positions[i + 1]] }

          outputs.map { |out| decode_type(subtype, out) }
        else
          (0...l).map { |i| decode_type(subtype, data[subtype.size * i, subtype.size]) }
        end
      elsif type.is_a?(Array)
        l = decode_uint256(data[0, 32])
        raise DecodingError, "Too long length: #{l}" if l > 100_000

        subtype = type.subtype

        if subtype.dynamic?
          raise DecodingError, "Not enough data for head" unless data.size >= 32 + 32 * l

          start_positions = (1..l).map { |i| 32 + decode_uint256(data[32 * i, 32]) }
          start_positions.push(data.size)

          outputs = (0...l).map { |i| data[start_positions[i]...start_positions[i + 1]] }

          outputs.map { |out| decode_type(subtype, out) }
        else
          (0...l).map { |i| decode_type(subtype, data[32 + subtype.size * i, subtype.size]) }
        end
      else
        decode_primitive_type(type, data)
      end
    end

    def decode_primitive_type(type, data)
      case type
      when Uint
        decode_uint256(data)
      when Int
        u = decode_uint256(data)
        u >= 2**(type.bits - 1) ? (u - 2**type.bits) : u
      when Bool
        data[-1] == BYTE_ONE
      when String
        data.force_encoding(Encoding::UTF_8)
      when Bytes
        data
      when FixedBytes
        data[0, type.length]
      when Address
        ## note: convert to a hex string (with UTF_8 encoding NOT BINARY!!!)
        data[12..].unpack1("H*").force_encoding(Encoding::UTF_8)
      else
        raise DecodingError, "Unknown primitive type: #{type.class.name} #{type.format}"
      end
    end

    def decode_uint256(bin)
      # bin = bin.sub( /\A(\x00)+/, '' )   ## keep "performance" shortcut - why? why not?
      ### todo/check - allow nil - why? why not?
      ##  raise DeserializationError, "Invalid serialization (not minimal length)" if !@size && serial.size > 0 && serial[0] == BYTE_ZERO
      # bin = bin || BYTE_ZERO
      bin.unpack1("H*").to_i(16)
    end
  end
end
