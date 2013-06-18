
defmodule Collabs.Publication do

  alias HTTPotion.Response

  @user_agent  [ "User-agent": "Elixir aforward@gmail.com"]


  def fetch(url) do
    case HTTPotion.get(url, @user_agent) do
      Response[body: body, status_code: status, headers: _headers ] 
      when status in 200..299 ->
        { :ok, body }
      Response[body: body, status_code: _status, headers: _headers ] ->
        { :error, body }
    end
  end

  def decode(nil), do: []
  def decode(xml_body) do
    clean_html(xml_body)
    |> scan_html
    |> scan_articles_html
  end

  # private

    defp clean_html(xml_body), do: Regex.replace(%r/\n/,xml_body,"")
    defp scan_html(xml_body), do: List.flatten(Regex.scan(%r/<r[^>]*>(.*)\<\/r/r,xml_body))
    defp scan_articles_html([]), do: []
    defp scan_articles_html([xml_article|tail]), do: [ List.flatten(Regex.scan(%r/author>([^<]*)\<\/author/r,xml_article)) ] ++ scan_articles_html(tail)


    # 

end
