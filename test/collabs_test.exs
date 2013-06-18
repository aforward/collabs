Code.require_file "test_helper.exs", __DIR__

defmodule CollabsTest do
  use ExUnit.Case
  import Collabs.CLI, only: [ parse_args: 1 ]
  import Collabs.Publication

  test ":help returned by option parsing with -h and --help options" do assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "one values returned if one given" do
    assert parse_args(["http://hello.com"]) == { "http://hello.com" }
  end

  test "decode: handle nil" do
    assert decode(nil) == []
  end

  test "decode: grab after target" do
    assert decode("<r key=\"journals/ijsi/FatolahiSL12\" mdate=\"2013-01-30\"><author>Ali Fatolahi</author><author>Stephane S. Some</author><author>Timothy C. Lethbridge</author></r><r blah><author>Timothy C. Lethbridge</author></r>") == [["Ali Fatolahi","Stephane S. Some","Timothy C. Lethbridge"],["Timothy C. Lethbridge"]]
  end


end
