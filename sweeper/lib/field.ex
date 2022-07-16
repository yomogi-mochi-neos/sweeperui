defmodule Sweeper.Field do
  defstruct location: {0, 0},
            is_bomb: false,
            number: 0,
            is_open: false

  def new(attributes \\ []), do: __struct__(attributes)

  @doc """
    `field`に`struct_field`を合成し返却する。
  """
  def merge(field, struct_field) do
    %{
      struct_field.location => %{
        is_bomb: struct_field.is_bomb,
        number: struct_field.number,
        is_open: struct_field.is_open
      }
    }
    |> Enum.into(field)
  end

  def new_struct(location) do
    %__MODULE__{
      location: location,
      is_bomb: random_bomb() and random_bomb(),
      number: 0,
      is_open: false
    }
  end

  @doc """
    新しい`field`をランダム生成する。
  """
  def new_random() do
    field =
      for x <- 0..9, y <- 0..9 do
        Map.new()
        |> merge(new_struct({x, y}))
      end
      |> Enum.reduce(fn x, acc -> Map.merge(x, acc) end)

    # numberの計算
    field
      |> Enum.map(&compute_number(field, &1))
      |> Enum.reduce(fn x, acc -> Map.merge(x, acc) end)
  end

  defp random_bomb do
    [true, false]
    |> Enum.random()
  end


  @doc """
    `{x, y}`の周囲8マスの座標を取得する。
  """
  def around(around_points, {x, y}, {dx, dy}) when dx == 0 and dy == 0 do
    around(around_points, {x, y}, compute_delta({dx, dy}))
  end

  def around(around_points, {_x, _y}, {dx, dy}) when dx > 1 and dy > 1, do: around_points

  def around(around_points, {x, y}, {dx, dy}) do
    added_points = around_points ++ [{x + dx, y + dy}]
    around(added_points, {x, y}, compute_delta({dx, dy}))
  end

  @doc """
    `field`上に存在する、`{x, y}`の周囲8マスの座標を取得する。
  """
  def get_exist_around_fields(field, point) do
    around_points = around([], point, {-1, -1})

    field
    |> Map.filter(fn {k, _} -> k in around_points end)
  end

  @doc """
    `field`上に存在する、`{x, y}`の周囲8マスの座標を取得する。

    ## Examples

    iex(1)> import Sweeper.Field
    Sweeper.Field
    iex(2)> compute_delta({-1, -1})
    {0, -1}
    iex(3)> compute_delta({0, -1})
    {1, -1}
    iex(4)> compute_delta({1, -1})
    {-1, 0}
    iex(5)> compute_delta({-1, 0})
    {0, 0}
    iex(6)> compute_delta({0, 0})
    {1, 0}
    iex(7)> compute_delta({1, 0})
    {-1, 1}
    iex(8)> compute_delta({-1, 1})
    {0, 1}
    iex(9)> compute_delta({0, 1})
    {1, 1}
  """
  def compute_delta({dx, dy}) when dx < 1 and dy <= 1, do: {dx + 1, dy}
  def compute_delta({dx, dy}) when dx == 1 and dy < 1, do: {-1, dy + 1}
  def compute_delta({dx, dy}) when dx == 1 and dy == 1, do: {dx + 1, dy + 1}


  @doc """
    `number`を計算する。
    `exactly_field`の周囲8マスにある`is_bomb`を持つ`field`の数を数える。
  """
  def compute_number(field, exactly_field) do
    exactly_key = elem(exactly_field, 0)

    bomb_count =
      field
      |> get_exist_around_fields(exactly_key)
      |> Map.filter(fn {_, v} -> v.is_bomb end)
      |> Enum.count()

    exactly_value = elem(exactly_field, 1)

    %{exactly_key => Map.put(exactly_value, :number, bomb_count)}
  end

  @doc """
    `number`が0のフィールドを連鎖的に開く。
    開いたフィールドの`number`が0場合、さらにその周囲を開く。
  """
  def open_fields_chained(field, should_open_keys) when should_open_keys == [], do: field
  def open_fields_chained(field, should_open_keys) do
    [point | other] = should_open_keys

    new_value =
      field
      |> open_field(point)

    new_field =
      field
      |> Map.put(point, new_value)

    %{is_bomb: is_bomb, number: number} = new_value

    around_should_open_keys =
      if number == 0 && !is_bomb do
        new_field
        |> get_exist_around_fields(point)
        |> Map.filter(fn {_, v} -> !v.is_open end)
        |> Map.keys()
      else
        []
      end

    new_should_open_keys = other ++ around_should_open_keys
    open_fields_chained(new_field, new_should_open_keys)
  end

  @doc """
    フィールドを開く。
  """
  def open_field(field, point) do
    field
    |> Map.fetch!(point)
    |> Map.put(:is_open, true)
  end

  defimpl Inspect, for: Sweeper.Field do
    import Inspect.Algebra

    def inspect(field, _opts) do
      concat([
        "location: ",
        inspect(field.location),
        " ",
        "is_bomb: ",
        inspect(field.is_bomb),
        " ",
        "number: ",
        inspect(field.number),
        " ",
        "is_open: ",
        inspect(field.is_open)
      ])
    end
  end
end
