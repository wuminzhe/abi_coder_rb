module AbiCoderRb
  def encode_primitive_type(type, arg)
    arg = before_encoding_action.call(type.format, arg) if before_encoding_action
    # 根据类型选择相应的编码方法
    case type
    when Uint
      # NOTE: for now size in  bits always required
      encode_uint(arg, type.bits)
    when Int
      # NOTE: for now size in  bits always required
      encode_int(arg, type.bits)
    when Bool
      encode_bool(arg)
    when String
      encode_string(arg)
    when FixedBytes
      encode_bytes(arg, type.length)
    when Bytes
      encode_bytes(arg)
    when Address
      encode_address(arg)
    else
      raise EncodingError, "Unknown type: #{type}"
    end
  end

  def encode_uint(arg, bits)
    raise ArgumentError, "arg is not integer: #{arg}" unless arg.is_a?(Integer)
    raise ValueOutOfBounds, arg unless arg >= 0 && arg < 2**bits

    lpad_int(arg)
  end

  def encode_uint256(arg)
    encode_uint(arg, 256)
  end

  def encode_int(arg, _bits)
    ## raise EncodingError or ArgumentError - why? why not?
    raise ArgumentError, "arg is not integer: #{arg}" unless arg.is_a?(Integer)

    hex_to_bin(int_to_abi_signed_256bit(arg))
  end

  def encode_bool(arg)
    ## raise EncodingError or ArgumentError - why? why not?
    raise ArgumentError, "arg is not bool: #{arg}" unless arg.is_a?(TrueClass) || arg.is_a?(FalseClass)

    lpad(arg ? BYTE_ONE : BYTE_ZERO) ## was  lpad_int( arg ? 1 : 0 )
  end

  def encode_string(arg)
    ## raise EncodingError or ArgumentError - why? why not?
    raise EncodingError, "Expecting string: #{arg}" unless arg.is_a?(::String)

    arg = arg.b if arg.encoding != "BINARY" ## was: name == 'UTF-8', wasm

    raise ValueOutOfBounds, "Integer invalid or out of range: #{arg.size}" if arg.size > UINT_MAX

    size  =  lpad_int(arg.size)
    value =  rpad(arg, ceil32(arg.size))
    size + value
  end

  def encode_bytes(arg, length = nil)
    ## raise EncodingError or ArgumentError - why? why not?
    raise EncodingError, "Expecting string: #{arg}" unless arg.is_a?(::String)

    arg = arg.b if arg.encoding != Encoding::BINARY

    if length # fixed length type
      raise ValueOutOfBounds, "invalid bytes length #{arg.size}, should be #{length}" if arg.size > length
      raise ValueOutOfBounds, "invalid bytes length #{length}" if length < 0 || length > 32

      rpad(arg)
    else # variable length type  (if length is nil)
      raise ValueOutOfBounds, "Integer invalid or out of range: #{arg.size}" if arg.size > UINT_MAX

      size =  lpad_int(arg.size)
      value = rpad(arg, ceil32(arg.size))
      size + value
    end
  end

  def encode_address(arg)
    if arg.is_a?(Integer)
      lpad_int(arg)
    elsif arg.size == 20
      ## note: make sure encoding is always binary!!!
      arg = arg.b if arg.encoding != Encoding::BINARY
      lpad(arg)
    elsif arg.size == 40
      lpad_hex(arg)
    elsif arg.size == 42 && arg[0, 2] == "0x" ## todo/fix: allow 0X too - why? why not?
      lpad_hex(arg[2..-1])
    else
      raise EncodingError, "Could not parse address: #{arg}"
    end
  end
end
