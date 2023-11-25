require "spec_helper"

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

  it "(bytes32,(address,uint256,uint256,address,uint256,address,uint256,bytes))" do
    type = "(bytes32,(address,uint256,uint256,address,uint256,address,uint256,bytes))"
    value = [
      hex("2628abe10aaf809f0ea9a33fb15782582e8d8353ea15698d7067b057748581a4"),
      [
        "00000000001523057a05d6293c1e5171ee33ee0a",
        195,
        421_614,
        "0000000000d2de3e2444926c4577b0a59f1dd8bc",
        44,
        "0000000000d2de3e2444926c4577b0a59f1dd8bc",
        473_508,
        hex("394d1bca0000000000000000000000000b001c95e86d64c1ad6e43944c568a6c31b538870000000000000000000000000b001c95e86d64c1ad6e43944c568a6c31b53887000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000090841287191622077700000000000000000000000000000000000000000000000")
      ]
    ]
    data = hex "2628abe10aaf809f0ea9a33fb15782582e8d8353ea15698d7067b057748581a4000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000001523057a05d6293c1e5171ee33ee0a00000000000000000000000000000000000000000000000000000000000000c30000000000000000000000000000000000000000000000000000000000066eee0000000000000000000000000000000000d2de3e2444926c4577b0a59f1dd8bc000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000d2de3e2444926c4577b0a59f1dd8bc00000000000000000000000000000000000000000000000000000000000739a4000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000a4394d1bca0000000000000000000000000b001c95e86d64c1ad6e43944c568a6c31b538870000000000000000000000000b001c95e86d64c1ad6e43944c568a6c31b5388700000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000009084128719162207770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "int" do
    type = "int16"
    value = -27_402
    data = hex "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff94f6"

    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "int -123" do
    type = "int16"
    value = -123
    data = hex "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff85"

    # p bin_to_hex(encode(type, value))
    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "int 123" do
    type = "int16"
    value = 123
    data = hex "000000000000000000000000000000000000000000000000000000000000007b"

    # p bin_to_hex(encode(type, value))
    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "int200" do
    type = "int200"
    value = -543_743_724_524_076_305_014_218_871_275_020_539_778_907_053_744_360_586_100_627
    data = hex "ffffffffffffffa9606aa1c2096ff66deafccdd2b53c3f86454784947209c06d"

    # p bin_to_hex(encode(type, value))
    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end

  it "int256" do
    type = "int256"
    value = 27_802_518_402_575_066_607_249_769_491_585_535_785_998_548_161_249_427_099_741_273_810_538_706_891_652
    data = hex "3d77aaf2a26292612f77f218a76f2bb30e4a7289d62dfe1930434ef806b5f384"

    # p bin_to_hex(encode(type, value))
    expect(encode(type, value)).to eq data
    expect(decode(type, data)).to eq value
  end
end
