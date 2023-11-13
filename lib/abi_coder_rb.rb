# frozen_string_literal: true

require_relative "abi_coder_rb/version"

require_relative "abi_coder_rb/parser"
require_relative "abi_coder_rb/types"
require_relative "abi_coder_rb/decode"

module AbiCoderRb
  class DecodingError < StandardError; end

  ###################
  ### some (shared) constants  (move to constants.rb or such - why? why not?)

  ## todo/check:  use auto-freeze string literals magic comment - why? why not?
  ##
  ## todo/fix: move  BYTE_EMPTY, BYTE_ZERO, BYTE_ONE to upstream to bytes gem
  ##    and make "global" constants - why? why not?

  ## BYTE_EMPTY = "".b.freeze
  BYTE_ZERO  = "\x00".b.freeze
  BYTE_ONE   = "\x01".b.freeze ## note: used for encoding bool for now

  UINT_MAX = 2**256 - 1   ## same as 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  UINT_MIN = 0
  INT_MAX  = 2**255 - 1   ## same as  57896044618658097711785492504343953926634992332820282019728792003956564819967
  INT_MIN  = -2**255      ## same as -57896044618658097711785492504343953926634992332820282019728792003956564819968

  def hex_to_bin(hex) # convert hex(adecimal) string  to binary string
    hex = hex[2..] if %w[0x 0X].include?(hex[0, 2]) ## cut-of leading 0x or 0X if present
    [hex].pack("H*")
  end
  alias hex hex_to_bin

  def bin_to_hex(bin) # convert binary string to hex string
    bin.unpack1("H*")
  end
  alias bin bin_to_hex
end
