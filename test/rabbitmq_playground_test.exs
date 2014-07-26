defmodule RabbitmqPlaygroundTest do
  use ExUnit.Case
  require RabbitMQ

  setup_all do
    {:ok, connection} = :amqp_connection.start(RabbitMQ.amqp_params_network(host: 'localhost'))
    {:ok, channel}    = :amqp_connection.open_channel(connection)
    :amqp_channel.call(channel, RabbitMQ.queue_declare(queue: "generic"))
    {:ok, channel: channel}
  end

  test "publishing a message", meta do
    :amqp_channel.subscribe(meta[:channel], RabbitMQ.basic_consume(queue: "generic", no_ack: true), self())
    receive do
      RabbitMQ.basic_consume_ok() -> :ok
    end
    :amqp_channel.cast(meta[:channel], RabbitMQ.basic_publish(exchange: "", routing_key: "generic"), RabbitMQ.amqp_msg(payload: "Hello world!"))
    assert_receive {_, RabbitMQ.amqp_msg(payload: "Hello world!")}
  end
end
