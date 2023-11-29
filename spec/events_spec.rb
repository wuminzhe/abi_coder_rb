require "spec_helper"

RSpec.describe EventDecoder do
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

    event_decoder = EventDecoder.new(event_abi)

    # data
    # https://sepolia.arbiscan.io/tx/0x505ab955a67a26a3aebbb1623ff9ee571c453b70e92c6131cb82c9755993cab7#eventlog
    topics = ["0x7230c950337b2a02b9ec21bcf8aa09e4933dad2cd8ec86686fe6877ee19a8896"]
    data = "0x08682caa96c39f78514e656f97444693e2bb6da6359d31130c809b4b010bf207" \
             "0000000000000000000000000000000000000000000000000000000000000040" \
             "00000000000000000000000000000000001523057a05d6293c1e5171ee33ee0a" \
             "0000000000000000000000000000000000000000000000000000000000000000" \
             "0000000000000000000000000000000000000000000000000000000000066eee" \
             "0000000000000000000000000000000000d2de3e2444926c4577b0a59f1dd8bc" \
             "000000000000000000000000000000000000000000000000000000000000002c" \
             "0000000000000000000000000000000000d2de3e2444926c4577b0a59f1dd8bc" \
             "000000000000000000000000000000000000000000000000000000000007a120" \
             "0000000000000000000000000000000000000000000000000000000000000100" \
             "00000000000000000000000000000000000000000000000000000000000000a4" \
             "394d1bca0000000000000000000000009f33a4809aa708d7a399fedba514e0a0" \
             "d15efa85000000000000000000000000313ac72074274d6876019b25a306f2b6" \
             "4aba44dd00000000000000000000000000000000000000000000000000000000" \
             "0000006000000000000000000000000000000000000000000000000000000000" \
             "0000000212340000000000000000000000000000000000000000000000000000" \
             "0000000000000000000000000000000000000000000000000000000000000000"

    expect(event_decoder.decode_topics(topics)).to eq ["0x7230c950337b2a02b9ec21bcf8aa09e4933dad2cd8ec86686fe6877ee19a8896"]
    expect(event_decoder.decode_topics(topics, with_names: true))
      .to eq({ "msg_hash" => "0x7230c950337b2a02b9ec21bcf8aa09e4933dad2cd8ec86686fe6877ee19a8896" })

    # flatten: true, with_names: false
    expect(event_decoder.decode_data(data)).to eq [
      "0x08682caa96c39f78514e656f97444693e2bb6da6359d31130c809b4b010bf207",
      "0x00000000001523057a05d6293c1e5171ee33ee0a",
      0,
      421_614,
      "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
      44,
      "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
      500_000,
      "0x394d1bca0000000000000000000000009f33a4809aa708d7a399fedba514e0a0d15efa85000000000000000000000000313ac72074274d6876019b25a306f2b64aba44dd000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000"
    ]

    # flatten: true, with_names: true
    expect(event_decoder.decode_data(data, with_names: true))
      .to eq({
               "root" => "0x08682caa96c39f78514e656f97444693e2bb6da6359d31130c809b4b010bf207",
               "message.channel" => "0x00000000001523057a05d6293c1e5171ee33ee0a",
               "message.index" => 0,
               "message.from_chain_id" => 421_614,
               "message.from" => "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
               "message.to_chain_id" => 44,
               "message.to" => "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
               "message.gas_limit" => 500_000,
               "message.encoded" => "0x394d1bca0000000000000000000000009f33a4809aa708d7a399fedba514e0a0d15efa85000000000000000000000000313ac72074274d6876019b25a306f2b64aba44dd000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000"
             })

    # flatten: false, with_names: false
    expect(event_decoder.decode_data(data, flatten: false)).to eq [
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

    # flatten: false, with_names: true
    expect(event_decoder.decode_data(data, flatten: false, with_names: true))
      .to eq({
               "root" => "0x08682caa96c39f78514e656f97444693e2bb6da6359d31130c809b4b010bf207",
               "message" => {
                 "channel" => "0x00000000001523057a05d6293c1e5171ee33ee0a",
                 "index" => 0,
                 "from_chain_id" => 421_614,
                 "from" => "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
                 "to_chain_id" => 44,
                 "to" => "0x0000000000d2de3e2444926c4577b0a59f1dd8bc",
                 "gas_limit" => 500_000,
                 "encoded" => "0x394d1bca0000000000000000000000009f33a4809aa708d7a399fedba514e0a0d15efa85000000000000000000000000313ac72074274d6876019b25a306f2b64aba44dd000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000"
               }
             })
  end

  it "can decode event 2" do
    event_abi = {
      "anonymous" => false,
      "inputs" => [
        {
          "components" => [
            {
              "internalType" => "address",
              "name" => "to",
              "type" => "address"
            },
            {
              "components" => [
                {
                  "internalType" => "string",
                  "name" => "name",
                  "type" => "string"
                }
              ],
              "internalType" => "struct Abi.User",
              "name" => "user",
              "type" => "tuple"
            }
          ],
          "indexed" => false,
          "internalType" => "struct Abi.Message",
          "name" => "message",
          "type" => "tuple"
        }
      ],
      "name" => "PrintMessage",
      "type" => "event"
    }

    event_decoder = EventDecoder.new(event_abi)

    data = "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000005416c696365000000000000000000000000000000000000000000000000000000"

    # flatten: true, with_names: false
    expect(event_decoder.decode_data(data)).to eq %w[0x5b38da6a701c568545dcfcb03fcb875f56beddc4 Alice]

    # flatten: true, with_names: true
    expect(event_decoder.decode_data(data, with_names: true))
      .to eq(
        {
          "message.to" => "0x5b38da6a701c568545dcfcb03fcb875f56beddc4",
          "message.user.name" => "Alice"
        }
      )

    # flatten: false, with_names: false
    expect(event_decoder.decode_data(data, flatten: false))
      .to eq [
        ["0x5b38da6a701c568545dcfcb03fcb875f56beddc4", ["Alice"]]
      ]

    # flatten: false, with_names: true
    expect(event_decoder.decode_data(data, flatten: false, with_names: true))
      .to eq(
        {
          "message" => {
            "to" => "0x5b38da6a701c568545dcfcb03fcb875f56beddc4",
            "user" => {
              "name" => "Alice"
            }
          }
        }
      )
  end
end
