module AbiCoderRb
  def decode_array(type, data)
    size = decode_uint256(data[0, 32])
    raise DecodingError, "Too many elements: #{size}" if size > 100_000

    inner_type = type.inner_type

    if inner_type.dynamic?
      raise DecodingError, "Not enough data for head" unless data.size >= 32 + 32 * size

      start_positions = (1..size).map { |i| 32 + decode_uint256(data[32 * i, 32]) }
      start_positions.push(data.size)

      outputs = (0...size).map { |i| data[start_positions[i]...start_positions[i + 1]] }

      outputs.map { |out| decode_type(inner_type, out) }
    else
      (0...size).map { |i| decode_type(inner_type, data[(32 + inner_type.size * i)..]) }
    end
  end
end
