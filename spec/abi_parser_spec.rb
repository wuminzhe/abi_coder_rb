require "spec_helper"

RSpec.describe AbiCoderRb::AbiParser do
  def expect_parsed_abi_to_match(abi_string, expected)
    parser = AbiCoderRb::AbiParser.new(abi_string)
    expect(parser.parse).to eq(expected)
  end

  describe '#parse' do
    it 'parses simple type' do
      expect_parsed_abi_to_match(
        'bool',
        { type: 'bool' }
      )
    end

    it 'parses array type with length' do
      expect_parsed_abi_to_match(
        'string[3]',
        { type: 'array', inner_type: { type: 'string' }, length: 3 }
      )
    end

    it 'parses nested array type' do
      expect_parsed_abi_to_match(
        'bytes32[3][2]',
        {
          type: 'array',
          inner_type: {
            type: 'array',
            inner_type: { type: 'bytes', length: 32 },
            length: 3
          },
          length: 2
        }
      )
    end

    it 'parses dynamic array type' do
      expect_parsed_abi_to_match(
        'string[]',
        { type: 'array', inner_type: { type: 'string' }, length: nil }
      )
    end

    it 'parses tuple type' do
      expect_parsed_abi_to_match(
        "((address,uint256),bool[])",
        {
          type: "tuple",
          inner_types: [
            { type: "tuple", inner_types: [{ type: "address" }, { type: "uint", bits: 256 }] },
            { type: "array", inner_type: { type: "bool" }, length: nil }
          ]
        }
      )
    end

    it 'parses complex nested types' do
      expect_parsed_abi_to_match(
        "(bool[3], (uint256, string[]))",
        {
          type: "tuple",
          inner_types: [
            { type: "array", inner_type: { type: "bool" }, length: 3 },
            {
              type: "tuple", inner_types: [
                { type: "uint", bits: 256 },
                { type: "array", inner_type: { type: "string" }, length: nil }
              ]
            }
          ]
        }
      )
    end

    it 'raises error for unexpected token' do
      parser = AbiCoderRb::AbiParser.new("unexpected")
      expect { parser.parse }.to raise_error(AbiCoderRb::ParseError, "Unexpected token: unexpected")
    end

    it 'raises error for invalid array length' do
      parser = AbiCoderRb::AbiParser.new("string[invalid]")
      expect { parser.parse }.to raise_error(AbiCoderRb::ParseError, "Expected array length or closing ']'")
    end
  end
end