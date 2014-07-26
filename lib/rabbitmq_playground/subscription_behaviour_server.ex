defmodule RabbitmqPlayground.SubscriptionBehaviour do
  defmacro __using__(_) do
    quote do
      use GenServer
      require RabbitMQ

      def start_link(pid) do
        GenServer.start_link(__MODULE__, pid, [])
      end

      def init(pid) do
        {:ok, connection} = :amqp_connection.start(RabbitMQ.amqp_params_network(host: 'localhost'))
        {:ok, channel}    = :amqp_connection.open_channel(connection)
        {:ok, channel: channel, pid: pid}
      end

      def subscribe(pid, topic) do
        :gen_server.call(pid, {:subscribe, topic})
      end

      def handle_call({:subscribe, topic}, _from, state) do
        :amqp_channel.call(state[:channel], RabbitMQ.queue_declare(queue: topic))
        :amqp_channel.subscribe(state[:channel], RabbitMQ.basic_consume(queue: topic, no_ack: true), self())
        receive do
          RabbitMQ.basic_consume_ok() -> :ok
        end
        {:reply, :ok, state}
      end

      def handle_info(msg, state) do
        IO.inspect "handle_info"
        handle_message(msg, state)
        {:noreply, state}
      end
    end
  end
end

defmodule RabbitmqPlayground.SubscriptionBehaviourServer do
  use RabbitmqPlayground.SubscriptionBehaviour

  def handle_message(message, state) do
    IO.puts "handle_message"
    IO.inspect message
    send(state[:pid], message)
  end
end
