module AbiCoderRb
  class Decoder
    def decode_primitive_type(type, data)
      case type
      when Uint
        decode_uint256(data[0, 32])
      when Int
        u = decode_uint256(data[0, 32])
        u >= 2**(type.bits - 1) ? (u - 2**type.bits) : u
      when Bool
        data[31] == BYTE_ONE
      when String
        size = decode_uint256(data[0, 32])
        data[32...(32 + size)].force_encoding(Encoding::UTF_8)
      when Bytes
        size = decode_uint256(data[0, 32])
        data[32...(32 + size)]
      when FixedBytes
        data[0, type.length]
      when Address
        ## note: convert to a hex string (with UTF_8 encoding NOT BINARY!!!)
        data[12..].unpack1("H*").force_encoding(Encoding::UTF_8)
      else
        raise DecodingError, "Unknown primitive type: #{type.class.name} #{type.format}"
      end
    end
  end
end
