require_relative "decode/decode_tuple"
require_relative "decode/decode_fixed_array"
require_relative "decode/decode_array"
require_relative "decode/decode_primitive_type"

module AbiCoderRb
  def decode(type_str, data)
    raise DecodingError, "Empty data" if data.nil? || data.empty?

    decode_type(Type.parse(type_str), data)
  end

  private

  def decode_type(type, data)
    case type
    when Tuple ## todo: support empty (unit) tuple - why? why not?
      decode_tuple(type, data)
    when FixedArray # static-sized arrays
      decode_fixed_array(type, data)
    when Array
      decode_array(type, data)
    else
      decode_primitive_type(type, data)
    end
  end
end
