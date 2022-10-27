defmodule FlukyChatWeb.PageController do
  use FlukyChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
