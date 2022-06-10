defmodule GameOfLifeWeb.GameOfLifeLive do
  @moduledoc """
  Presentation layer for Game of Life
  """
  use Phoenix.LiveView
  alias Conway.Grid
  alias Conway.TerminalGame

  def mount(_params, _session, socket) do
    {
      :ok,
      assign(
        socket,
        message: "",
        board: "",
        size: 0
      )
    }
  end

  def render(assigns) do
    ~L"""
    <div>
    Grid Dimension: <br>
     50 x 50  <input type="checkbox"  phx-click="dimension"  phx-value-dimension="50"> <br>
     20 x 20  <input type="checkbox"  phx-click="dimension"  phx-value-dimension="20"> <br>
     10 x 10  <input type="checkbox"  phx-click="dimension"  phx-value-dimension="10"> <br>
     5 x 5    <input type="checkbox"  phx-click="dimension"  phx-value-dimension="5"> <br>
    </div>

     <h2>
       <%= @message %> <br>
     </h2>

     <button phx-click="randomize">Randomize</button>

    """
  end

  def handle_event("randomize", _, socket) do
    message = "Yu start randomize"
    Grid.new(socket.assigns.size) |> TerminalGame.play("on liveview test", 10)

    {
      :noreply,
      assign(
        socket,
        message: message
      )
    }
  end

  def handle_event("dimension", %{"dimension" => dimension} = data, socket) do
    IO.inspect(data)
    message = "Your select: #{dimension} x #{dimension}  "
    dimension = String.to_integer(dimension)
    # Grid.new(dimension) |> TerminalGame.play("on liveview test", 10)
    {
      :noreply,
      assign(
        socket,
        message: message,
        size: dimension
      )
    }
  end
end
