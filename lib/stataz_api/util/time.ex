defmodule StatazApi.Util.Time do
  use Timex

  def timex_from_ecto(date) do
    Ecto.DateTime.to_erl(date)
    |> Date.from()
  end

  def ecto_now() do
    Ecto.DateTime.utc()
  end

  def ecto_shift(ecto_datetime, amount) do
    timex_from_ecto(ecto_datetime)
    |> Date.shift(amount)
    |> DateConvert.to_erlang_datetime
    |> Ecto.DateTime.from_erl()
  end

  def ecto_date_diff(date1, date2, unit) do
    date1 = timex_from_ecto(date1)
    date2 = timex_from_ecto(date2)

    Date.diff(date1, date2, unit)
  end

  def ecto_datetime_simple_format(date) do
    {:ok, string} = timex_from_ecto(date)
                    |> DateFormat.format("%Y-%m-%d %H:%M:%S", :strftime)
    string
  end
end
