defmodule Dtls.Application do
  @moduledoc """
  Documentation for dtls.
  """
  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    :ssl.start()
    {:ok, l} = :ssl.listen(9000, [certfile: "certs/cert.pem",
                                  keyfile: "certs/key.pem",
                                  protocol: :dtls,
                                  active: true])
    children = [
      {Dtls.ConnectionProvider, l},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DtlsApp.Supervisor]
    Supervisor.start_link(children, opts)
    {:ok, _} = Dtls.ConnectionProvider.start_child()
  end
end
