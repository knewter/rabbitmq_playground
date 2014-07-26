defmodule RabbitMQ.Framing do
  require Record
  Record.defrecord :pbasic, :'P_basic', Record.extract(:'P_basic', from_lib: "rabbit_common/include/rabbit_framing.hrl")
end

defmodule RabbitMQ do
  require Record
  require RabbitMQ.Framing
  alias RabbitMQ.Framing

  Record.defrecord :amqp_params_network, Record.extract(:amqp_params_network, from_lib: "amqp_client/include/amqp_client.hrl")
	Record.defrecord :queue_declare, :'queue.declare', Record.extract(:'queue.declare', from_lib: "rabbit_common/include/rabbit_framing.hrl")
  Record.defrecord :basic_publish, :'basic.publish', Record.extract(:'basic.publish', from_lib: "rabbit_common/include/rabbit_framing.hrl")
	Record.defrecord :amqp_msg, [props: Framing.pbasic(), payload: ""]
	Record.defrecord :basic_consume, :'basic.consume', Record.extract(:'basic.consume', from_lib: "rabbit_common/include/rabbit_framing.hrl")
  Record.defrecord :basic_consume_ok, :'basic.consume_ok', Record.extract(:'basic.consume_ok', from_lib: "rabbit_common/include/rabbit_framing.hrl")
  Record.defrecord :basic_deliver, :'basic.deliver', Record.extract(:'basic.deliver', from_lib: "rabbit_common/include/rabbit_framing.hrl")
end
