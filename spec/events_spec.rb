require "spec_helper"
require "json"

class EventCoder
  include AbiCoderRb

  def initialize(event_abi)
    @event_abi = event_abi
    @indexed_topic_inputs, @data_inputs = event_abi["inputs"].partition { |input| input["indexed"] }
    @indexed_topic_types = @indexed_topic_inputs.map { |input| input["type"] }
    @data_type_str = inputs_to_type_str(@data_inputs)

    after_decoding lambda { |type, value|
      if type == "address"
        "0x#{value}"
      elsif type.start_with?("bytes")
        "0x#{bin_to_hex(value)}"
      else
        value
      end
    }
  end

  def decode_topics(topics)
    topics = topics[1..] if topics.count == @indexed_topic_inputs.count + 1 && @event_abi["anonymous"] == false

    raise "topics count not match" if topics.count != @indexed_topic_inputs.count

    topics.each_with_index.map do |topic, i|
      indexed_topic_type = @indexed_topic_types[i]
      decode(indexed_topic_type, hex_to_bin(topic))
    end
  end

  def decode_data(data)
    decode(@data_type_str, hex_to_bin(data))
  end

  private

  # inputs: [
  #   {
  #     "components"=>[
  #       {"internalType"=>"address", "name"=>"channel", "type"=>"address"},
  #       {"internalType"=>"uint256", "name"=>"index", "type"=>"uint256"},
  #       {"internalType"=>"uint256", "name"=>"fromChainId", "type"=>"uint256"},
  #       {"internalType"=>"address", "name"=>"from", "type"=>"address"},
  #       {"internalType"=>"uint256", "name"=>"toChainId", "type"=>"uint256"},
  #       {"internalType"=>"address", "name"=>"to", "type"=>"address"},
  #       {"internalType"=>"bytes", "name"=>"encoded", "type"=>"bytes"}
  #     ],
  #     "internalType"=>"struct Message",
  #     "name"=>"message",
  #     "type"=>"tuple"
  #   }
  # ]
  # returns: '((address,uint256,uint256,address,uint256,address,bytes))'
  def inputs_to_type_str(inputs)
    types =
      inputs.map do |input|
        if input["type"] == "tuple"
          inputs_to_type_str(input["components"])
        elsif input["type"] == "enum"
          "uint8"
        else
          input["type"]
        end
      end

    "(#{types.join(",")})"
  end
end

RSpec.describe EventCoder do
  it "can decode event" do
    # MessageAccepted (index_topic_1 bytes32 msgHash, bytes32 root, tuple message)
    event_abi = {
      "anonymous" => false,
      "inputs" => [
        {
          "indexed" => true,
          "internalType" => "bytes32",
          "name" => "msgHash",
          "type" => "bytes32"
        },
        {
          "indexed" => false,
          "internalType" => "bytes32",
          "name" => "root",
          "type" => "bytes32"
        },
        {
          "components" => [
            {
              "internalType" => "address",
              "name" => "channel",
              "type" => "address"
            },
            {
              "internalType" => "uint256",
              "name" => "index",
              "type" => "uint256"
            },
            {
              "internalType" => "uint256",
              "name" => "fromChainId",
              "type" => "uint256"
            },
            {
              "internalType" => "address",
              "name" => "from",
              "type" => "address"
            },
            {
              "internalType" => "uint256",
              "name" => "toChainId",
              "type" => "uint256"
            },
            {
              "internalType" => "address",
              "name" => "to",
              "type" => "address"
            },
            {
              "internalType" => "uint256",
              "name" => "gasLimit",
              "type" => "uint256"
            },
            {
              "internalType" => "bytes",
              "name" => "encoded",
              "type" => "bytes"
            }
          ],
          "indexed" => false,
          "internalType" => "struct Message",
          "name" => "message",
          "type" => "tuple"
        }
      ],
      "name" => "MessageAccepted",
      "type" => "event"
    }

    event_coder = EventCoder.new(event_abi)

    # data
    # https://sepolia.arbiscan.io/tx/0x505ab955a67a26a3aebbb1623ff9ee571c453b70e92c6131cb82c9755993cab7#eventlog
    topics = ["0x7230c950337b2a02b9ec21bcf8aa09e4933dad2cd8ec86686fe6877ee19a8896"]
    data = "0x08682caa96c39f78514e656f97444693e2bb6da6359d31130c809b4b010bf207000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000001523057a05d6293c1e5171ee33ee0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066eee0000000000000000000000000000000000d2de3e2444926c4577b0a59f1dd8bc000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000d2de3e2444926c4577b0a59f1dd8bc000000000000000000000000000000000000000000000000000000000007a120000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000a4394d1bca0000000000000000000000009f33a4809aa708d7a399fedba514e0a0d15efa85000000000000000000000000313ac72074274d6876019b25a306f2b64aba44dd00000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000002123400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

    expect(event_coder.decode_topics(topics)).to eq ["0x7230c950337b2a02b9ec21bcf8aa09e4933dad2cd8ec86686fe6877ee19a8896"]

    expect(event_coder.decode_data(data)).to eq [
      "0x08682caa96c39f78514e656f97444693e2bb6da6359d31130c809b4b010bf207",
      [
        "0x00000000001523057a05d6293c1e5171ee33ee0a",
        0,
        421_614,
        "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
        44,
        "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
        500_000,
        "0x394d1bca0000000000000000000000009f33a4809aa708d7a399fedba514e0a0d15efa85000000000000000000000000313ac72074274d6876019b25a306f2b64aba44dd000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000"
      ]
    ]
  end
end
