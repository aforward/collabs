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

end
