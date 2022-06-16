defmodule ConwayTest do
  use ExUnit.Case
  alias Conway.Grid
  alias Conway.TerminalGame
  alias Sum

  describe "conway_grid" do
    test "gird_size" do
      grid = Grid.new(5)
      assert tuple_size(grid.data) == 5
    end

    test "new_grid_data" do
      data = [[1, 1, 0], [1, 1, 0], [1, 1, 0]]
      assert Grid.new(data) == %Conway.Grid{data: {{1, 1, 0}, {1, 1, 0}, {1, 1, 0}}}
    end

    test "new_size_prob_10" do
      assert Grid.new(2, 10) == %Conway.Grid{data: {{1, 1}, {1, 1}}}
    end

    test "new_size_prob_0" do
      assert Grid.new(2, 0) == %Conway.Grid{data: {{0, 0}, {0, 0}}}
    end

    test "size" do
      assert Grid.size(%Conway.Grid{data: {{1, 1, 0}, {1, 1, 0}, {1, 1, 0}}}) == 3
    end

    test "next_grid" do
      assert Conway.Grid.next(%Conway.Grid{data: {{1, 1, 0}, {1, 1, 0}, {1, 1, 0}}}) ==
               %Conway.Grid{data: {{1, 1, 0}, {0, 0, 1}, {1, 1, 0}}}
    end

    test "change cell state" do
      grid = %Conway.Grid{data: {{1, 1, 0}, {0, 0, 1}, {1, 1, 0}}}
      row = 1
      column = 0
      state = 1

      assert Conway.Grid.change_state(grid, row, column, state) == %Conway.Grid{
               data: {{1, 1, 0}, {1, 0, 1}, {1, 1, 0}}
             }
    end
  end

  test "play" do
    grid = %Conway.Grid{
      data: {{1, 0, 0, 0, 0}, {1, 0, 0, 0, 1}, {0, 0, 1, 1, 1}, {1, 0, 0, 1, 0}, {0, 1, 0, 1, 1}}
    }

    assert :ok == TerminalGame.play(grid, "test", 2)
  end
end
