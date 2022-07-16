defmodule SweeperuiWeb.PageController do
  use SweeperuiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
