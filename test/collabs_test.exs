Code.require_file "test_helper.exs", __DIR__

defmodule CollabsTest do
  use ExUnit.Case
  import Collabs.CLI, only: [ parse_args: 1 ]

  test ":help returned by option parsing with -h and --help options" do assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "one values returned if one given" do
    assert parse_args(["http://hello.com"]) == { "http://hello.com" }
  end

end
