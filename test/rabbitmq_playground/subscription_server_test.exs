defmodule RabbitmqPlayground.SubscriptionServerTest do
  use ExUnit.Case
  require RabbitMQ
  alias RabbitmqPlayground.SubscriptionServer

  test "subscribing a function for a given topic" do
    # TODO: Make this a behaviour rather than a ridiculous callback style
    me = self()
    topic = "foo"
    SubscriptionServer.start(%{topic: topic, handler: fn(payload) -> send(me, payload) end})
    {:ok, connection} = :amqp_connection.start(RabbitMQ.amqp_params_network(host: 'localhost'))
    {:ok, channel}    = :amqp_connection.open_channel(connection)
    :amqp_channel.call(channel, RabbitMQ.queue_declare(queue: topic))
    :amqp_channel.cast(channel, RabbitMQ.basic_publish(exchange: "", routing_key: topic), RabbitMQ.amqp_msg(payload: "Hello world!"))
    assert_receive "Hello world!"
  end
end
