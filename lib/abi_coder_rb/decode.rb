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

  private

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

  def decode_types(types, data)
    start_positions = start_positions(types, data)

    types.map.with_index do |type, index|
      start_position = start_positions[index]
      decode_type(type, data[start_position..])
    end
  end

  def start_positions(types, data)
    start_positions = ::Array.new(types.size)
    offset = 0

    types.each_with_index do |type, index|
      if type.dynamic?
        # 读取动态类型的偏移量
        start_positions[index] = decode_uint256(data[offset, 32])
        offset += 32
      else
        start_positions[index] = offset
        offset += type.size
      end
    end

    start_positions
  end
end
