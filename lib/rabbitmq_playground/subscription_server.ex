# LOL CALLBACKS
defmodule RabbitmqPlayground.SubscriptionServer do
  require RabbitMQ

  def start(%{topic: topic, handler: callback}) do
    spawn(__MODULE__, :await, [topic, callback])
  end

  def await(topic, callback) do
    {:ok, connection} = :amqp_connection.start(RabbitMQ.amqp_params_network(host: 'localhost'))
    {:ok, channel}    = :amqp_connection.open_channel(connection)
    :amqp_channel.call(channel, RabbitMQ.queue_declare(queue: topic))
    :amqp_channel.subscribe(channel, RabbitMQ.basic_consume(queue: topic, no_ack: true), self())
    receive do
      RabbitMQ.basic_consume_ok() -> :ok
    end
    loop(callback)
  end

  def loop(callback) do
    receive do
      {_, amqp_message} ->
        callback.(RabbitMQ.amqp_msg(amqp_message, :payload))
    end
    loop(callback)
  end
end
