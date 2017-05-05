defmodule Sableye.Home do
  import Plug.Conn

  def home(conn) do
    send_resp(conn, 200, :templates.index([name: "Zeyi"]))
  end
end
