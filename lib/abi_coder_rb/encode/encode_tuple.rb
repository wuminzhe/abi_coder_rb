module AbiCoderRb
  def encode_tuple(tuple, args)
    encode_types(tuple.types, args)
  end

  private

  def encode_types(types, args)
    raise ArgumentError, "args must be an array" unless args.is_a?(::Array)

    unless args.size == types.size
      raise ArgumentError,
            "Wrong number of args: found #{args.size}, expecting #{types.size}"
    end

    # 计算头部大小
    head_size = types.map { |type| type.size || 32 }.sum

    # 初始化头部和尾部
    head = "".b
    tail = "".b # 使用二进制字符串

    # 遍历类型并编码
    types.each_with_index do |type, i|
      if type.dynamic?
        # 动态类型: 更新头部和尾部
        head += encode_uint256(head_size + tail.size)
        tail += encode_type(type, args[i])
      else
        # 静态类型: 只更新头部
        head += encode_type(type, args[i])
      end
    end

    head + tail
  end
end
