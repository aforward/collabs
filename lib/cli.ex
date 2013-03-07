defmodule Collabs.CLI do

  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a 
  table of the last _n_ issues in a github project
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise specify a website to fetch publication data
  Returns a list of publication authors
  [ [ author1, author2, ...], ... ] 
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do
      { [ help: true ], _ }           -> :help
      { _, [ url ] }                  -> { url }
      _                               -> :help
    end
  end

  def process(:help) do
   IO.puts """
   usage: collabs <publication_url> 
   """
   System.halt(0)
  end

  def process({url}) do
    Collabs.Publication.fetch(url)
    |> decode_response
  end

  def decode_response({:ok, body}), do: Collabs.Publication.decode(body)
  def decode_response({:error, msg}) do
    IO.puts "Error fetching data: #{msg}"
    System.halt(2)    
  end

end
