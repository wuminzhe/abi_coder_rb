module AbiCoderRb
  def encode_fixed_array(type, args)
    raise ArgumentError, "arg must be an array" unless args.is_a?(::Array)
    raise ArgumentError, "Wrong array size: found #{args.size}, expecting #{type.dim}" unless args.size == type.dim

    args.map { |arg| encode_type(type.subtype, arg) }.join
  end
end
