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
    parse = OptionParser.parse(argv, switches: [ help: :boolean, uottawa: :boolean],
                                     aliases:  [ h:    :help , o: :uottawa  ])
    case  parse  do
      { [ help: true, uottawa: _ ], _ }           -> :help
      { [ uottawa: true, help: false ], _ }       -> :uottawa
      { _ , urls }                                -> { :informatik,  urls }
      _                                           -> :help
    end
  end

  def process(:help) do
   IO.puts """
   usage: collabs <publication_url> 
   """
   System.halt(0)
  end

  def process(:uottawa) do
    IO.puts "Processing UOttawa Professors"
    a = Collabs.Publication.fetch("http://www.eecs.uottawa.ca/professors")
    a = decode_response a, :professors
    a = Collabs.Publication.professor_biblio a
    a = Collabs.Publication.fetch a
    a = decode_response a, :authors
    MapReduce.go a, JointAuthors
  end


  def process({ :informatik,  urls }), do: process(urls,[])
  def process([url|tail],results), do: process(tail, process_url(url) ++ results)
  def process([],results), do: MapReduce.go results, JointAuthors

  def decode_response([],_), do: []
  def decode_response([head|tail],mode), do: decode_response(head,mode) ++ decode_response(tail,mode)
  def decode_response({:ok, body},:authors), do: Collabs.Publication.decode_authors(body)
  def decode_response({:ok, body},:professors), do: Collabs.Publication.decode_professors(body)
  def decode_response({:error, msg}, _) do
    IO.puts "Error fetching data: #{msg}"
    System.halt(2)    
  end

  def process_url(url) do
    Collabs.Publication.fetch(url)
    |> decode_response :authors
  end


end
