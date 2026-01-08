defmodule AskOuijaTest do
  use ExUnit.Case
  doctest AskOuija

  test "greets the world" do
    assert AskOuija.hello() == :world
  end
end
