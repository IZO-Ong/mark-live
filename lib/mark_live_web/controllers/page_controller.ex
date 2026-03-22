defmodule MarkLiveWeb.PageController do
  use MarkLiveWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
