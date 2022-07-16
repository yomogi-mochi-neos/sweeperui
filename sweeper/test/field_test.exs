defmodule FieldTest do
  use ExUnit.Case

  import Sweeper.Field

  test "inspect field struct" do
    actual = new_field() |> inspect

    assert "#{actual}" == "location: {0, 0} is_bomb: false number: 0 is_open: false"
  end

  test "merge field" do
    one_actual = merge(%{}, new_field())
    assert one_actual == %{{0, 0} => %{is_bomb: false, number: 0, is_open: false}}

    two_actual = merge(one_actual, new_field(location: {1, 0}))

    assert two_actual == %{
             {0, 0} => %{is_bomb: false, number: 0, is_open: false},
             {1, 0} => %{is_bomb: false, number: 0, is_open: false}
           }
  end

  test "create new random" do
    count = new_random() |> Map.keys |> Enum.count()

    assert count == 100
  end

  test "compute_delta" do
    assert compute_delta({0, -1}) == {1, -1}
    assert compute_delta({1, -1}) == {-1, 0}
  end

  test "get exist around fields" do
    field = %{
      {0, 0} => %{is_bomb: false, number: 0, is_open: false},
      {1, 0} => %{is_bomb: true, number: 0, is_open: false},
      {2, 0} => %{is_bomb: false, number: 0, is_open: false},
    }

    actual =
      field
        |> get_exist_around_fields({0, 0})

    assert actual == %{{1, 0} => %{is_bomb: true, number: 0, is_open: false}}
  end

  test "compute number" do
    field = %{
      {0, 0} => %{is_bomb: false, number: 0, is_open: false},
      {1, 0} => %{is_bomb: true, number: 0, is_open: false},
      {2, 0} => %{is_bomb: false, number: 0, is_open: false},
    }

    actual =
      field
        |> Enum.map(& compute_number(field, &1))
        |> Enum.reduce(fn (x, acc) -> Map.merge(x, acc) end)

    expected = %{
      {0, 0} => %{is_bomb: false, number: 1, is_open: false},
      {1, 0} => %{is_bomb: true, number: 0, is_open: false},
      {2, 0} => %{is_bomb: false, number: 1, is_open: false},
    }

    assert actual == expected
  end

  test "more compute number" do
    field = %{
      {0, 0} => %{is_bomb: false, number: 0, is_open: false},
      {1, 0} => %{is_bomb: true, number: 0, is_open: false},
      {2, 0} => %{is_bomb: false, number: 0, is_open: false},
      {0, 1} => %{is_bomb: false, number: 0, is_open: false},
      {1, 1} => %{is_bomb: true, number: 0, is_open: false},
      {2, 1} => %{is_bomb: false, number: 0, is_open: false},
      {0, 2} => %{is_bomb: false, number: 0, is_open: false},
      {1, 2} => %{is_bomb: true, number: 0, is_open: false},
      {2, 2} => %{is_bomb: false, number: 0, is_open: false},
    }

    actual =
      field
        |> Enum.map(& compute_number(field, &1))
        |> Enum.reduce(fn (x, acc) -> Map.merge(x, acc) end)

    expected = %{
      {0, 0} => %{is_bomb: false, number: 2, is_open: false},
      {1, 0} => %{is_bomb: true, number: 1, is_open: false},
      {2, 0} => %{is_bomb: false, number: 2, is_open: false},
      {0, 1} => %{is_bomb: false, number: 3, is_open: false},
      {1, 1} => %{is_bomb: true, number: 2, is_open: false},
      {2, 1} => %{is_bomb: false, number: 3, is_open: false},
      {0, 2} => %{is_bomb: false, number: 2, is_open: false},
      {1, 2} => %{is_bomb: true, number: 1, is_open: false},
      {2, 2} => %{is_bomb: false, number: 2, is_open: false},
    }

    assert actual == expected
  end

  test "open field" do
    field = %{
      {0, 0} => %{is_bomb: false, number: 0, is_open: false},
      {1, 0} => %{is_bomb: true, number: 0, is_open: false},
      {2, 0} => %{is_bomb: false, number: 0, is_open: false},
    }

    actual =
      field
        |> open_field({1, 0})

    expected = %{is_bomb: true, number: 0, is_open: true}

    assert actual == expected
  end

  test "open fields chained" do
    field = %{
      {0, 0} => %{is_bomb: false, number: 0, is_open: false},
      {1, 0} => %{is_bomb: false, number: 0, is_open: false},
      {2, 0} => %{is_bomb: false, number: 0, is_open: false},
      {0, 1} => %{is_bomb: false, number: 0, is_open: false},
      {1, 1} => %{is_bomb: false, number: 0, is_open: false},
      {2, 1} => %{is_bomb: false, number: 0, is_open: false},
      {0, 2} => %{is_bomb: false, number: 0, is_open: false},
      {1, 2} => %{is_bomb: false, number: 0, is_open: false},
      {2, 2} => %{is_bomb: false, number: 0, is_open: false},
    }

    should_open_keys = [{0, 0}]

    actual =
      field
        |> open_fields_chained(should_open_keys)

    expected = %{
      {0, 0} => %{is_bomb: false, number: 0, is_open: true},
      {1, 0} => %{is_bomb: false, number: 0, is_open: true},
      {2, 0} => %{is_bomb: false, number: 0, is_open: true},
      {0, 1} => %{is_bomb: false, number: 0, is_open: true},
      {1, 1} => %{is_bomb: false, number: 0, is_open: true},
      {2, 1} => %{is_bomb: false, number: 0, is_open: true},
      {0, 2} => %{is_bomb: false, number: 0, is_open: true},
      {1, 2} => %{is_bomb: false, number: 0, is_open: true},
      {2, 2} => %{is_bomb: false, number: 0, is_open: true},
    }

    assert actual == expected
  end

  def new_field(attributes \\ []), do: new(attributes)
end
