module AbiCoderRb
  class Type
    def size
      raise NotImplementedError, "size method not defined for #{self.class.name}"
    end

    def dynamic?
      size.nil?
    end

    def format
      raise NotImplementedError, "format method not defined for #{self.class.name}"
    end
  end

  class Address < Type
    def size
      32
    end

    def format
      "address"
    end

    def ==(other)
      other.is_a?(Address)
    end
  end

  class Bytes < Type
    def size
      nil
    end

    def format
      "bytes"
    end

    def ==(other)
      other.is_a?(Bytes)
    end
  end

  class FixedBytes < Type
    attr_reader :length

    def initialize(length)
      @length = length
    end

    def size
      32
    end

    def format
      "bytes#{@length}"
    end

    def ==(other)
      other.is_a?(FixedBytes) && @length == other.length
    end
  end

  class Int < Type
    attr_reader :bits

    def initialize(bits = 256)
      @bits = bits
    end

    def size
      32
    end

    def format
      "int#{@bits}"
    end

    def ==(other)
      other.is_a?(Int) && @bits == other.bits
    end
  end

  class Uint < Type
    attr_reader :bits

    def initialize(bits = 256)
      @bits = bits
    end

    def size
      32
    end

    def format
      "uint#{@bits}"
    end

    def ==(other)
      other.is_a?(Uint) && @bits == other.bits
    end
  end

  class Bool < Type
    def size
      32
    end

    def format
      "bool"
    end

    def ==(other)
      other.is_a?(Bool)
    end
  end

  class String < Type
    def size
      nil
    end

    def format
      "string"
    end

    def ==(other)
      other.is_a?(String)
    end
  end

  class Array < Type
    attr_reader :inner_type

    def initialize(inner_type)
      @inner_type = inner_type
    end

    def size
      nil
    end

    def format
      "#{@inner_type.format}[]"
    end

    def ==(other)
      other.is_a?(Array) && @inner_type == other.inner_type
    end
  end

  class FixedArray < Type
    attr_reader :inner_type, :length

    def initialize(inner_type, length)
      @inner_type = inner_type
      @length = length
    end

    def size
      @inner_type.dynamic? ? nil : @length * inner_type.size
    end

    def format
      "#{@inner_type.format}[#{@length}]"
    end

    def ==(other)
      other.is_a?(FixedArray) && @length == other.length && @inner_type == other.inner_type
    end
  end

  class Tuple < Type
    attr_reader :inner_types

    def initialize(inner_types)
      @inner_types = inner_types
    end

    def size
      s = 0
      has_dynamic = false
      @inner_types.each do |type|
        ts = type.size
        has_dynamic ||= ts.nil?
        s += ts unless ts.nil?
      end
      has_dynamic ? nil : s
    end

    def format
      "(#{@inner_types.map(&:format).join(",")})"
    end

    def ==(other)
      other.is_a?(Tuple) && @inner_types == other.inner_types
    end
  end
end