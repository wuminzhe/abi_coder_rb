# frozen_string_literal: true

require_relative "abi_coder_rb/version"

require_relative "abi_coder_rb/parser"
require_relative "abi_coder_rb/types"
require_relative "abi_coder_rb/decoder"

module AbiCoderRb
  class DecodingError < StandardError; end
  # Your code goes here...

  class << self
    def hex_to_bin(hex) # convert hex(adecimal) string  to binary string
      hex = hex[2..] if %w[0x 0X].include?(hex[0, 2]) ## cut-of leading 0x or 0X if present
      [hex].pack("H*")
    end

    def bin_to_hex(bin) # convert binary string to hex string
      bin.unpack1("H*")
    end
  end
end
