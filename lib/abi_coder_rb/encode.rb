require_relative "encode/encode_tuple"
require_relative "encode/encode_fixed_array"
require_relative "encode/encode_array"
require_relative "encode/encode_primitive_type"

module AbiCoderRb
  # returns byte array
  def encode(typestr_or_typestrs, value_or_values, packed = false)
    if typestr_or_typestrs.is_a?(::Array)
      raise EncodingError, "values should be an array" unless value_or_values.is_a?(::Array)

      typestrs = typestr_or_typestrs
      values = value_or_values
      typestrs.map.with_index do |typestr, i|
        value = values[i]
        encode(typestr, value, packed)
      end.join
    else
      typestr = typestr_or_typestrs
      value = value_or_values
      # TODO: more checks?
      raise EncodingError, "Value can not be nil" if value.nil?

      parsed = Type.parse(typestr)
      encode_type(parsed, value, packed)
    end
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
