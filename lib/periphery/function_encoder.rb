require "digest/keccak"

module FunctionEncoder
  extend AbiCoderRb

  class << self
    def encode_function(function_signature, params)
      # check the method_signature by regex
      raise "Invalid function signature" unless function_signature.match?(/^\w+\(.+\)$/)

      # e.g. baz(uint32,bool) => (uint32,bool)
      types_str = "(#{function_signature.match(/\((.*)\)/)[1]})"
      "0x#{function_id(function_signature)}#{bin_to_hex(encode(types_str, params))}"
    end

    private

    # This is derived as the first 4 bytes of the Keccak hash of the ASCII form of the signature like `baz(uint32,bool)`.
    def function_id(function_signature)
      # remove blank spaces
      function_signature = function_signature.gsub(/\s+/, "")
      Digest::Keccak.hexdigest(function_signature, 256)[0, 8]
    end
  end
end
