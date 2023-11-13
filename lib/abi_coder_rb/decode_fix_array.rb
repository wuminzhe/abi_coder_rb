module AbiCoderRb
  def decode_fix_array(type, data)
    l = type.dim
    subtype = type.subtype
    if subtype.dynamic?
      start_positions = (0...l).map { |i| decode_uint256(data[32 * i, 32]) }
      start_positions.push(data.size)

      outputs = (0...l).map { |i| data[start_positions[i]...start_positions[i + 1]] }

      outputs.map { |out| decode_type(subtype, out) }
    else
      (0...l).map { |i| decode_type(subtype, data[subtype.size * i, subtype.size]) }
    end
  end
end
