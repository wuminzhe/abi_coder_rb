module AbiCoderRb
  def encode_primitive_type(type, arg)
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

  def encode_int(arg, bits)
    ## raise EncodingError or ArgumentError - why? why not?
    raise ArgumentError, "arg is not integer: #{arg}" unless arg.is_a?(Integer)
    raise ValueOutOfBounds, arg unless arg >= -2**(bits - 1) && arg < 2**(bits - 1)

    lpad_int(arg % 2**bits)
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

    arg = hex_to_bin(arg) if hex?(arg)
    arg = arg.b if arg.encoding != Encoding::BINARY

    if length # fixed length type
      raise ValueOutOfBounds, "invalid bytes length #{length}" if arg.size > length
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

  private

  ###########
  #  encoding helpers / utils
  #    with "hard-coded" fill symbol as BYTE_ZERO

  def rpad(bin, l = 32) ## note: same as builtin String#ljust !!!
    # note: default l word is 32 bytes
    return bin if bin.size >= l

    bin + BYTE_ZERO * (l - bin.size)
  end

  ## rename to lpad32 or such - why? why not?
  def lpad(bin) ## note: same as builtin String#rjust !!!
    l = 32 # NOTE: default l word is 32 bytes
    return bin  if bin.size >= l

    BYTE_ZERO * (l - bin.size) + bin
  end

  ## rename to lpad32_int or such - why? why not?
  def lpad_int(n)
    raise ArgumentError, "Integer invalid or out of range: #{n}" unless n.is_a?(Integer) && n >= 0 && n <= UINT_MAX

    hex = n.to_s(16)
    hex = "0#{hex}" if hex.length.odd? # wasm, no .odd
    bin = hex_to_bin(hex)

    lpad(bin)
  end

  ## rename to lpad32_hex or such - why? why not?
  def lpad_hex(hex)
    raise TypeError, "Value must be a string" unless hex.is_a?(::String)
    raise TypeError, "Non-hexadecimal digit found" unless hex =~ /\A[0-9a-fA-F]*\z/

    bin = hex_to_bin(hex)

    lpad(bin)
  end

  def ceil32(x)
    x % 32 == 0 ? x : (x + 32 - x % 32)
  end
end
