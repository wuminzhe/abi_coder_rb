module AbiCoderRb
  module Utils
    class << self
      def hex_to_bin(hex)
        hex = hex[2..] if %w[0x 0X].include?(hex[0, 2]) ## cut-of leading 0x or 0X if present
        hex.scan(/../).map { |x| x.hex.chr }.join
      end

      def bin_to_hex(bin)
        bin.each_byte.map { |byte| "%02x" % byte }.join
      end

      def hex?(str)
        str.start_with?("0x") && str.length.even? && str[2..].match?(/\A\b[0-9a-fA-F]+\b\z/)
      end

      # example:
      #   lpad("hello", 'x', 10) => "xxxxxxhello"
      def lpad(str, sym, len)
        return str if str.size >= len

        sym * (len - str.size) + str
      end

      def zpad(str, len)
        lpad str, BYTE_ZERO, len
      end

      def ffpad(str, len)
        lpad str, BYTE_FF, len
      end

      def uint_to_big_endian(num, size)
        raise "Can only serialize integers" unless num.is_a?(Integer)
        raise "Cannot serialize negative integers" if num.negative?
        raise "Integer too large (does not fit in #{size} bytes)" if size && num >= 256**size

        # Convert num into a binary string
        s = if num.zero?
              BYTE_EMPTY
            else
              hex = num.to_s(16)
              hex = "0#{hex}" if hex.size.odd?
              hex_to_bin hex
            end

        # Adjust the size of the binary string to match the specified `size` in bytes, if `size` is given.
        s = size ? "#{BYTE_ZERO * [0, size - s.size].max}#{s}" : s

        zpad s, size
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

      def int_to_abi_signed(value)
        # 确保值在32位有符号整数范围内
        raise "Value out of range" if value < -2**31 || value > 2**31 - 1

        # 转换为32位有符号整数的二进制表示，然后转换为十六进制
        hex_str = [value].pack("l>").unpack1("H*")

        # 如果是正数，补齐前导零以达到64位长度
        # 如果是负数，pack方法会产生正确的补码形式，但需要确保长度为64位
        if value >= 0
          hex_str.rjust(64, "0")
        else
          hex_str.rjust(64, "f")
        end
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
  end
end
