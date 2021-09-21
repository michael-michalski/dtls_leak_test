defmodule DtlsLeakTestTest do
  use ExUnit.Case
  require Logger

  @run_time_seconds 50

  @tag timeout: :infinity
  test "greets the world" do
    :dbg.start()
    :dbg.tracer(:process, {fn msg, n -> File.write("trace_ssl_gen_statem.txt", "#{inspect msg}\n", [:append]); n+1 end, 0})
    :dbg.tpl(:ssl_gen_statem, :_, [])
    :dbg.p(:all, :c)

    Logger.info("Before Process count: #{Process.list |> length()}")
    processes = Process.list()

    {:ok, s} = :ssl.connect('localhost', 9000, [protocol: :dtls, active: false])

    Process.sleep(1000)
    process_info_list_before = Enum.map(Process.list() -- processes, fn pid -> Process.info(pid) end)

    Benchee.run(
    %{
        "send" => fn ->
            :ssl.send(s, "ping")
            {:ok, data} = :ssl.recv(s, 4)
          end,
        }, time: @run_time_seconds
      )

    :dbg.stop_clear()

    process_info_list_after = Enum.map(Process.list() -- processes, fn pid -> Process.info(pid) end)

    assert ^process_info_list_before = process_info_list_after
  end
end
