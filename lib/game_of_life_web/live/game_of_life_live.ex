defmodule GameOfLifeWeb.GameOfLifeLive do
  @moduledoc """
  Presentation layer for Game of Life
  """
  use Phoenix.LiveView
  alias Conway.Grid
  alias Conway.TerminalGame
  @topic "calc"

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
        probability: 0 , 
        grid: %Conway.Grid{
          data:
            {{0, 1, 0, 0, 0}, {0, 0, 0, 0, 1}, {1, 0, 1, 0, 1}, {1, 1, 1, 1, 0}, {0, 1, 0, 1, 1}}
        }
      )
    }
  end

  def render(assigns) do
    ~L"""
    <div class= "container">
      <div class = "grid_size" >
        <div> Grid Dimension: </div> 
        <div> 50 x 50 </div> <input type="checkbox"  phx-click="dimension"  phx-value-dimension="50"> <br>
        <div> 20 x 20 </div> <input type="checkbox"  phx-click="dimension"  phx-value-dimension="20"> <br>
        <div> 10 x 10 </div> <input type="checkbox"  phx-click="dimension"  phx-value-dimension="10"> <br>
        <div> 10 x 10 </div> <input type="checkbox"  phx-click="dimension"  phx-value-dimension="5"> <br>
      </div>
       <p>
         <%= @message %> <br>
       </p>
       <div class="board-container">
          <div class="board">
            <%= for y <- 0..(Conway.Grid.size(@grid) - 1) do %>
              <div class="row"> 
                <%= for  x <- 0..(Conway.Grid.size(@grid)- 1) do %>
                  <div class="cell"> 
                  <%= case Conway.Grid.cell_status(@grid, x, y) do %>
                    <% 0 -> %> <div class = "dead"> </div>
                    <% 1 -> %> <div class = "alive" > </div>
                  <% end%>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
        <div class = "buttons">
          <button phx-click="go"> Go </button>  
          <button phx-click="stop"> Stop </button>  
          <div class="slidecontainer">
            <button phx-click="randomize"> Randomize </button>        
            <input type="range" min="0" max="10" value="1" class="slider" id="myRange" >
            the probability is <%= @probability %>
            </div>  
        </div>
    </div >
    """
  end

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
    message = "amonos"
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
    message = "It's stop, to START again, press the button "
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

   def handle_event("probability",%{"probability" => probability}, socket) do
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
    message = "If yu want to stop press STOP button"
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
end
