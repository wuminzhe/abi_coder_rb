require_relative "decode/decode_type"
require_relative "decode/decode_types"
require_relative "decode/decode_tuple"
require_relative "decode/decode_fix_array"
require_relative "decode/decode_array"
require_relative "decode/decode_primitive_type"

module AbiCoderRb
  def decode(types, data)
    # Convert types to ABI::Type if they are not already
    types = types.map { |type| type.is_a?(Type) ? type : Type.parse(type) }

    decode_types(types, data)
  end
end
