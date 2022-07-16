defmodule SweeperuiWeb.SweeperLive do
  use Phoenix.LiveView
  import Phoenix.HTML, only: [raw: 1]

  @debug true
  @box_width 32
  @box_height 32

  def mount(_session, _, socket), do: {:ok, start_game(socket)}

  # ゲーム実行中のrender
  def render(%{state: :playing} = assigns) do
    ~L"""
      <div style="width: 320px; margin: auto;">
        <h1 style="text-align: center;">Sweeper</h1>
        <div style="display: inline-flex; flex-wrap: wrap;">
          <%= raw svgs(@field, @state) %>
        </div>
      </div>
      <%= debug(assigns) %>
    """
  end

  # ゲーム開始前のrender
  def render(%{state: :starting} = assigns) do
    ~L"""
      <div style="width: 640px; margin: auto;">
        <h1 style="text-align: center;">Welcome to Sweeper!</h1>
        <div style="text-align: center;">
          <button phx-click="start">Start</button>
        </div>
      </div>
    """
  end

  # ゲームオーバー時のrender
  def render(%{state: :game_over} = assigns) do
    ~L"""
      <div style="width: 320px; margin: auto;">
        <h1 style="text-align: center;">Game Over</h1>
        <div style="display: inline-flex; flex-wrap: wrap; margin-bottom: 24px;">
          <%= raw svgs(@field, @state) %>
        </div>
        <div style="text-align: center;">
          <button phx-click="start">Play again?</button>
        </div>
      </div>
      <%= debug(assigns) %>
    """
  end

  # ゲームクリア時のrender
  def render(%{state: :game_clear} = assigns) do
    ~L"""
      <div style="width: 320px; margin: auto;">
        <h1 style="text-align: center;">Game Clear!</h1>
        <div style="display: inline-flex; flex-wrap: wrap; margin-bottom: 24px;">
          <%= raw svgs(@field, @state) %>
        </div>
        <div style="text-align: center;">
          <button phx-click="start">Play again?</button>
        </div>
      </div>
      <%= debug(assigns) %>
    """
  end

  def render(assigns) do
    ~L"""
    <%= debug(assigns) %>
    """
  end

  # ゲーム開始前のrenderを表示
  defp start_game(socket) do
    assign(
      socket,
      state: :starting
    )
  end

  # ゲーム実行中のrenderを表示
  defp new_game(socket) do
    assign(socket,
      state: :playing,
      field: Sweeper.Field.new_random()
    )
  end

  defp show(socket, field) do
    assign(socket, field: field)
  end

  defp button_head({x, y} = _point) do
    """
    <div
    phx-click="on_field_clicked"
    phx-value-x="#{x}" phx-value-y="#{y}"
    style="display: contents">
    """
  end

  defp button_foot(), do: "</div>"

  # ゲーム終了時のsvgを表示
  defp svgs(field, state) when state == :game_over or state == :game_clear do
    field
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn {x, y} -> {y, x} end)
    |> Enum.map(&compute_component_when_game_finish(&1, Map.fetch!(field, &1)))
    |> Enum.join("\n")
  end

  # ゲーム実行中のsvgを表示
  defp svgs(field, _state) do
    field
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn {x, y} -> {y, x} end)
    |> Enum.map(&compute_component(&1, Map.fetch!(field, &1)))
    |> Enum.join("\n")
  end

  # ゲーム終了時、開かれていない爆弾を表示する。
  defp compute_component_when_game_finish(point, %{is_open: is_open, is_bomb: is_bomb}) when not is_open and is_bomb do
    [
      svg_head(point),
      closed_box(point),
      bomb_svg(point),
      svg_foot()
    ]
  end

  # ゲーム終了時、開かれていないフィールドを表示する。
  defp compute_component_when_game_finish(point, %{is_open: is_open}) when not is_open do
    [
      svg_head(point),
      closed_box(point),
      svg_foot()
    ]
  end

  # ゲーム終了時、開かれている爆弾フィールドを表示する。
  defp compute_component_when_game_finish(point, %{is_bomb: is_bomb}) when is_bomb do
    [
      svg_head(point),
      red_box(point),
      bomb_svg(point),
      svg_foot()
    ]
  end

  # ゲーム終了時、開かれているフィールドを表示する。
  defp compute_component_when_game_finish(point, %{number: number}) do
    [
      svg_head(point),
      opened_svg(point, number),
      svg_foot()
    ]
  end

  # ゲーム実行中、開かれていないフィールドを表示する。
  defp compute_component(point, %{is_open: is_open}) when not is_open do
    [
      button_head(point),
      svg_head(point),
      closed_box(point),
      svg_foot(),
      button_foot()
    ]
  end

  # ゲーム実行中、開かれている爆弾フィールドを表示する。
  defp compute_component(point, %{is_bomb: is_bomb}) when is_bomb do
    [
      svg_head(point),
      bomb_svg(point),
      svg_foot()
    ]
  end

  # ゲーム実行中、開かれているフィールドを表示する。
  defp compute_component(point, %{number: number}) do
    [
      svg_head(point),
      opened_svg(point, number),
      svg_foot()
    ]
  end

  defp svg_head(point) do
    {x, y} = to_pixels(point)

    """
    <svg
    xmlns="http://www.w3.org/2000/svg"
    version="1.0"
    style="background-color: #F8F8F8"
    width="#{@box_width}"
    height="#{@box_height}"
    viewBox="#{x} #{y} #{@box_width} #{@box_height}"
    xml:space="preserve">
    """
  end

  defp svg_foot(), do: "</svg>"

  defp to_pixels({x, y}), do: {x * @box_width, y * @box_height}

  defp bomb_svg(point) do
    pixel = to_pixels(point)
    {_, svg_raw} = File.read(Path.join(:code.priv_dir(:sweeperui), "static/images/svgs/bomb.svg"))

    [
      svg_head_g(pixel),
      svg_raw,
      opened_svg_foot()
    ]
    |> Enum.join("\n")
  end

  defp opened_svg(_point, number) when number == 0, do: ""

  defp opened_svg(point, number) do
    pixel = to_pixels(point)

    {_, svg_raw} =
      File.read(Path.join(:code.priv_dir(:sweeperui), "static/images/svgs/#{number}.svg"))

    [
      svg_head_g(pixel, color(number)),
      svg_raw,
      opened_svg_foot()
    ]
    |> Enum.join("\n")
  end

  defp svg_head_g({x, y} = _pixel, color \\ "#000000") do
    """
    <g xmlns="http://www.w3.org/2000/svg" transform="translate(#{x}, #{y + @box_height}) scale(0.0025,-0.0025)" fill="#{color}" stroke="none">
    """
  end

  defp opened_svg_foot(), do: "</g>"

  defp closed_box(point) do
    {x, y} = to_pixels(point)
    {w, h} = {@box_width, @box_height}

    """
    <rect x="#{x}" y="#{y}" style="fill: #969696;" width="#{w}" height="#{h}" />
    <g xmlns="http://www.w3.org/2000/svg" transform="translate(#{x}, #{y + h}) scale(0.1, -0.1)" fill="#000000" stroke="none">
      <path d="M307 313 c-4 -3 -7 -71 -7 -150 l0 -143 -144 0 c-86 0 -147 -4 -151 -10 -4 -7 50 -10 154 -10 l161 0 0 160 c0 88 -1 160 -3 160 -2 0 -7 -3 -10 -7z"/>
    </g>
    <g xmlns="http://www.w3.org/2000/svg" transform="translate(#{x + w}, #{y}) scale(-0.1, 0.1)" fill="#FFFFFF" stroke="none">
      <path d="M307 313 c-4 -3 -7 -71 -7 -150 l0 -143 -144 0 c-86 0 -147 -4 -151 -10 -4 -7 50 -10 154 -10 l161 0 0 160 c0 88 -1 160 -3 160 -2 0 -7 -3 -10 -7z"/>
    </g>
    """
  end

  defp red_box(point) do
    {x, y} = to_pixels(point)
    {w, h} = {@box_width, @box_height}

    """
    <rect x="#{x}" y="#{y}" style="fill: #FF0000;" width="#{w}" height="#{h}" />
    """
  end

  # 爆弾フィールドが開かれたかを判定する。
  defp is_game_over?(field) do
    failure_count =
      field
      |> Map.filter(fn {_, v} -> v.is_open && v.is_bomb end)
      |> Enum.count()

    failure_count != 0
  end

  # 爆弾ではないフィールドが全て開かれたかを判定する。
  defp is_full_open?(field) do
    safe_count =
      field
      |> Map.filter(fn {_, v} -> !v.is_bomb end)
      |> Enum.count()

    open_count =
      field
      |> Map.filter(fn {_, v} -> v.is_open end)
      |> Enum.count()

    safe_count == open_count
  end

  defp compute_game_state(socket, field) do
    cond do
      is_game_over?(field) ->
        assign(socket, state: :game_over)

      is_full_open?(field) ->
        assign(socket, state: :game_clear)

      true ->
        socket
    end
  end

  # `{x_str, y_str}`地点のフィールドを開き、game_stateを判定する。
  defp try_open_field(:playing, socket, {x_str, y_str}) do
    point = {String.to_integer(x_str), String.to_integer(y_str)}

    new_field =
      socket.assigns.field
      |> Sweeper.Field.open_fields_chained([point])

    socket
    |> compute_game_state(new_field)
    |> show(new_field)
  end

  defp try_open_field(_not_playing, socket, _point), do: socket

  defp color(number) when number == 1, do: "#e91e63"
  defp color(number) when number == 2, do: "#9c27b0"
  defp color(number) when number == 3, do: "#673ab7"
  defp color(number) when number == 4, do: "#3f51b5"
  defp color(number) when number == 5, do: "#2196f3"
  defp color(number) when number == 6, do: "#009688"
  defp color(number) when number == 7, do: "#795548"
  defp color(_number), do: "#000000"

  def handle_event("start", _, socket) do
    {:noreply, new_game(socket)}
  end

  def handle_event("on_field_clicked", %{"x" => x_str, "y" => y_str}, socket) do
    {:noreply, try_open_field(socket.assigns.state, socket, {x_str, y_str})}
  end

  defp inspect_field_values(%{is_bomb: is_bomb, number: number, is_open: is_open}),
    do: "is_bomb: #{is_bomb}, number: #{number}, is_open: #{is_open}"

  defp inspect_field(field) do
    field
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn {x, y} -> {y, x} end)
    |> Enum.map(fn {x, y} ->
      "[#{x}, #{y}] :#{inspect_field_values(Map.fetch!(field, {x, y}))} \n"
    end)
  end

  def debug(assigns), do: debug(assigns, @debug, Mix.env())

  def debug(assigns, true, :dev) do
    ~L"""
    <pre>
    <%= raw( @state |> inspect) %>
    <%= raw( @field |> inspect_field) %>
    </pre>
    """
  end

  def debug(_assigns, _, _), do: ""
end
