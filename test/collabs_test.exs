Code.require_file "test_helper.exs", __DIR__

defmodule CollabsTest do
  use ExUnit.Case
  import Collabs.CLI, only: [ parse_args: 1 ]
  import Collabs.Publication

  test ":help returned by option parsing with -h and --help options" do assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "one values returned if one given" do
    assert parse_args(["http://hello.com"]) == {:informatik,["http://hello.com"]}
  end

  test "decode_authors: handle nil" do
    assert decode_authors(nil) == []
  end

  test "decode_authors: grab after target" do
    assert decode_authors("<r key=\"journals/ijsi/FatolahiSL12\" mdate=\"2013-01-30\"><author>Ali Fatolahi</author><author>Stephane S. Some</author><author>Timothy C. Lethbridge</author></r><r blah><author>Timothy C. Lethbridge</author></r>") == [["Ali Fatolahi","Stephane S. Some","Timothy C. Lethbridge"],["Timothy C. Lethbridge"]]
  end


  test "decode_professors: handle nil" do
    assert decode_professors(nil) == []
  end

  test "people: grab the people" do
    input = """
      blah<a href="http://www.eecs.uottawa.ca/matwin-stan">Matwin, Stan</a>blah
      <a href="http://www.eecs.uottawa.ca/lethbridge-tim">Lethbridge, Tim</a>blah    
    """
    assert decode_professors(input) == [ {"Stan","Matwin"}, {"Tim", "Lethbridge"} ]
  end

  test "professor_biblio" do
    assert professor_biblio({"Stan","Matwin"}) == "http://www.informatik.uni-trier.de/~ley/pers/xx/m/Matwin:Stan"
  end


end
