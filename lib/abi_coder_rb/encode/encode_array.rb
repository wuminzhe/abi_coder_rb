module AbiCoderRb
  def encode_array(type, args, packed = false)
    raise ArgumentError, "arg must be an array" unless args.is_a?(::Array)

    _encode_array(type: type, args: args, packed: packed)
  end

  private

  def _encode_array(type:, args:, packed: false)
    head = "".b
    tail = "".b

    # 数组长度
    head += encode_uint256(args.size) if type.is_a?(Array) && !packed

    subtype = type.subtype
    args.each do |arg|
      if subtype.dynamic?
        raise "#{type.class} with dynamic inner type is not supported in packed mode" if packed

        head += encode_uint256(32 * args.size + tail.size) # 当前数据的位置指针
        tail += encode_type(subtype, arg)
      else
        head += encode_type(subtype, arg)
      end
    end

    head + tail
  end
end
