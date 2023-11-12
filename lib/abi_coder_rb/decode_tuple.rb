module AbiCoderRb
  class Decoder
    def decode_tuple(type, data)
      decode_types(type.types, data)
    end
  end
end
