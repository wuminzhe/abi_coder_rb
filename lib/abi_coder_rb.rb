# frozen_string_literal: true

require_relative "abi_coder_rb/version"

require_relative "abi_coder_rb/utils"

require_relative "abi_coder_rb/parser"
require_relative "abi_coder_rb/types"
require_relative "abi_coder_rb/decode"
require_relative "abi_coder_rb/encode"

require_relative "periphery/event_decoder"
require_relative "periphery/function_encoder"

module AbiCoderRb
  class DecodingError < StandardError; end
  class EncodingError < StandardError; end
  class ValueError < StandardError; end
  class ValueOutOfBounds < ValueError; end

  BYTE_EMPTY = "".b.freeze
  BYTE_ZERO  = "\x00".b.freeze
  BYTE_ONE   = "\x01".b.freeze ## note: used for encoding bool for now

  UINT_MAX = 2**256 - 1   ## same as 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  UINT_MIN = 0
  INT_MAX  = 2**255 - 1   ## same as  57896044618658097711785492504343953926634992332820282019728792003956564819967
  INT_MIN  = -2**255      ## same as -57896044618658097711785492504343953926634992332820282019728792003956564819968

  attr_accessor :before_encoding_action, :after_decoding_action

  def before_encoding(action)
    self.before_encoding_action = action
  end

  def after_decoding(action)
    self.after_decoding_action = action
  end
end
