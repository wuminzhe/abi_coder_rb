module AbiCoderRb
  class Decoder
    def decode_tuple(types, data)
      types = convert_types(types)
      start_positions = initialize_start_positions(types, data)

      types.map.with_index do |type, index|
        start_position = start_positions[index]

        if type.dynamic?
          content_length = decode_uint256(data[start_position...start_position + 32])
          content_from = start_position + 32
          content_to = content_from + content_length
        else
          content_from = start_position
          content_to = content_from + type.size
        end

        content = data[content_from...content_to]
        puts "== type: #{type}"
        print "   "
        p content
        decode_type(type, content)
      end
    end

    private

    # Convert types to ABI::Type if they are not already
    def convert_types(types)
      types.map { |type| type.is_a?(Type) ? type : Type.parse(type) }
    end

    def initialize_start_positions(types, data)
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
end
