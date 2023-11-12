module AbiCoderRb
  class Decoder
    def decode_type(type, data)
      return nil if data.nil? || data.empty?

      case type
      when Tuple ## todo: support empty (unit) tuple - why? why not?
        decode_tuple(type, data)
      when FixedArray # static-sized arrays
        decode_fix_array(type, data)
      when Array
        decode_array(type, data)
      else
        decode_primitive_type(type, data)
      end
    end
  end
end
