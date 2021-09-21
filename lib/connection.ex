defmodule Dtls.Connection do
  use GenServer
  require Logger

  def start_link(sock) do
      GenServer.start_link(__MODULE__, [sock])
  end

  def init([sock]) do
    IO.puts "init"
      Logger.info "Starting new connection"
      {:ok, sock, 0}
  end

  def handle_info(:timeout, l) do
      Logger.info "timeout"

      {:ok, s} = :ssl.transport_accept(l)
      Dtls.ConnectionProvider.start_child() # spawn another connection handler
      {:ok, _so} = :ssl.handshake(s)
      {:noreply, s}
  end

  def handle_info({:ssl, sslsocket, data}, state) do
      :ssl.send(sslsocket, "pong")
      {:noreply, state}
  end

  def handle_info({:ssl_closed, _sslsocket}, state) do
      Logger.info "ssl connection is closed"
      {:stop, :normal, state}
  end

  def handle_info({:ssl_error, _sslsocket, _reason}, state) do
      {:stop, :normal, state}
  end
end
