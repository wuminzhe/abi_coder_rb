# Generated from https://github.com/wuminzhe/abi_coder_rb
module AbiCoderRb
  def decode_array(type, data)
    size = decode_uint256(data[0, 32])
    raise DecodingError, "Too many elements: #{size}" if size > 100_000
    subtype = type.subtype
    if subtype.dynamic?
      raise DecodingError, "Not enough data for head" unless data.size >= 32 + 32 * size
      start_positions = (1..size).map { |i| 32 + decode_uint256(data[32 * i, 32]) }
      start_positions.push(data.size)
      outputs = (0...size).map { |i| data[start_positions[i]...start_positions[i + 1]] }
      outputs.map { |out| decode_type(subtype, out) }
    else
      (0...size).map { |i| decode_type(subtype, data[(32 + subtype.size * i)..]) }
    end
  end
end
module AbiCoderRb
  def decode_fixed_array(type, data)
    l = type.dim
    subtype = type.subtype
    if subtype.dynamic?
      start_positions = (0...l).map { |i| decode_uint256(data[32 * i, 32]) }
      start_positions.push(data.size)
      outputs = (0...l).map { |i| data[start_positions[i]...start_positions[i + 1]] }
      outputs.map { |out| decode_type(subtype, out) }
    else
      (0...l).map { |i| decode_type(subtype, data[subtype.size * i, subtype.size]) }
    end
  end
end
module AbiCoderRb
  def decode_primitive_type(type, data)
    case type
    when Uint
      decode_uint256(data[0, 32])
    when Int
      u = decode_uint256(data[0, 32])
      u >= 2**(type.bits - 1) ? (u - 2**type.bits) : u
    when Bool
      data[31] == BYTE_ONE
    when String
      size = decode_uint256(data[0, 32])
      data[32...(32 + size)].force_encoding("UTF-8")
    when Bytes
      size = decode_uint256(data[0, 32])
      data[32...(32 + size)]
    when FixedBytes
      data[0, type.length]
    when Address
      bin_to_hex(data[12...32]).force_encoding("UTF-8")
    else
      raise DecodingError, "Unknown primitive type: #{type.class.name} #{type.format}"
    end
  end
  private
  def decode_uint256(bin)
    bin_to_hex(bin).to_i(16)
  end
end
module AbiCoderRb
  def decode_tuple(type, data)
    decode_types(type.types, data)
  end
  private
  def decode_types(types, data)
    start_positions = start_positions(types, data)
    types.map.with_index do |type, index|
      start_position = start_positions[index]
      decode_type(type, data[start_position..])
    end
  end
  def start_positions(types, data)
    start_positions = ::Array.new(types.size)
    offset = 0
    types.each_with_index do |type, index|
      if type.dynamic?
        start_positions[index] = decode_uint256(data[offset, 32])
        offset += 32
      else
        start_positions[index] = offset
        offset += type.size
      end
    end
    start_positions
  end
end
module AbiCoderRb
  def decode(type_str, data)
    raise DecodingError, "Empty data" if data.nil? || data.empty?
    decode_type(Type.parse(type_str), data)
  end
  private
  def decode_type(type, data)
    case type
    when Tuple ## todo: support empty (unit) tuple - why? why not?
      decode_tuple(type, data)
    when FixedArray # static-sized arrays
      decode_fixed_array(type, data)
    when Array
      decode_array(type, data)
    else
      decode_primitive_type(type, data)
    end
  end
end
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
module AbiCoderRb
  def encode_fixed_array(type, args)
    raise ArgumentError, "arg must be an array" unless args.is_a?(::Array)
    raise ArgumentError, "Wrong array size: found #{args.size}, expecting #{type.dim}" unless args.size == type.dim
    args.map { |arg| encode_type(type.subtype, arg) }.join
  end
