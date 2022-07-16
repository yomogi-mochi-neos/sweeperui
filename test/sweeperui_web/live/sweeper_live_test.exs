defmodule SweeperuiWeb.SweeperLiveTest do
  use SweeperuiWeb.ConnCase

  test "file read" do
    {result, _} = File.read(Path.join(:code.priv_dir(:sweeperui), "static/images/svgs/1.svg"))
    assert result == :ok
  end
end
