require_relative "decode_type"
require_relative "decode_types"
require_relative "decode_tuple"
require_relative "decode_fix_array"
require_relative "decode_array"
require_relative "decode_primitive_type"

module AbiCoderRb
  def decode(types, data)
    # Convert types to ABI::Type if they are not already
    types = types.map { |type| type.is_a?(Type) ? type : Type.parse(type) }

    decode_types(types, data)
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
