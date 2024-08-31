module AbiCoderRb
  def decode_fixed_array(type, data)
    inner_type = type.inner_type

    if inner_type.dynamic?
      start_positions = (0...type.length).map { |i| decode_uint256(data[32 * i, 32]) } << data.size
      outputs = start_positions.each_cons(2).map { |start, stop| data[start...stop] }
    else
      outputs = (0...type.length).map { |i| data[inner_type.size * i, inner_type.size] }
    end

    outputs.map { |out| decode_type(inner_type, out) }
  end
end