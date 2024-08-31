require "spec_helper"

RSpec.describe AbiCoderRb::AbiTokenizer do
  describe '#next_token' do
    it 'tokenizes simple type' do
      tokenizer = AbiCoderRb::AbiTokenizer.new("bool")
      expect(collect_tokens(tokenizer)).to eq(["bool"])
    end

    it 'tokenizes array type' do
      tokenizer = AbiCoderRb::AbiTokenizer.new("string[3]")
      expect(collect_tokens(tokenizer)).to eq(%w(string [ 3 ]))
    end

    it 'tokenizes bytes type' do
      tokenizer = AbiCoderRb::AbiTokenizer.new("bytes3")
      expect(collect_tokens(tokenizer)).to eq(%w[bytes 3])
    end

    it 'tokenizes int type' do
      tokenizer = AbiCoderRb::AbiTokenizer.new("int8")
      expect(collect_tokens(tokenizer)).to eq(%w[int 8])
    end

    it 'tokenizes complex type' do
      tokenizer = AbiCoderRb::AbiTokenizer.new("((address,uint256[3]),bool[])")
      expect(collect_tokens(tokenizer)).to eq(%w{( ( address , uint 256 [ 3 ] ) , bool [ ] )})
    end

    it 'handles whitespace' do
      tokenizer = AbiCoderRb::AbiTokenizer.new(" ( (address,  uint256[ 3]),bool[  ] ) ")
      expect(collect_tokens(tokenizer)).to eq(%w{( ( address , uint 256 [ 3 ] ) , bool [ ] )})
    end

    it 'returns nil for empty string' do
      tokenizer = AbiCoderRb::AbiTokenizer.new("")
      expect(tokenizer.next_token).to be_nil
    end

    it 'returns nil for whitespace only' do
      tokenizer = AbiCoderRb::AbiTokenizer.new("   ")
      expect(tokenizer.next_token).to be_nil
    end
  end

  def collect_tokens(tokenizer)
    tokens = []
    while (token = tokenizer.next_token)
      tokens << token
    end
    tokens
  end
end