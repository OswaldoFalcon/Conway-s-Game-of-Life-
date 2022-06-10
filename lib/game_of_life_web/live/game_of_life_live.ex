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
        size: 5,
        tref: {},
        grid: %Conway.Grid{
          data:
            {{0, 1, 0, 0, 0}, {0, 0, 0, 0, 1}, {1, 0, 1, 0, 1}, {1, 1, 1, 1, 0}, {0, 1, 0, 1, 1}}
        }
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

     <div class="board-container">
        <div class="board">
          <%= for y <- 0..(Conway.Grid.size(@grid) - 1) do %>
            <div class="row"> □
              <%= for  x <- 0..(Conway.Grid.size(@grid)- 1) do %>
                <div class="cell"> 
                <%= case Conway.Grid.cell_status(@grid, x, y) do %>
                  <% 0 -> %> □
                  <% 1 -> %> ■
                <% end%>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>


      <button phx-click="go">Go</button>  
      <button phx-click="stop">Stop</button>  
      <button phx-click="randomize">Randomize</button>  

    """
  end

  # def handle_event("randomize", _, socket) do
  #   message = "Yu start randomize"
  #   grid = TerminalGame.playliveview(socket.assigns.grid,"on livewviw")
  #   {
  #     :noreply,
  #     assign(
  #       socket,
  #       message: message,
  #       grid: grid,
  #     )
  #   }
  # end

  # def 

  def handle_event("dimension", %{"dimension" => dimension} = data, socket) do
    IO.inspect(data)
    message = "Your select: #{dimension} x #{dimension}  "
    dimension = String.to_integer(dimension)
    grid = Grid.new(dimension)

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
    message = "amono"
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
    message = "quiero parar "
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
    message = "Randomize on  #{socket.assigns.size}  x #{socket.assigns.size}"

    grid = Grid.new(socket.assigns.size)

    {
      :noreply,
      assign(
        socket,
        message: message,
        grid: grid
      )
    }
  end

  def handle_info(:tick, %{assigns: %{grid: grid}} = socket) do
    # spawn(TerminalGame, :play, [])
    grid = TerminalGame.playliveview(grid, "Displaying with livewView")
    # message = "#{self()}"
    message = "If yu want to stop press STOP button"
    # {:noreply, socket |> assign(:grid, grid)}
    {
      :noreply,
      assign(
        socket,
        message: message,
        grid: grid
      )
    }
  end
end
