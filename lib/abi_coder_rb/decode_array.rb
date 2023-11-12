module AbiCoderRb
  class Decoder
    def decode_array(type, data)
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
    end
  end
end
