defmodule Dtls.ConnectionProvider do
    use Supervisor

    def start_link(socket) do
        Supervisor.start_link(__MODULE__, socket, name: __MODULE__)
       end

    def init(socket) do
        flags = %{ :strategy => :simple_one_for_one, :intensity  => 1,
         :period => 5 }

        specs = [%{
            :id => :connectionprovider,
            start: {Dtls.Connection, :start_link, [socket]},
            restart: :temporary,
            shutdown: :brutal_kill,
            type: :worker,
            modules: [Dtls.Connection]
        }]
        {:ok, {flags, specs}}
    end

    def start_child() do
        Supervisor.start_child(__MODULE__, [])
    end

end