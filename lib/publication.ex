
defmodule Collabs.Publication do

  alias HTTPotion.Response

  @user_agent  [ "User-agent": "Elixir aforward@gmail.com"]


  def fetch([]), do: []
  def fetch([head|tail]), do: [ fetch(head) ] ++ fetch(tail) 
  def fetch(url) do
    case HTTPotion.get(url, @user_agent) do
      Response[body: body, status_code: status, headers: _headers ] 
      when status in 200..299 ->
        { :ok, body }
      Response[body: body, status_code: _status, headers: _headers ] ->
        { :error, body }
    end
  end

  def decode_authors(nil), do: []
  def decode_authors(xml_body) do
    clean_html(xml_body)
    |> scan_authors_xml
    |> scan_articles_xml
  end

  def decode_professors(nil), do: []
  def decode_professors(html_body) do
    clean_html(html_body)
    |> scan_professors_html
  end

  def professor_biblio([]), do: []
  def professor_biblio([head|tail]), do: [professor_biblio(head)] ++ professor_biblio(tail)
  def professor_biblio({first_name,last_name}) do 
    dir = String.downcase(String.first(last_name))
    "http://www.informatik.uni-trier.de/~ley/pers/xx/#{dir}/#{last_name}:#{first_name}"
  end

  # private

    defp clean_html(xml_body), do: Regex.replace(%r/\n/,xml_body,"")
    defp scan_authors_xml(xml_body), do: List.flatten(Regex.scan(%r/<r[^>]*>(.*)\<\/r/r,xml_body))
    defp scan_articles_xml([]), do: []
    defp scan_articles_xml([xml_article|tail]), do: [ List.flatten(Regex.scan(%r/author>([^<]*)\<\/author/r,xml_article)) ] ++ scan_articles_xml(tail)

    defp scan_professors_html(html_body) do
      filtered = List.last(Regex.run(%r/Faculty members(.*)<\/table\>/r,html_body))
      List.flatten(Regex.scan(%r/<a[^>]*>\s*(.*)\s*\<\/a/r,filtered))
      |> extract_professors_names
    end

    def extract_professors_names([]), do: []
    def extract_professors_names([head|tail]), do: [ extract_name(head) ] ++ extract_professors_names(tail)
    defp extract_name(name) do
      [last_name, first_name] = List.last(Regex.scan(%r/^([^\s]*)\s*([^\s]*)$/,name) ++ Regex.scan(%r/^(.*)\s*,\s*(.*)$/,name))
      first_name = biblio_friendly(first_name)
      last_name = biblio_friendly(last_name)
      IO.puts "Found #{first_name} #{last_name}"
      { first_name, last_name }
    end

    defp biblio_friendly(name) do
      name = Regex.replace(%r/&#039;/,name,"=")
      name = Regex.replace(%r/\s/,name,"_")
      name = Regex.replace(%r/\./,name,"=")
      name = Regex.replace(%r/é/,name,"=eacute=")
      name
    end

end
