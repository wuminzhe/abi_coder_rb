require "json"
require "digest/keccak"

# param: address is a hex string with or without '0x' prefix
def to_checksum_address(address)
  # Hash the address using Keccak-256
  address_hash = Digest::Keccak.hexdigest(address, 256)

  # Create checksum address
  checksum_address = ""
  address.chars.each_with_index do |char, index|
    checksum_address += if %w[0 1 2 3 4 5 6 7 8 9].include?(char)
                          char
                        elsif address_hash[index].to_i(16) >= 8
                          char.upcase
                        else
                          char
                        end
  end

  checksum_address
end

module AbiTestsForWeb3js
  extend AbiCoderRb

  before_encoding lambda { |type, value|
    if type.start_with?("bytes")
      hex_to_bin(value)
    elsif type.start_with?("uint") || type.start_with?("int")
      value.to_i
    elsif type == "string"
      value
    else
      value
    end
  }

  after_decoding lambda { |type, value|
    if type == "address"
      "0x#{to_checksum_address(value)}"
    elsif type.start_with?("uint") || type.start_with?("int")
      "#{value}"
    elsif type.start_with?("bytes")
      "0x#{bin_to_hex(value)}"
    else
      value
    end
  }
end

RSpec.describe AbiTestsForWeb3js do
  it "can pass web3js's unit/encodeDecodeParams.test.ts" do
    data = File.join __dir__, "fixtures", "abitestsdata.json"

    tests = JSON.parse File.open(data).read
    # test = tests[2]
    tests.each_with_index do |test, i|
      puts "test #{i}: #{test["name"]}"
      type = "(#{test["type"]})"
      value = [test["value"]]
      data = AbiTestsForWeb3js.hex test["encoded"]

      # p bin_to_hex AbiTestsForWeb3js.encode(type, value)
      # p bin_to_hex data
      expect(AbiTestsForWeb3js.encode(type, value)).to eq data
      expect(AbiTestsForWeb3js.decode(type, data)).to eq value
    end
  end

  it "(address[2])" do
    type = "(address[2])"
    value = [
      %w[
        0x4Dd619E0Bd36C127256eED954270dDb41047AF6F
        0xE5a8B84E1E3e31F9865e21dC9a27d1e2A53ddCb6
      ]
    ]
    data = AbiTestsForWeb3js.hex "0000000000000000000000004dd619e0bd36c127256eed954270ddb41047af6f000000000000000000000000e5a8b84e1e3e31f9865e21dc9a27d1e2a53ddcb6"

    expect(AbiTestsForWeb3js.encode(type, value)).to eq data
    expect(AbiTestsForWeb3js.decode(type, data)).to eq value
  end

  it "(string[1])" do
    type = "(string[1])"
    value = [["Moo"]]
    data = hex "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000034d6f6f0000000000000000000000000000000000000000000000000000000000"

    expect(AbiTestsForWeb3js.encode(type, value)).to eq data
    expect(AbiTestsForWeb3js.decode(type, data)).to eq value
  end

  it "((string)[1])" do
    type = "((string)[1])"
    value = [[["Moo é🚀 🚀Mé🚀 "]]]
    data = hex "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000174d6f6f20c3a9f09f9a8020f09f9a804dc3a9f09f9a8020000000000000000000"

    expect(AbiTestsForWeb3js.encode(type, value)).to eq data
    expect(AbiTestsForWeb3js.decode(type, data)).to eq value
  end

  it "(int[3])" do
    type = "(int[3])"
    value = [[
			"22144625395505013793541396894978047301879552760557550459710097639205924396256",
			"49014605461735350270020130074585700878308928893996551478136032661948578830694",
			"15439996497944648374711822534969745767433790445362253538804586678498669515301"
		]]
    data = hex "0x30f569ef377da0d933b91d3518fe5e9e8ba10a184b91e2ce3f660ada3f7e5ce06c5d48988598a477e664f50ae5279d0e85357f1f31c63ed8129099d2859699662222ba73c48707167f1032c7f300b25c2a487b0b60956ab060d400a175de5225"

    expect(AbiTestsForWeb3js.encode(type, value)).to eq data
    expect(AbiTestsForWeb3js.decode(type, data)).to eq value
  end
end
