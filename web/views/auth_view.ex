defmodule StatazApi.AuthView do
  use StatazApi.Web, :view
  alias StatazApi.Util.Time

  def render("show.json", %{access_token: access_token}) do
    expires_in = Time.ecto_now()
                 |> Time.ecto_date_diff(access_token.expires, :secs)
    data = %{ access_token: access_token.token,
              expires_in: expires_in,
              token_type: "bearer" }
    %{data: data}
  end

  def render("show.json", %{error: error}) do
    %{errors:
      %{ title: StatazApi.ErrorHelpers.translate_error(to_string(error)) }
    }
  end
end
