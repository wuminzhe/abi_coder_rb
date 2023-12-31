require_relative "encode/encode_tuple"
require_relative "encode/encode_fixed_array"
require_relative "encode/encode_array"
require_relative "encode/encode_primitive_type"

module AbiCoderRb
  # returns byte array
  def encode(type, value)
    # TODO: more checks?
    raise EncodingError, "Value can not be nil" if value.nil?

    parsed = Type.parse(type)
    encode_type(parsed, value)
  end

  private

  def encode_type(type, value)
    if type.is_a?(Tuple)
      encode_tuple(type, value)
    elsif type.is_a?(Array)
      encode_array(type, value)
    elsif type.is_a?(FixedArray)
      encode_fixed_array(type, value)
    else
      encode_primitive_type(type, value)
    end
  end
end
