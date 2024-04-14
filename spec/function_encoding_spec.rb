require "spec_helper"

RSpec.describe FunctionEncoder do
  it "can encode function" do
    result = FunctionEncoder.encode_function("baz(uint32,bool)", [69, true])
    expect(result).to eq "0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"
  end
end
