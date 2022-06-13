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
        size: 5,
        tref: {},
        probability: "0.2",
        grid: %Conway.Grid{
          data:
            {{0, 1, 0, 0, 0}, {0, 0, 0, 0, 1}, {1, 0, 1, 0, 1}, {1, 1, 1, 1, 0}, {0, 1, 0, 1, 1}}
        }
      )
    }
  end

  def render(assigns), do: PageView.render("gol.html", assigns)

  def handle_event("dimension", %{"dimension" => dimension} = data, socket) do
    IO.inspect(data)

    message = "Your select: #{dimension} x #{dimension}  "
    dimension = String.to_integer(dimension)
    grid = Grid.new(dimension)
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{grid: grid})

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
    {:ok, tref} = :timer.send_interval(1000, self(), :tick)

    {
      :noreply,
      assign(
        socket,
        message: message,
        tref: tref
      )
    }
  end

  def handle_event("stop", _params, socket) do
    message = "It's stop, to START again, press the button GO "
    :timer.cancel(socket.assigns.tref)

    {
      :noreply,
      assign(
        socket,
        message: message
      )
    }
  end

  def handle_event("randomize", _params, socket) do
    message = "Randomize on  #{socket.assigns.size}  x #{socket.assigns.size} Grid"
    probability = convert_type(socket.assigns.probability) * 10
    grid = Grid.new(socket.assigns.size, probability)
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{grid: grid})

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
    {
      :noreply,
      assign(
        socket,
        probability: probability
      )
    }
  end

  def handle_info(:tick, %{assigns: %{grid: grid}} = socket) do
    grid = TerminalGame.playliveview(grid, "Displaying with livewView")
    message = "If you want to stop, press STOP button"
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "update_grid", %{grid: grid})

    {
      :noreply,
      assign(
        socket,
        message: message,
        grid: grid
      )
    }
  end

  def handle_info(%{topic: @topic, payload: payload}, socket) do
    {
      :noreply,
      assign(
        socket,
        :grid,
        payload.grid
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
