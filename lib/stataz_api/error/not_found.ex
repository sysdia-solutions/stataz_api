defmodule StatazApi.Error.NotFound do
  defstruct resource: "", id: "", message: ""
end

defimpl Poison.Encoder, for: StatazApi.Error.NotFound do
  def encode(error, _options) do
    %{errors: %{title: "#{error.resource} '#{error.id}' can't be found"}}
    |> Poison.Encoder.encode([])
  end
end
