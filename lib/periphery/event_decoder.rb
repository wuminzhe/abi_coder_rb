require "active_support"
require "active_support/core_ext/string"

class EventDecoder
  include AbiCoderRb

  attr_reader :event_abi,
              # indexed_topic_inputs
              :indexed_topic_inputs, :indexed_topic_types,
              # data_inputs
              :data_inputs, :data_type_str, :data_field_names, :data_field_names_flattened

  def initialize(event_abi)
    @event_abi = event_abi
    @indexed_topic_inputs, @data_inputs = event_abi["inputs"].partition { |input| input["indexed"] }

    # indexed_topic_inputs:
    @indexed_topic_types = @indexed_topic_inputs.map { |input| input["type"] }

    # data_inputs:
    @data_fields = fields_of(@data_inputs)

    @data_type_str = fields_type_str(@data_fields)

    @data_field_names = fields_names(@data_fields)
    @data_field_names_flattened = fields_names_flatten(@data_fields)

    # add after_decoding action
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

  def decode_topics(topics, with_names: false)
    topics = topics[1..] if topics.count == @indexed_topic_inputs.count + 1 && @event_abi["anonymous"] == false

    raise "topics count not match" if topics.count != @indexed_topic_inputs.count

    values = topics.each_with_index.map do |topic, i|
      indexed_topic_type = @indexed_topic_types[i]
      decode(indexed_topic_type, hex_to_bin(topic))
    end

    if with_names
      combine(@indexed_topic_inputs.map { |input| input["name"].underscore }, values)
    else
      values
    end
  end

  def decode_data(data, flatten: true, with_names: false)
    return with_names ? {} : [] if @data_type_str == "()"

    data_values = decode(@data_type_str, hex_to_bin(data))

    case flatten
    when true
      if with_names
        combine(@data_field_names_flattened, data_values.flatten)
      else
        data_values.flatten
      end
    when false
      if with_names
        combine(@data_field_names, data_values)
      else
        data_values
      end
    end
  end

  private

  # fields:
  #   [
  #     ["root", "bytes32"],
  #     ["message", [["channel", "address"], ["index", "uint256"], ["fromChainId", "uint256"], ["from", "address"], ["toChainId", "uint256"], ["to", "address"], ["encoded", "bytes"]]]
  #   ]
  #
  # returns:
  #   '(bytes32,(address,uint256,uint256,address,uint256,address,bytes))'
  def fields_type_str(fields)
    "(#{
      fields.map do |_name, type|
        if type.is_a?(::Array)
          fields_type_str(type)
        else
          type
        end
      end.join(",")
    })"
  end

  # fields:
  #   [
  #     ["root", "bytes32"],
  #     ["message", [["channel", "address"], ["index", "uint256"], ["fromChainId", "uint256"], ["from", "address"], ["toChainId", "uint256"], ["to", "address"], ["encoded", "bytes"]]]
  #   ]
  #
  # returns:
  #   ["root", {"message" => ["channel", "index", "fromChainId", "from", "toChainId", "to", "gasLimit", "encoded"]}
  def fields_names(fields)
    fields.map do |name, type|
      name = name.underscore
      if type.is_a?(::Array)
        { name => fields_names(type) }
      elsif type.is_a?(::String)
        name
      end
    end
  end

  # fields:
  #   [
  #     ["root", "bytes32"],
  #     ["message", [["channel", "address"], ["index", "uint256"], ["fromChainId", "uint256"], ["from", "address"], ["toChainId", "uint256"], ["to", "address"], ["encoded", "bytes"]]]
  #   ]
  #
  # returns:
  #   ["root", "message_channel", "message_index", "message_fromChainId", "message_from", "message_toChainId", "message_to", "message_gasLimit", "message_encoded"]
  def fields_names_flatten(fields, prefix = nil)
    fields.map do |name, type|
      name = name.underscore
      if type.is_a?(::Array)
        fields_names_flatten(
          type,
          prefix.nil? ? name : "#{prefix}.#{name}"
        )
      elsif type.is_a?(::String)
        prefix.nil? ? name : "#{prefix}.#{name}"
      end
    end.flatten
  end

  # returns:
  #   [
  #     ["root", "bytes32"],
  #     ["message", [["channel", "address"], ["index", "uint256"], ["fromChainId", "uint256"], ["from", "address"], ["toChainId", "uint256"], ["to", "address"], ["encoded", "bytes"]]]
  #   ]
  def fields_of(inputs)
    inputs.map do |input|
      if input["type"] == "tuple"
        [input["name"], fields_of(input["components"])]
      elsif input["type"] == "enum"
        [input["name"], "uint8"]
      else
        [input["name"], input["type"]]
      end
    end
  end

  # params:
  #   keys = ['key1', 'key2' => ['key2_1', 'key2_2']]
  #   values = [1, [2.1, 2.2]]
  #
  # returns:
  #   {"key1"=>1, "key2"=>{"key2_1"=>2.1, "key2_2"=>2.2}}
  def combine(keys, values)
    result = {}

    keys.each_with_index do |key, index|
      if key.is_a?(Hash)
        key.each do |k, v|
          result[k] = combine(v, values[index])
        end
      else
        result[key] = values[index]
      end
    end

    result
  end
end
