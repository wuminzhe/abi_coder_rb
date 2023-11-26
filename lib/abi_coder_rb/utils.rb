module AbiCoderRb
  def hex_to_bin(hex)
    hex = hex[2..] if %w[0x 0X].include?(hex[0, 2]) ## cut-of leading 0x or 0X if present
    hex.scan(/../).map { |x| x.hex.chr }.join
  end
  alias hex hex_to_bin

  def bin_to_hex(bin)
    bin.each_byte.map { |byte| "%02x" % byte }.join
  end

  def hex?(str)
    str.start_with?("0x") && str.length.even? && str[2..].match?(/\A\b[0-9a-fA-F]+\b\z/)
  end

  ###########
  #  encoding helpers / utils
  #    with "hard-coded" fill symbol as BYTE_ZERO

  def rpad(bin, l = 32) ## note: same as builtin String#ljust !!!
    # note: default l word is 32 bytes
    return bin if bin.size >= l

    bin + BYTE_ZERO * (l - bin.size)
  end

  ## rename to lpad32 or such - why? why not?
  # example:
  # lpad("hello", 'x', 10) => "xxxxxxhello"
  def lpad(bin) ## note: same as builtin String#rjust !!!
    l = 32 # NOTE: default l word is 32 bytes
    return bin  if bin.size >= l

    BYTE_ZERO * (l - bin.size) + bin
  end

  ## rename to lpad32_int or such - why? why not?
  def lpad_int(n)
    unless n.is_a?(Integer) && n >= 0 && n <= UINT_MAX
      raise ArgumentError,
            "Integer invalid or out of range: #{n}"
    end

    hex = n.to_s(16)
    hex = "0#{hex}" if hex.length.odd? # wasm, no .odd?
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

  def int_to_abi_signed_256bit(value)
    # 确保值在256位有符号整数范围内
    min = -2**255
    max = 2**255 - 1
    raise "Value out of range" if value < min || value > max

    # 为负数计算补码
    value = (1 << 256) + value if value < 0

    # 转换为十六进制字符串
    hex_str = value.to_s(16)

    # 确保字符串长度为64字符（256位）
    hex_str.rjust(64, "0")
  end

  def abi_to_int_signed(hex_str, bits)
    hex_str = "0x#{hex_str}" if hex_str[0, 2] != "0x" || hex_str[0, 2] != "0X"

    # 计算预期的十六进制字符串长度
    expected_length = bits / 4
    extended_hex_str = if hex_str.length < expected_length
                         # 如果输入长度小于预期，根据首位字符扩展字符串
                         extend_char = hex_str[0] == "f" ? "f" : "0"
                         extend_char * (expected_length - hex_str.length) + hex_str
                       else
                         hex_str
                       end

    # 将十六进制字符串转换为二进制字符串
    binary_str = extended_hex_str.to_i(16).to_s(2).rjust(bits, extended_hex_str[0])

    # 检查符号位并转换为整数
    if binary_str[0] == "1" # 负数
      # 取反加一以计算补码，然后转换为负数
      -((binary_str.tr("01", "10").to_i(2) + 1) & ((1 << bits) - 1))
    else # 正数
      binary_str.to_i(2)
    end
  end
end
