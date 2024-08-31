module AbiCoderRb
  def decode_primitive_type(type, data)
    result =
      case type
      when Uint
        decode_uint256(data[0, 32])
      when Int
        abi_to_int_signed(bin_to_hex(data[0, 32]), type.bits)
      when Bool
        data[31] == BYTE_ONE
      when String
        size = decode_uint256(data[0, 32])
        data[32...(32 + size)].force_encoding("UTF-8")
      when Bytes
        size = decode_uint256(data[0, 32])
        data[32...(32 + size)]
      when FixedBytes
        data[0, type.length]
      when Address
        bin_to_hex(data[12...32]).force_encoding("UTF-8")
      else
        raise DecodingError, "Unknown primitive type: #{type.class.name} #{type.format}"
      end

    result = after_decoding_action.call(type.format, result) if after_decoding_action

    result
  end

  private

  def decode_uint256(bin)
    bin_to_hex(bin).to_i(16)
  end
end
