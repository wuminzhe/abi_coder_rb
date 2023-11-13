module AbiCoderRb
  # 和原来的代码最不同的地方，data不再是正好的，而是包含了 解码所需的数据 和 剩余的数据。
  # 这样在入口处，也就是decoder.decode 方法中不再需要为每个类型都计算准确的 解码所需的数据。
  # 从而简化了代码。
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
