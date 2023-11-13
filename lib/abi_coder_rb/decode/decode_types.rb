module AbiCoderRb
  def decode_types(types, data)
    start_positions = start_positions(types, data)

    types.map.with_index do |type, index|
      start_position = start_positions[index]
      decode_type(type, data[start_position..])
    end
  end

  private

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
