module AbiCoderRb
  def encode_fixed_array(type, args, packed = false)
    raise ArgumentError, "arg must be an array" unless args.is_a?(::Array)
    raise ArgumentError, "Wrong array size: found #{args.size}, expecting #{type.dim}" unless args.size == type.dim

    # fixed_array，是没有元素数量的编码de
    # 如果内部类型是静态的，就是一个一个元素编码后加起来。
    # 如果内部类型是动态的，先用位置一个一个编码加起来，然后是元素本体

    head = "".b
    tail = "".b

    subtype = type.subtype
    args.each do |arg|
      if subtype.dynamic?
        raise "Fixed array with dynamic inner type not supported in packed mode" if packed

        head += encode_uint256(32 * args.size + tail.size) # 当前数据的位置指针
        tail += encode_type(subtype, arg)
      else
        head += encode_type(subtype, arg)
      end
    end

    head + tail
  end
end
