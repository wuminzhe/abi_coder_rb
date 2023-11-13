module AbiCoderRb
  def encode_array(type, args)
    raise ArgumentError, "arg must be an array" unless args.is_a?(::Array)

    head = "".b
    tail = "".b # 使用二进制字符串

    head += encode_uint256(args.size)

    subtype = type.subtype
    args.each do |arg|
      if subtype.dynamic?
        head += encode_uint256(32 * args.size + tail.size)
        tail += encode_type(subtype, arg)
      else
        head += encode_type(subtype, arg)
      end
    end

    head + tail
  end
end
