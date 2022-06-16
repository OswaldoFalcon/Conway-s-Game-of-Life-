defmodule Sum do
  @moduledoc """
    Works on Elixir 1.0.x
    This module is based on Sasa Juric Algorithm
    With a little changes to function in Phoenix LiveView
    This module do a Sum
  """
  defstruct value: 0

  def value(%Sum{value: value}), do: value

  def add(%Sum{value: value} = sum, x) do
    %Sum{sum | value: value + x}
  end

  defimpl Collectable do
    def into(original) do
      {
        original,
        fn
          sum, {:cont, x} -> Sum.add(sum, x)
          sum, :done -> sum
          _, :halt -> :ok
        end
      }
    end
  end
end

defmodule Conway.Grid do
  @moduledoc """
    Works on Elixir 1.0.x
    This module is based on Sasa Juric Algorithm
    With a little changes to function in Phoenix LiveView
    this module Creates, Updates, the grid.
  """
  defstruct data: nil

  def new(size) when is_integer(size) and size > 0 do
    %Conway.Grid{
      data: new_data(size, fn _, _ -> :rand.uniform(2) - 1 end)
    }
  end

  def new(data) when is_list(data) do
    %Conway.Grid{data: list_to_data(data)}
  end

  def new(size, prob) when is_integer(size) and size > 0 do
    %Conway.Grid{
      data:
        new_data(size, fn _, _ ->
          if :rand.uniform(10) - 1 < prob do
            1
          else
            0
          end
        end)
    }
  end

  def size(%Conway.Grid{data: data}), do: tuple_size(data)

  def cell_status(grid, x, y) do
    grid.data
    |> elem(y)
    |> elem(x)
  end

  def next(grid) do
    %Conway.Grid{grid | data: new_data(size(grid), &next_cell_status(grid, &1, &2))}
  end

  defp new_data(size, producer_fun) do
    for y <- 0..(size - 1) do
      for x <- 0..(size - 1) do
        producer_fun.(x, y)
      end
    end
    |> list_to_data
  end

  defp list_to_data(data) do
    data
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  def next_cell_status(grid, x, y) do
    case {cell_status(grid, x, y), alive_neighbours(grid, x, y)} do
      {1, 2} -> 1
      {1, 3} -> 1
      {0, 3} -> 1
      {_, _} -> 0
    end
  end

  def change_state(grid, row, column, state) do
    new_row = put_elem(elem(grid.data, row), column, state)
    new_grid = put_elem(grid.data, row, new_row)
    %Conway.Grid{grid | data: new_grid}
  end

  defp alive_neighbours(grid, cell_x, cell_y) do
    for x <- (cell_x - 1)..(cell_x + 1),
        y <- (cell_y - 1)..(cell_y + 1),
        x in 0..(size(grid) - 1) and
          y in 0..(size(grid) - 1) and
          (x != cell_x or y != cell_y) and
          cell_status(grid, x, y) == 1,
        into: %Sum{} do
      1
    end
    |> Sum.value()
  end
end

defmodule Conway.TerminalGame do
  @moduledoc """
    Works on Elixir 1.0.x
    This module is based on Sasa Juric Algorithm
    With a little changes to function in Phoenix LiveView
    This module  Prints the
  """
  # Concurrent until button stops the function
  def play(_grid, _name, 0), do: :ok

  def play(grid, name, steps) do
    grid
    |> print(name)
    |> Conway.Grid.next()
    |> play(name, steps - 1)
  end

  def print(grid, name) do
    IO.puts(String.duplicate("\n", 100))
    IO.puts("#{name}\n")

    for y <- 0..(Conway.Grid.size(grid) - 1) do
      for x <- 0..(Conway.Grid.size(grid) - 1) do
        case Conway.Grid.cell_status(grid, x, y) do
          0 -> IO.write(" ")
          1 -> IO.write("*")
        end
      end

      IO.puts("")
    end

    :timer.sleep(200)
    grid
  end

  def playliveview(grid, name) do
    grid
    |> print(name)
    |> Conway.Grid.next()
  end
end
