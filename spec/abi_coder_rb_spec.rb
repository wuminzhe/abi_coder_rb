RSpec.describe AbiCoderRb do
  let(:decoder) { AbiCoderRb::Decoder.new }
  def hex(data)
    AbiCoderRb.hex_to_bin(data)
  end

  def bin(data)
    AbiCoderRb.bin_to_hex(data)
  end

  it "baz" do
    types = %w[uint32 bool]
    args  = [69, true]

    data = hex "0000000000000000000000000000000000000000000000000000000000000045" \
               "0000000000000000000000000000000000000000000000000000000000000001"

    expect(decoder.decode(types, data)).to eq args
  end

  it "bar" do
    types = ["bytes3[2]"]
    args =  [
      ["abc".b,
       "def".b]
    ]

    data = hex "6162630000000000000000000000000000000000000000000000000000000000" +
               "6465660000000000000000000000000000000000000000000000000000000000"
    expect(decoder.decode(types, data)).to eq args
  end

  it "uint256[2]" do
    types = ["uint256[2]"]
    args =  [
      [100, 200]
    ]
    data = hex "0000000000000000000000000000000000000000000000000000000000000064" \
               "00000000000000000000000000000000000000000000000000000000000000c8"
    expect(decoder.decode(types, data)).to eq args
  end

  it "uint256[]" do
    types = ["uint256[]"]
    args =  [
      [100, 200]
    ]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "0000000000000000000000000000000000000000000000000000000000000002" \
               "0000000000000000000000000000000000000000000000000000000000000064" \
               "00000000000000000000000000000000000000000000000000000000000000c8"
    expect(decoder.decode(types, data)).to eq args
  end

  it "single uint" do
    types = ["uint256"]
    args = [98_127_491]
    data = hex "0000000000000000000000000000000000000000000000000000000005d94e83"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single int" do
    types = ["int256"]
    args = [-100]
    data = hex "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single bool" do
    types = ["bool"]
    args = [false]
    data = hex "0000000000000000000000000000000000000000000000000000000000000000"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single string" do
    types = ["string"]
    args = ["Hello World"]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "000000000000000000000000000000000000000000000000000000000000000b" \
               "48656c6c6f20576f726c64000000000000000000000000000000000000000000"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single bytes" do
    types = ["bytes"]
    args = [hex("0x12345678")]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "0000000000000000000000000000000000000000000000000000000000000004" \
               "1234567800000000000000000000000000000000000000000000000000000000"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single bytes4" do
    types = ["bytes4"]
    args = [hex("0x12345678")]
    data = hex "1234567800000000000000000000000000000000000000000000000000000000"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single address" do
    types = ["address"]
    args = ["cd2a3d9f938e13cd947ec05abc7fe734df8dd826"]
    data = hex "000000000000000000000000cd2a3d9f938e13cd947ec05abc7fe734df8dd826"

    expect(decoder.decode(types, data)).to eq args
  end

  # it "single uint[]" do
  # end

  it "integer and address" do
    types = %w[uint256 address]
    args = [
      324_124,
      "cd2a3d9f938e13cd947ec05abc7fe734df8dd826"
    ]
    data = hex "000000000000000000000000000000000000000000000000000000000004f21c" \
               "000000000000000000000000cd2a3d9f938e13cd947ec05abc7fe734df8dd826"
    expect(decoder.decode(types, data)).to eq args
  end

  it "hello" do
    types = %w[uint256 string]
    args = [1234, "Hello World"]
    data = hex "00000000000000000000000000000000000000000000000000000000000004d2" \
               "0000000000000000000000000000000000000000000000000000000000000040" \
               "000000000000000000000000000000000000000000000000000000000000000b" \
               "48656c6c6f20576f726c64000000000000000000000000000000000000000000"
    expect(decoder.decode(types, data)).to eq args

    types = ["uint256[]", "string"]
    args = [[1234, 5678], "Hello World"]
    data = hex "0000000000000000000000000000000000000000000000000000000000000040" +
               "00000000000000000000000000000000000000000000000000000000000000a0" +
               "0000000000000000000000000000000000000000000000000000000000000002" +
               "00000000000000000000000000000000000000000000000000000000000004d2" +
               "000000000000000000000000000000000000000000000000000000000000162e" +
               "000000000000000000000000000000000000000000000000000000000000000b" +
               "48656c6c6f20576f726c64000000000000000000000000000000000000000000"
    expect(decoder.decode(types, data)).to eq args
  end
end
