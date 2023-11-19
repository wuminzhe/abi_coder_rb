RSpec.describe AbiCoderRb do
  it "uint256[2]" do
    type = "uint256[2]"
    value = [100, 200]
    data = hex "0000000000000000000000000000000000000000000000000000000000000064" \
               "00000000000000000000000000000000000000000000000000000000000000c8"
    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "uint256[]" do
    type = "uint256[]"
    value = [100, 200]
    data = hex "0000000000000000000000000000000000000000000000000000000000000002" \
               "0000000000000000000000000000000000000000000000000000000000000064" \
               "00000000000000000000000000000000000000000000000000000000000000c8"
    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(uint256[])" do
    type = "(uint256[])"
    value = [[100, 200]]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "0000000000000000000000000000000000000000000000000000000000000002" \
               "0000000000000000000000000000000000000000000000000000000000000064" \
               "00000000000000000000000000000000000000000000000000000000000000c8"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "uint" do
    type = "uint256"
    value = 98_127_491
    data = hex "0000000000000000000000000000000000000000000000000000000005d94e83"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(uint)" do
    type = "(uint256)"
    value = [98_127_491]
    data = hex "0000000000000000000000000000000000000000000000000000000005d94e83"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "int" do
    type = "int256"
    value = -100
    data = hex "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(int)" do
    type = "(int256)"
    value = [-100]
    data = hex "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "bool" do
    type = "bool"
    value = false
    data = hex "0000000000000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(bool)" do
    type = "(bool)"
    value = [false]
    data = hex "0000000000000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "string" do
    type = "string"
    value = "Hello World"
    data = hex "000000000000000000000000000000000000000000000000000000000000000b" \
               "48656c6c6f20576f726c64000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(string)" do
    type = "(string)"
    value = ["Hello World"]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "000000000000000000000000000000000000000000000000000000000000000b" \
               "48656c6c6f20576f726c64000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "bytes" do
    type = "bytes"
    value = hex("0x12345678")
    data = hex "0000000000000000000000000000000000000000000000000000000000000004" \
               "1234567800000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(bytes)" do
    type = "(bytes)"
    value = [hex("0x12345678")]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "0000000000000000000000000000000000000000000000000000000000000004" \
               "1234567800000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "bytes4" do
    type = "bytes4"
    value = hex("0x12345678")
    data = hex "1234567800000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "bytes4 - 2" do
    type = "bytes4"
    value = "1234".b
    data = hex "3132333400000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(bytes4)" do
    type = "(bytes4)"
    value = [hex("0x12345678")]
    data = hex "1234567800000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "(bytes4) - encoding from hex string" do
    type = "(bytes4)"
    value = ["0x12345678"]
    data = hex "1234567800000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
  end
end