end
module AbiCoderRb
  def encode_primitive_type(type, arg)
    case type
    when Uint
      encode_uint(arg, type.bits)
    when Int
      encode_int(arg, type.bits)
    when Bool
      encode_bool(arg)
    when String
      encode_string(arg)
    when FixedBytes
      encode_bytes(arg, type.length)
    when Bytes
      encode_bytes(arg)
    when Address
      encode_address(arg)
    else
      raise EncodingError, "Unknown type: #{type}"
    end
  end
  def encode_uint(arg, bits)
    raise ArgumentError, "arg is not integer: #{arg}" unless arg.is_a?(Integer)
    raise ValueOutOfBounds, arg unless arg >= 0 && arg < 2**bits
    lpad_int(arg)
  end
  def encode_uint256(arg)
    encode_uint(arg, 256)
  end
  def encode_int(arg, bits)
    raise ArgumentError, "arg is not integer: #{arg}" unless arg.is_a?(Integer)
    raise ValueOutOfBounds, arg unless arg >= -2**(bits - 1) && arg < 2**(bits - 1)
    lpad_int(arg % 2**bits)
  end
  def encode_bool(arg)
    raise ArgumentError, "arg is not bool: #{arg}" unless arg.is_a?(TrueClass) || arg.is_a?(FalseClass)
    lpad(arg ? BYTE_ONE : BYTE_ZERO) ## was  lpad_int( arg ? 1 : 0 )
  end
  def encode_string(arg)
    raise EncodingError, "Expecting string: #{arg}" unless arg.is_a?(::String)
    arg = arg.b if arg.encoding != "BINARY" ## was: name == 'UTF-8', wasm
    raise ValueOutOfBounds, "Integer invalid or out of range: #{arg.size}" if arg.size > UINT_MAX
    size  =  lpad_int(arg.size)
    value =  rpad(arg, ceil32(arg.size))
    size + value
  end
  def encode_bytes(arg, length = nil)
    raise EncodingError, "Expecting string: #{arg}" unless arg.is_a?(::String)
    arg = hex_to_bin(arg) if hex?(arg)
    arg = arg.b if arg.encoding != Encoding::BINARY
    if length # fixed length type
      raise ValueOutOfBounds, "invalid bytes length #{length}" if arg.size > length
      raise ValueOutOfBounds, "invalid bytes length #{length}" if length < 0 || length > 32
      rpad(arg)
    else # variable length type  (if length is nil)
      raise ValueOutOfBounds, "Integer invalid or out of range: #{arg.size}" if arg.size > UINT_MAX
      size =  lpad_int(arg.size)
      value = rpad(arg, ceil32(arg.size))
      size + value
    end
  end
  def encode_address(arg)
    if arg.is_a?(Integer)
      lpad_int(arg)
    elsif arg.size == 20
      arg = arg.b if arg.encoding != Encoding::BINARY
      lpad(arg)
    elsif arg.size == 40
      lpad_hex(arg)
    elsif arg.size == 42 && arg[0, 2] == "0x" ## todo/fix: allow 0X too - why? why not?
      lpad_hex(arg[2..-1])
    else
      raise EncodingError, "Could not parse address: #{arg}"
    end
  end
  private
  def rpad(bin, l = 32) ## note: same as builtin String#ljust !!!
    return bin if bin.size >= l
    bin + BYTE_ZERO * (l - bin.size)
  end
  def lpad(bin) ## note: same as builtin String#rjust !!!
    l = 32 # NOTE: default l word is 32 bytes
    return bin  if bin.size >= l
    BYTE_ZERO * (l - bin.size) + bin
  end
  def lpad_int(n)
    raise ArgumentError, "Integer invalid or out of range: #{n}" unless n.is_a?(Integer) && n >= 0 && n <= UINT_MAX
    hex = n.to_s(16)
    hex = "0#{hex}" if hex.length.odd? # wasm, no .odd
    bin = hex_to_bin(hex)
    lpad(bin)
  end
  def lpad_hex(hex)
    raise TypeError, "Value must be a string" unless hex.is_a?(::String)
    raise TypeError, "Non-hexadecimal digit found" unless hex =~ /\A[0-9a-fA-F]*\z/
    bin = hex_to_bin(hex)
    lpad(bin)
  end
  def ceil32(x)
    x % 32 == 0 ? x : (x + 32 - x % 32)
  end
end
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
    head_size = types.map { |type| type.size || 32 }.sum
    head = "".b
    tail = "".b # 使用二进制字符串
    types.each_with_index do |type, i|
      if type.dynamic?
        head += encode_uint256(head_size + tail.size)
        tail += encode_type(type, args[i])
      else
        head += encode_type(type, args[i])
      end
    end
    head + tail
  end
end
module AbiCoderRb
  def encode(type, value)
    raise EncodingError, "Value can not be nil" if value.nil?
    encode_type(Type.parse(type), value)
  end
  private
  def encode_type(type, value)
    if type.is_a?(Tuple)
      encode_tuple(type, value)
    elsif type.is_a?(Array) || type.is_a?(FixedArray)
      type.dynamic? ? encode_array(type, value) : encode_fixed_array(type, value)
    else
      encode_primitive_type(type, value)
    end
  end
