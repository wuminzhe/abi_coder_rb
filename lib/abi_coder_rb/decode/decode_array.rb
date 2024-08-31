module AbiCoderRb
  def decode_array(type, data)
    size = decode_uint256(data[0, 32])
    raise DecodingError, "Too many elements: #{size}" if size > 100_000

    inner_type = type.inner_type
    raise DecodingError, "Not enough data for head" if inner_type.dynamic? && data.size < 32 + 32 * size

    if inner_type.dynamic?
      start_positions = (1..size).map { |i| 32 + decode_uint256(data[32 * i, 32]) } << data.size
      outputs = start_positions.each_cons(2).map { |start, stop| data[start...stop] }
    else
      outputs = (0...size).map { |i| data[(32 + inner_type.size * i)..] }
    end

    outputs.map { |out| decode_type(inner_type, out) }
  end
end