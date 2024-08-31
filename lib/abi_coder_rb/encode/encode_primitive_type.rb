module AbiCoderRb
  def encode_primitive_type(type, arg, packed = false)
    arg = before_encoding_action.call(type.format, arg) if before_encoding_action
    # 根据类型选择相应的编码方法
    case type
    when Uint
      # NOTE: for now size in  bits always required
      encode_uint(arg, type.bits, packed)
    when Int
      # NOTE: for now size in  bits always required
      encode_int(arg, type.bits, packed)
    when Bool
      encode_bool(arg, packed)
    when String
      encode_string(arg, packed)
    when FixedBytes
      encode_bytes(arg, length: type.length, packed: packed)
    when Bytes
      encode_bytes(arg, packed: packed)
    when Address
      encode_address(arg, packed)
    else
      raise EncodingError, "Unknown type: #{type}"
    end
  end

  def encode_uint(arg, bits, packed = false)
    raise EncodingError, "arg is not integer: #{arg}" unless arg.is_a?(Integer)
    raise ValueOutOfBounds, arg unless arg >= 0 && arg < 2**bits

    packed ? lpad_int(arg, bits / 8) : lpad_int(arg)
  end

  def encode_uint256(arg)
    encode_uint(arg, 256)
  end

  def encode_int(arg, bits, packed = false)
    raise EncodingError, "arg is not integer: #{arg}" unless arg.is_a?(Integer)

    if packed
      hex_to_bin(int_to_abi_signed(arg, bits))
    else
      hex_to_bin(int_to_abi_signed_256bit(arg))
    end
  end

  def encode_bool(arg, packed = false)
    raise EncodingError, "arg is not bool: #{arg}" unless [TrueClass, FalseClass].include?(arg.class)

    if packed
      arg ? BYTE_ONE : BYTE_ZERO
    else
      lpad(arg ? BYTE_ONE : BYTE_ZERO)
    end
  end

  def encode_string(arg, packed = false)
    raise EncodingError, "Expecting string: #{arg}" unless arg.is_a?(::String)

    arg = arg.b if arg.encoding != "BINARY" ## was: name == 'UTF-8', wasm
    raise ValueOutOfBounds, "Integer invalid or out of range: #{arg.size}" if arg.size > UINT_MAX

    packed ? arg : lpad_int(arg.size) + rpad(arg, ceil32(arg.size))
  end

  def encode_bytes(arg, length: nil, packed: false)
    raise EncodingError, "Expecting string: #{arg}" unless arg.is_a?(::String)

    arg = arg.b if arg.encoding != Encoding::BINARY
    if length
      raise ValueOutOfBounds, "invalid bytes length #{arg.size}, should be #{length}" if arg.size > length
      raise ValueOutOfBounds, "invalid bytes length #{length}" if length < 0 || length > 32
      packed ? arg : rpad(arg)
    else
      raise ValueOutOfBounds, "Integer invalid or out of range: #{arg.size}" if arg.size > UINT_MAX
      packed ? arg : lpad_int(arg.size) + rpad(arg, ceil32(arg.size))
    end
  end

  def encode_address(arg, packed = false)
    if arg.is_a?(Integer)
      packed ? lpad_int(arg, 20) : lpad_int(arg)
    elsif arg.is_a?(::String)
      arg = arg.b if arg.encoding != Encoding::BINARY
      case arg.size
      when 20
        packed ? arg : lpad(arg)
      when 40
        packed ? hex_to_bin(arg) : lpad_hex(arg)
      when 42
        arg = arg[2..-1]
        packed ? hex_to_bin(arg) : lpad_hex(arg)
      else
        raise EncodingError, "Could not parse address: #{arg}"
      end
    end
  end
end
