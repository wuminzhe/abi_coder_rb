module AbiCoderRb
  def encode_tuple(tuple, args)
    encode_types(tuple.types, args)
  end
end
