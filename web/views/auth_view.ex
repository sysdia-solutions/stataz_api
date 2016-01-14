defmodule StatazApi.AuthView do
  use StatazApi.Web, :view
  alias StatazApi.Util.Time

  def render("show.json", %{access_token: access_token}) do
    expires_in = Time.ecto_now()
                 |> Time.ecto_date_diff(access_token.expires, :secs)
    data = %{ token_type: "bearer",
              access_token: access_token.access_token,
              expires_in: expires_in,
              refresh_token: access_token.refresh_token }
    %{data: data}
  end

  def render("show.json", %{error: error}) do
    %{errors:
      %{ title: StatazApi.ErrorHelpers.translate_error(to_string(error)) }
    }
  end
end
