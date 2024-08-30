module AbiCoderRb
  def encode_fixed_array(type, args, packed = false)
    raise ArgumentError, "arg must be an array" unless args.is_a?(::Array)
    raise ArgumentError, "Wrong array size: found #{args.size}, expecting #{type.length}" unless args.size == type.length

    # fixed_array，是没有元素数量的编码de
    # 如果内部类型是静态的，就是一个一个元素编码后加起来。
    # 如果内部类型是动态的，先用位置一个一个编码加起来，然后是元素本体
    _encode_array(type: type, args: args, packed: packed)
  end
end
