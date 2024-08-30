module AbiCoderRb
  def decode_fixed_array(type, data)
    l = type.length
    inner_type = type.inner_type
    if inner_type.dynamic?
      start_positions = (0...l).map { |i| decode_uint256(data[32 * i, 32]) }
      start_positions.push(data.size)

      outputs = (0...l).map { |i| data[start_positions[i]...start_positions[i + 1]] }

      outputs.map { |out| decode_type(inner_type, out) }
    else
      (0...l).map { |i| decode_type(inner_type, data[inner_type.size * i, inner_type.size]) }
    end
  end
end
