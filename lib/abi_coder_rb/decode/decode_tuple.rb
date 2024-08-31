module AbiCoderRb
  def decode_tuple(type, data)
    decode_types(type.inner_types, data)
  end

  private

  def decode_types(types, data)
    start_positions = calculate_start_positions(types, data)
    types.map.with_index { |type, index| decode_type(type, data[start_positions[index]..]) }
  end

  def calculate_start_positions(types, data)
    offset = 0
    types.map do |type|
      position = offset
      offset += type.dynamic? ? 32 : type.size
      type.dynamic? ? decode_uint256(data[position, 32]) : position
    end
  end
end