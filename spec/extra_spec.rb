RSpec.describe AbiCoderRb do
  it "uint256[2]" do
    types = ["uint256[2]"]
    args =  [
      [100, 200]
    ]
    data = hex "0000000000000000000000000000000000000000000000000000000000000064" \
               "00000000000000000000000000000000000000000000000000000000000000c8"
    expect(decode(types, data)).to eq args
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
    expect(decode(types, data)).to eq args
  end

  it "single uint" do
    types = ["uint256"]
    args = [98_127_491]
    data = hex "0000000000000000000000000000000000000000000000000000000005d94e83"

    expect(decode(types, data)).to eq args
  end

  it "single int" do
    types = ["int256"]
    args = [-100]
    data = hex "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c"

    expect(decode(types, data)).to eq args
  end

  it "single bool" do
    types = ["bool"]
    args = [false]
    data = hex "0000000000000000000000000000000000000000000000000000000000000000"

    expect(decode(types, data)).to eq args
  end

  it "single string" do
    types = ["string"]
    args = ["Hello World"]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "000000000000000000000000000000000000000000000000000000000000000b" \
               "48656c6c6f20576f726c64000000000000000000000000000000000000000000"

    expect(decode(types, data)).to eq args
  end

  it "single bytes" do
    types = ["bytes"]
    args = [hex("0x12345678")]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020" \
               "0000000000000000000000000000000000000000000000000000000000000004" \
               "1234567800000000000000000000000000000000000000000000000000000000"

    expect(decode(types, data)).to eq args
  end

  it "single bytes4" do
    types = ["bytes4"]
    args = [hex("0x12345678")]
    data = hex "1234567800000000000000000000000000000000000000000000000000000000"

    expect(decode(types, data)).to eq args
  end
end
