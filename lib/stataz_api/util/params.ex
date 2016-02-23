defmodule StatazApi.Util.Params do
  defp get_value(data, default) do
    if data, do: data, else: default
  end

  def get_limit_offset(params) do
    {get_value(params["limit"], 10), get_value(params["offset"], 0)}
  end
end
