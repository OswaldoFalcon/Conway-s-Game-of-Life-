defmodule GameOfLifeWeb.GameOfLifeLive do
  @moduledoc """
  Presentation layer for Game of Life
  """
  use Phoenix.LiveView
  alias Conway.Grid
  alias Conway.TerminalGame
  alias GameOfLifeWeb.PageView
  @topic "grid"

  def mount(_params, _session, socket) do
    GameOfLifeWeb.Endpoint.subscribe(@topic)

    {
      :ok,
      assign(
        socket,
        message: "",
        board: "",
        size: 10,
        tref: {},
        probability: "0.2",
        on_process: false,
        row: 0,
        cell_state: "background-color:transparent;",
        current_row: 0,
        current_column: 0,
        grid: %Conway.Grid{
          data:
            {{1, 1, 0, 0, 1, 0, 0, 1, 1, 0}, {1, 1, 1, 1, 1, 0, 0, 1, 1, 1},
             {0, 0, 1, 0, 1, 1, 1, 1, 0, 1}, {1, 0, 0, 1, 1, 1, 0, 0, 0, 1},
             {0, 1, 0, 1, 0, 1, 1, 1, 0, 1}, {0, 0, 1, 0, 0, 1, 1, 0, 1, 1},
             {0, 0, 1, 1, 1, 0, 1, 1, 0, 1}, {0, 1, 0, 0, 0, 1, 0, 0, 0, 0},
             {0, 1, 1, 1, 0, 1, 0, 1, 0, 1}, {0, 0, 1, 1, 0, 0, 1, 0, 1, 1}}
        }
      )
    }
  end

  def render(assigns), do: PageView.render("gol.html", assigns)

  def handle_event("dimension", %{"dimension" => dimension}, socket) do
    message = "Your select: #{dimension} x #{dimension}  "
    dimension = String.to_integer(dimension)
    grid = Grid.new(dimension)

    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{
      grid: grid,
      size: dimension,
      message: message
    })

    {
      :noreply,
      assign(
        socket,
        message: message,
        size: dimension,
        grid: grid
      )
    }
  end

  def handle_event("go", _params, socket) do
    message = "Let's go!"
    {:ok, tref} = :timer.send_interval(100, self(), :tick)

    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{
      on_process: true,
      message: message,
      tref: tref
    })

    {
      :noreply,
      assign(
        socket,
        message: message,
        tref: tref,
        on_process: true,
        cell_state: "dead"
      )
    }
  end

  def handle_event("stop", _params, socket) do
    message = "It's stop, to START again, press the button GO "
    :timer.cancel(socket.assigns.tref)

    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{
      on_process: false,
      message: message
    })

    {
      :noreply,
      assign(
        socket,
        message: message,
        on_process: false
      )
    }
  end

  def handle_event("randomize", _params, socket) do
    message = "Randomize on  #{socket.assigns.size}  x #{socket.assigns.size} Grid"
    probability = convert_type(socket.assigns.probability) * 10
    grid = Grid.new(socket.assigns.size, probability)

    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{
      grid: grid,
      message: message
    })

    {
      :noreply,
      assign(
        socket,
        message: message,
        grid: grid
      )
    }
  end

  def handle_event("probability", %{"value" => probability}, socket) do
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{
      probability: probability
    })

    {
      :noreply,
      assign(
        socket,
        probability: probability
      )
    }
  end

  def handle_event(
        "change_state",
        %{"row" => row, "column" => column, "state" => state},
        socket
      ) do
    row = String.to_integer(row)
    column = String.to_integer(column)
    state = String.to_integer(state)
    grid = Conway.Grid.change_state(socket.assigns.grid, row, column, state)
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{grid: grid})

    {
      :noreply,
      assign(
        socket,
        grid: grid
      )
    }
  end

  def handle_info(:tick, %{assigns: %{grid: grid}} = socket) do
    grid = TerminalGame.playliveview(grid)
    message = "If you want to stop, press STOP button"

    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{
      grid: grid,
      message: message
    })

    {
      :noreply,
      assign(
        socket,
        message: message,
        grid: grid
      )
    }
  end

  def handle_info(info, socket) do
    {
      :noreply,
      assign(
        socket,
        info.payload
      )
    }
  end

  defp convert_type(number) do
    codepoints = String.codepoints(number)

    cond do
      Enum.member?(codepoints, ".") == true -> String.to_float(number)
      Enum.member?(codepoints, ".") == false -> String.to_integer(number)
    end
  end
end
