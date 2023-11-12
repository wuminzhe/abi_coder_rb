module AbiCoderRb
  class Decoder
    def decode(types, data)
      types = prepare_types(types)
      start_positions = initialize_start_positions(types, data)
      outputs = ::Array.new(types.size)

      types.each_with_index do |type, index|
        start_position = start_positions[index]

        if type.dynamic?
          content_length = decode_uint256(data[start_position...start_position + 32])
          content_from = start_position + 32
          content_to = content_from + content_length
          content = data[content_from...content_to]
          # outputs[index] = decode_dynamic_type(type, content)
        else
          content_from = start_position
          content_to = content_from + type.size
          content = data[content_from...content_to]
          outputs[index] = decode_static_type(type, content)
        end

        # p  AbiCoderRb.bin_to_hex(data[content_from...content_to])
      end

      outputs
    end

    private

    # Convert types to ABI::Type if they are not already
    def prepare_types(types)
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

    def process_dynamic_type(_type, index, data, start_positions, _outputs, raise_errors)
      pos = calculate_position(index, data, raise_errors)
      start_positions[index] = decode_uint256(data[pos, 32])
      check_start_position_bounds(start_positions[index], data.size, raise_errors)
      update_previous_positions(start_positions, index)
      # Additional processing for dynamic types
    end

    def decode_static_type(type, content)
      raise AbiCoderRb::DecodingError, "Data out of bounds when decoding static type." if type.size > content.length

      p "decode_static_type: #{type}, #{content}"

      decode_primitive_type(type, content)
    end

    def decode_primitive_type(type, data)
      case type
      when Uint
        decode_uint256(data)
      when Int
        u = decode_uint256(data)
        u >= 2**(type.bits - 1) ? (u - 2**type.bits) : u
      when Bool
        data[-1] == BYTE_ONE
      when String
        ## note: convert to a string (with UTF_8 encoding NOT BINARY!!!)
        size = decode_uint256(data[0, 32])
        data[32..-1][0, size].force_encoding(Encoding::UTF_8)
      when Bytes
        size = decode_uint256(data[0, 32])
        data[32..-1][0, size]
      when FixedBytes
        data[0, type.length]
      when Address
        ## note: convert to a hex string (with UTF_8 encoding NOT BINARY!!!)
        data[12..-1].unpack1("H*").force_encoding(Encoding::UTF_8)
      else
        raise DecodingError, "Unknown primitive type: #{type.class.name} #{type.format}"
      end
    end

    def decode_uint256(bin)
      # bin = bin.sub( /\A(\x00)+/, '' )   ## keep "performance" shortcut - why? why not?
      ### todo/check - allow nil - why? why not?
      ##  raise DeserializationError, "Invalid serialization (not minimal length)" if !@size && serial.size > 0 && serial[0] == BYTE_ZERO
      # bin = bin || BYTE_ZERO
      bin.unpack1("H*").to_i(16)
    end
  end
end
