require_relative "encode/encode_tuple"
require_relative "encode/encode_fixed_array"
require_relative "encode/encode_array"
require_relative "encode/encode_primitive_type"

module AbiCoderRb
  # returns byte array
  def encode(str, value, packed = false)
    return encode_type(Type.parse(str), value, packed) if str.is_a?(::String)

    return str.map.with_index do |type, i|
      encode(type, value[i], packed)
    end.join("") if str.is_a?(::Array) && value.is_a?(::Array) && str.size == value.size

    raise EncodingError, "There is something wrong with #{str.inspect}, #{value.inspect}"
  end

  private

  def encode_type(type, value, packed = false)
    if type.is_a?(Tuple)
      encode_tuple(type, value, packed)
    elsif type.is_a?(Array)
      encode_array(type, value, packed)
    elsif type.is_a?(FixedArray)
      encode_fixed_array(type, value, packed)
    else
      encode_primitive_type(type, value, packed)
    end
  end
end
