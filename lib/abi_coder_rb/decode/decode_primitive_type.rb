module AbiCoderRb
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
      data[12...32].unpack1("H*").force_encoding(Encoding::UTF_8)
    else
      raise DecodingError, "Unknown primitive type: #{type.class.name} #{type.format}"
    end
  end

  private

  def decode_uint256(bin)
    # bin = bin.sub( /\A(\x00)+/, '' )   ## keep "performance" shortcut - why? why not?
    ### todo/check - allow nil - why? why not?
    ##  raise DeserializationError, "Invalid serialization (not minimal length)" if !@size && serial.size > 0 && serial[0] == BYTE_ZERO
    # bin = bin || BYTE_ZERO
    bin.unpack1("H*").to_i(16)
  end
end
