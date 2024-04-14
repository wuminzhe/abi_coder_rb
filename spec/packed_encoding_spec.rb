require "spec_helper"

# https://docs.soliditylang.org/en/v0.8.11/abi-spec.html#non-standard-packed-mode
RSpec.describe AbiCoderRb do
  it "bool" do
    type = "bool"
    value = true
    data = hex "01"

    expect(encode(type, value, true)).to eq data
    # expect(decode(type, data)).to eq value
  end

  it "bytes" do
    type = "bytes"
    value = "dave".b
    data = hex "64617665"

    expect(encode(type, value, true)).to eq data
  end

  it "types4" do
    type = "bytes4"
    value = "dave".b
    data = hex "64617665"

    expect(encode(type, value, true)).to eq data
  end

  it "string" do
    type = "string"
    value = "dave"
    data = hex "64617665"

    expect(encode(type, value, true)).to eq data
  end

  it "address1" do
    type = "address"
    value = "cd2a3d9f938e13cd947ec05abc7fe734df8dd826"
    data = hex "cd2a3d9f938e13cd947ec05abc7fe734df8dd826"

    expect(encode(type, value, true)).to eq data
  end

  it "address2" do
    type = "address"
    value = hex "cd2a3d9f938e13cd947ec05abc7fe734df8dd826"
    data = hex "cd2a3d9f938e13cd947ec05abc7fe734df8dd826"

    expect(encode(type, value, true)).to eq data
  end

  it "address3" do
    type = "address"
    value = 0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826
    data = hex "cd2a3d9f938e13cd947ec05abc7fe734df8dd826"

    expect(encode(type, value, true)).to eq data
  end

  it "uint32" do
    type = "uint32"
    value = 17
    data = hex "00000011"

    expect(encode(type, value, true)).to eq data
    # expect(decode(type, data)).to eq value
  end

  it "int64" do
    type = "int64"
    value = 17
    data = hex "0000000000000011"

    expect(encode(type, value, true)).to eq data
    # expect(decode(type, data)).to eq value
  end

  it "(uint64)" do
    type = "(uint64)"
    value = [17]
    data = hex "0000000000000011"

    expect(encode(type, value, true)).to eq data
    # expect(decode(type, data)).to eq value
  end

  # abi.encodePacked((var1, var2))
  it "(int32,uint64)" do
    type = "(int32,uint64)"
    value = [17, 17]
    # data = hex "000000110000000000000011"

    expect do
      encode(type, value, true)
    end.to raise_error("AbiCoderRb::Tuple with multi inner types is not supported in packed mode")
    # expect(decode(type, data)).to eq value
  end

  # abi.encodePacked(var1, var2)
  it "int32,uint64" do
    types = %w[int32 uint64]
    values = [17, 17]
    data = hex "000000110000000000000011"

    expect(encode(types, values, true)).to eq data
  end

  it "uint16[]" do
    type = "uint16[]"
    value = [1, 2]
    data = hex "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002"

    expect(encode(type, value, true)).to eq data
  end

  it "bool[]" do
    type = "bool[]"
    value = [true, false]
    data = hex "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value, true)).to eq data
  end

  it "(uint16[])" do
    type = "(uint16[])"
    value = [[1, 2]]
    data = hex "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002"

    expect(encode(type, value, true)).to eq data
  end

  it "uint16[2]" do
    type = "uint16[2]"
    value = [1, 2]
    data = hex "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002"

    expect(encode(type, value, true)).to eq data
  end

  it "bytes[2]" do
    type = "bytes[2]"
    value = ["dave".b, "dave".b]

    expect do
      encode(type, value, true)
    end.to raise_error("AbiCoderRb::FixedArray with dynamic inner type is not supported in packed mode")
  end

  it "encodes packed types" do
    expect(
      encode("uint8[]", [1, 2, 3], true)
    ).to eq(
      hex("000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003")
    )

    expect(
      encode("uint16[]", [1, 2, 3], true)
    ).to eq(
      hex("000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003")
    )

    expect(
      encode("uint32", 17, true)
    ).to eq(
      hex("00000011")
    )

    expect(
      encode("uint64", 17, true)
    ).to eq(
      hex("0000000000000011")
    )

    expect(
      encode("bool[]", [true, false], true)
    ).to eq(
      hex("00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000")
    )

    expect(
      encode("bool", true, true)
    ).to eq hex("01")

    expect(
      encode("int32[]", [1, 2, 3], true)
    ).to eq(
      hex("000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003")
    )

    expect(
      encode("int64[]", [1, 2, 3], true)
    ).to eq(
      hex("000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003")
    )

    expect(
      encode("int64", 17, true)
    ).to eq hex("0000000000000011")

    expect(
      encode("int128", 17, true)
    ).to eq hex("00000000000000000000000000000011")

    transactions = [
      { operation: 0, to: "0xa89005ab7d7fd81A94c8A8e0799648248CeE6934", value: 1, data: "".b },
      { operation: 0, to: "0xc1b5bcbc94e6127ac3ee4054d0664e4f6afe45d3", value: 1, data: "".b }
    ]
    result = transactions.map do |tx|
      encode(
        %w[uint8 address uint256 uint256 bytes],
        [tx[:operation], tx[:to], tx[:value], tx[:data].length, tx[:data]],
        true
      )
    end.join

    expect(result).to eq(
      hex("00a89005ab7d7fd81a94c8a8e0799648248cee69340000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000c1b5bcbc94e6127ac3ee4054d0664e4f6afe45d300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000")
    )
  end
end