end
module AbiCoderRb
  class Type
    class ParseError < StandardError; end
    class Parser
      TUPLE_TYPE_RX = /^\((.*)\)
                       ((\[[0-9]*\])*)
                     /x
      def self.parse(type)
        type = type.strip
        if type =~ TUPLE_TYPE_RX
          types = _parse_tuple_type(::Regexp.last_match(1))
          dims = _parse_dims(::Regexp.last_match(2))
          parsed_types = types.map { |t| parse(t) }
          return _parse_array_type(Tuple.new(parsed_types), dims)
        end
        base, sub, dims = _parse_base_type(type)
        _validate_base_type(base, sub)
        subtype =  case base
                   when "string"  then   String.new
                   when "bytes"   then   sub ? FixedBytes.new(sub) : Bytes.new
                   when "uint"    then   Uint.new(sub)
                   when "int"     then   Int.new(sub)
                   when "address" then   Address.new
                   when "bool"    then   Bool.new
                   else
                     raise ParseError, "Unrecognized type base: #{base}"
                   end
        _parse_array_type(subtype, dims)
      end
      BASE_TYPE_RX = /([a-z]*)
                      ([0-9]*)
                      ((\[[0-9]*\])*)
                     /x
      def self._parse_base_type(str)
        _, base, subscript, dimension = BASE_TYPE_RX.match(str).to_a
        sub = subscript == "" ? nil : subscript.to_i
        dims = _parse_dims(dimension)
        [base, sub, dims]
      end
      def self._parse_dims(str)
        dims = str.scan(/\[[0-9]*\]/)
        dims.map do |dim|
          size = dim[1...-1]
          size == "" ? -1 : size.to_i
        end
      end
      def self._parse_array_type(subtype, dims)
        dims.each do |dim|
          subtype = if dim == -1
                      Array.new(subtype)
                    else
                      FixedArray.new(subtype, dim)
                    end
        end
        subtype
      end
      def self._validate_base_type(base, sub)
        case base
        when "string"
          raise ParseError, "String cannot have suffix" if sub
        when "bytes"
          raise ParseError, "Maximum 32 bytes for fixed-length bytes"  if sub && sub > 32
        when "uint", "int"
          raise ParseError, "Integer type must have numerical suffix"  unless sub
          raise ParseError, "Integer size out of bounds" unless sub >= 8 && sub <= 256
          raise ParseError, "Integer size must be multiple of 8" unless sub % 8 == 0
        when "address"
          raise ParseError, "Address cannot have suffix" if sub
        when "bool"
          raise ParseError, "Bool cannot have suffix" if sub
        else
          raise ParseError, "Unrecognized type base: #{base}"
        end
      end
      def self._parse_tuple_type(str)
        depth     = 0
        collected = []
        current   = ""
        str.each_char do |c|
          case c
          when ","
            if depth == 0
              collected << current
              current = ""
            else
              current += c
            end
          when "("
            depth += 1
            current += c
          when ")"
            depth -= 1
            current += c
          else
            current += c
          end
        end
        collected << current unless current.empty?
        collected
      end
    end # class Parser
  end #  class Type
end  # module ABI
module AbiCoderRb
  class Type
    def self.parse(type) ## convenience helper
      Parser.parse(type)
    end
    def size
    end
    def dynamic?
      size.nil?
    end
    def format
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
  end # class Address
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
  end # class Bytes
  class FixedBytes < Type
    attr_reader :length
    def initialize(length)
      @length = length # in bytes (1,2,...32)
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
  end # class FixedBytes
  class Int < Type
    attr_reader :bits
    def initialize(bits = 256)
      @bits = bits # in bits (8,16,...256)
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
  end # class Int
  class Uint < Type
    attr_reader :bits
    def initialize(bits = 256)
      @bits = bits # in bits (8,16,...256)
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
  end # class  Uint
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
  end # class Bool
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
  end # class String
  class Array < Type
    attr_reader :subtype
    def initialize(subtype)
      @subtype = subtype
    end
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
module AbiCoderRb
  VERSION = "0.1.0"
end
module AbiCoderRb
  class DecodingError < StandardError; end
  class EncodingError < StandardError; end
  class ValueError < StandardError; end
  class ValueOutOfBounds < ValueError; end
  BYTE_ZERO  = "\x00".b.freeze
  BYTE_ONE   = "\x01".b.freeze ## note: used for encoding bool for now
  UINT_MAX = 2**256 - 1   ## same as 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  UINT_MIN = 0
  INT_MAX  = 2**255 - 1   ## same as  57896044618658097711785492504343953926634992332820282019728792003956564819967
  INT_MIN  = -2**255      ## same as -57896044618658097711785492504343953926634992332820282019728792003956564819968
  def hex_to_bin(hex) # convert hex(adecimal) string  to binary string
    hex = hex[2..] if %w[0x 0X].include?(hex[0, 2]) ## cut-of leading 0x or 0X if present
    hex.scan(/../).map { |x| x.hex.chr }.join
  end
  alias hex hex_to_bin
  def bin_to_hex(bin) # convert binary string to hex string
    bin.each_byte.map { |byte| "%02x" % byte }.join
  end
  def hex?(str)
    str.start_with?("0x") && str.length.even? && str[2..].match?(/\A\b[0-9a-fA-F]+\b\z/)
  end
end
