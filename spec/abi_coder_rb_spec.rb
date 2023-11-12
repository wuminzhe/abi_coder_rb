RSpec.describe AbiCoderRb do
  let(:decoder) { AbiCoderRb::Decoder.new }
  def hex(data)
    AbiCoderRb.hex_to_bin(data)
  end

  def bin(data)
    AbiCoderRb.bin_to_hex(data)
  end

  # age: uint256 = 25
  # name: string = "Alice"
  it "does something useful" do
    data =
      "0x0000000000000000000000000000000000000000000000000000000000000019" \
        "0000000000000000000000000000000000000000000000000000000000000020" \
        "0000000000000000000000000000000000000000000000000000000000000005" \
        "416C696365000000000000000000000000000000000000000000000000000000"

    types = "uint256,string"

    decoder = AbiCoderRb::Decoder.new
    p decoder.decode(types, data)
  end

  # struct User {
  #     string lastName;
  #     uint256 id;
  #     string firstName;
  # }
  #
  # User memory user = User({
  #     lastName: 'Aki',
  #     id: 33,
  #     firstName: 'Wu'
  # });
  #
  # event UserInfo(uint256 count, User user)
  it "hello" do
    data_hex =
      "000000000000000000000000000000000000000000000000000000000000000b" + # count: 11
      "0000000000000000000000000000000000000000000000000000000000000040" + # user: offset 64
      "0000000000000000000000000000000000000000000000000000000000000060" + # 96 -> *user.lastName
      "0000000000000000000000000000000000000000000000000000000000000021" + # 33 -> user.id
      "00000000000000000000000000000000000000000000000000000000000000a0" + # 160 -> *user.firstName
      "0000000000000000000000000000000000000000000000000000000000000003" + # 3 -> user.lastName.length
      "416b690000000000000000000000000000000000000000000000000000000000" + # "Aki" -> user.lastName
      "0000000000000000000000000000000000000000000000000000000000000002" + # 2 -> user.firstName.length
      "5775000000000000000000000000000000000000000000000000000000000000"   # "Wu" -> user.firstName
  end

  it "baz" do
    types = %w[uint32 bool]
    args  = [69, true]

    data = AbiCoderRb.hex_to_bin "0000000000000000000000000000000000000000000000000000000000000045" \
                                 "0000000000000000000000000000000000000000000000000000000000000001"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single uint" do
    types = ["uint256"]
    args = [98_127_491]
    data = AbiCoderRb.hex_to_bin "0000000000000000000000000000000000000000000000000000000005d94e83"

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
    data = hex "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b48656c6c6f20576f726c64000000000000000000000000000000000000000000"

    expect(decoder.decode(types, data)).to eq args
  end

  it "single bytes" do
    types = ["bytes"]
    args = [hex("0x12345678")]
    data = hex "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000041234567800000000000000000000000000000000000000000000000000000000"

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
  end
end
