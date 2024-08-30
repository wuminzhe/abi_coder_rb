module AbiCoderRb
  #######
  ## for now use (get inspired)
  ##    by the type names used by abi coder in rust
  ##      see  https://github.com/rust-ethereum/ethabi/blob/master/ethabi/src/param_type/param_type.rs

  class Type
    def self.parse(str) ## convenience helper
      Parser.parse(str)
    end

    ##
    # Get the static size of a type, or nil if dynamic.
    #
    # @return [Integer, NilClass]  size of static type, or nil for dynamic type
    #
    def size
      ## check/todo: what error to raise for not implemented / method not defined???
      raise ArgumentError, "no required size method defined for Type subclass #{self.class.name}; sorry"
    end

    def dynamic?
      size.nil?
    end

    def format
      ## check/todo: what error to raise for not implemented / method not defined???
      raise ArgumentError, "no required format method defined for Type subclass #{self.class.name}; sorry"
    end

    ####
    ##   default implementation
    ##    assume equal if class match (e.g. Address == Address)
    ##    - use format string for generic compare - why? why not?
  end

  class Address < Type
    ## note: address is always 20 bytes;  BUT uses 32 bytes (with padding)
    def size
      32
    end

    def format
      "address"
    end

    def ==(other)
      other.is_a?(Address)
    end
  end # class Address

  class Bytes < Type
    ## note: dynamic (not known at compile-time)
    def size
      nil
    end

    def format
      "bytes"
    end

    def ==(other)
      other.is_a?(Bytes)
    end
  end # class Bytes

  class FixedBytes < Type
    attr_reader :length

    def initialize(length)
      @length = length # in bytes (1,2,...32)
    end

    ## note: always uses 32 bytes (with padding)
    def size
      32
    end

    def format
      "bytes#{@length}"
    end

    def ==(other)
      other.is_a?(FixedBytes) && @length == other.length
    end
  end # class FixedBytes

  class Int < Type
    attr_reader :bits

    def initialize(bits = 256)
      @bits = bits # in bits (8,16,...256)
    end

    ## note: always uses 32 bytes (with padding)
    def size
      32
    end

    def format
      "int#{@bits}"
    end

    def ==(other)
      other.is_a?(Int) && @bits == other.bits
    end
  end # class Int

  class Uint < Type
    attr_reader :bits

    def initialize(bits = 256)
      @bits = bits # in bits (8,16,...256)
    end

    ## note: always uses 32 bytes (with padding)
    def size
      32
    end

    def format
      "uint#{@bits}"
    end

    def ==(other)
      other.is_a?(Uint) && @bits == other.bits
    end
  end # class  Uint

  class Bool < Type
    ## note: always uses 32 bytes (with padding)
    def size
      32
    end

    def format
      "bool"
    end

    def ==(other)
      other.is_a?(Bool)
    end
  end # class Bool

  class String < Type
    ## note: dynamic (not known at compile-time)
    def size
      nil
    end

    def format
      "string"
    end

    def ==(other)
      other.is_a?(String)
    end
  end # class String

  class Array < Type
    attr_reader :subtype

    def initialize(subtype)
      @subtype = subtype
    end

    ## note: dynamic (not known at compile-time)
    def size
      nil
    end

    def format
      "#{@subtype.format}[]"
    end

    def ==(other)
      other.is_a?(Array) && @subtype == other.subtype
    end
  end  # class Array

  class FixedArray < Type
    attr_reader :subtype, :dim

    def initialize(subtype, dim)
      @subtype = subtype
      @dim = dim
    end

    def size
      @subtype.dynamic? ? nil : @dim * subtype.size
    end

    def format
      "#{@subtype.format}[#{@dim}]"
    end

    def ==(other)
      other.is_a?(FixedArray) &&
        @dim == other.dim &&
        @subtype == other.subtype
    end
  end  # class FixedArray

  class Tuple < Type
    attr_reader :types

    def initialize(types)
      @types = types
    end

    def size
      s = 0
      has_dynamic = false
      @types.each do |type|
        ts = type.size
        if ts.nil?
          # can not return nil here? if wasm
          has_dynamic = true
        else
          s += ts
        end
      end

      return if has_dynamic

      s
    end

    def format
      "(#{@types.map { |t| t.format }.join(",")})" ## rebuild minimal string
    end

    def ==(other)
      other.is_a?(Tuple) && @types == other.types
    end
  end # class Tuple
end  # module ABI
