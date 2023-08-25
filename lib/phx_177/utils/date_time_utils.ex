defmodule Phx177.Utils.DateTime do
  @moduledoc """
  Helper functions for DateTimes
  Non business logic functions used throughout code-base

  DO NOT ALIAS .. unless intending to override native DateTime library


  http://www.gupta-tech.com
  Copyright (c) 2022 Milan Gupta

  """
  require Logger

  #
  #  generate datetime
  #     These functions ensure all time use in UTCDateTime truncated to the second
  #

  def datetime_now() do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end

  # conversion from NaiveDateTime
  def datetime(%NaiveDateTime{} = ts) do
    # Logger.warning("Conversion from Naive to UTC [#{inspect(ts)}] .. assuming [Etc/UTC] TZ")
    {:ok, ts} = DateTime.from_naive(ts, "Etc/UTC")
    DateTime.truncate(ts, :second)
  end

  # conversion from DateTime
  def datetime(%DateTime{} = ts) do
    ts |> DateTime.truncate(:second)
  end

  # conversion from Unix time_t
  def from_unix(ts) when is_integer(ts) do
    {:ok, dt} = DateTime.from_unix(ts)
    IO.inspect(dt, label: "DateTime.from_unix(#{inspect(ts)})}")
    dt
  end

  def from_unix(ts) do
    IO.inspect(ts, label: "DateTime.from_unix(#{inspect(ts)})")
    datetime_now()
  end

  def today() do
    DateTime.utc_now() |> Timex.beginning_of_day() |> Phx177.Utils.DateTime.datetime()
  end

  def get_date_from_string(%DateTime{} = date, format) do
    Calendar.strftime(date, format)
  end

  def get_date_from_string(date, format) do
    {:ok, date_time, _} = date |> DateTime.from_iso8601()
    Calendar.strftime(date_time, format)
  end

  #
  # date_from_string()
  #
  #  Timex.parse("2007-08-13", "{ISOdate}")
  #  {:ok, ~N[2007-08-13 00:00:00]}
  #

  def date_from_string(date_str, format \\ "{ISOdate}") do
    date_str
    |> Timex.parse!(format)
    |> Timex.to_date()
  rescue
    _ ->
      Logger.error("could not parse date_str : #{date_str} #{format}\n")
      # default to now
      today()
  end

  #
  # datetime_from_string()
  #
  #  # RFC1123 : "{YYYY}-{0M}-{D} {HH}:{MM}:{SS} UTC"
  #  Timex.parse("Tue, 05 Mar 2013 23:25:19 EST", "{RFC1123}")
  #  {:ok, #DateTime<2013-03-05 23:25:19-05:00 EST EST>}
  #
  #  # RFC1123z
  #  Timex.parse("Tue, 06 Mar 2013 01:25:19 Z", "{RFC1123z}")
  #  {:ok, #DateTime<2013-03-06 01:25:19Z>}
  #
  # https://hexdocs.pm/timex/parsing.html
  # https://hexdocs.pm/timex/Timex.Format.DateTime.Formatters.Default.html

  def datetime_from_string(datetime_str) do
    datetime_from_string(datetime_str, "{RFC1123}")
  end

  def datetime_from_string(datetime_str, format) when is_binary(datetime_str) do
    with {:rfc1123, {:error, _}} <- {:rfc1123, Timex.parse(datetime_str, format)},
         {:isoextz, {:error, _}} <- {:isoextz, Timex.parse(datetime_str, "{ISO:Extended:Z}")},
         {:naive, {:error, _}} <-
           {:naive, Timex.parse(datetime_str, "%Y-%m-%d %H:%M:%S.%f", :strftime)},
         {:naive, {:error, _}} <-
           {:naive, Timex.parse(datetime_str, "%Y-%m-%d %H:%M:%S.%LZ", :strftime)},
         {:naive, {:error, _}} <-
           {:naive, Timex.parse(datetime_str, "{YYYY}-{M}-{D} {h24}:{m}:{s}")},
         {:rfc1123z, {:error, _}} <- {:rfc1123z, Timex.parse(datetime_str, "{RFC1123z}")},
         {:rfc822, {:error, _}} <- {:rfc822, Timex.parse(datetime_str, "{RFC822}")},
         {:date, {:error, _}} <- {:date, Timex.parse(datetime_str, "{M}/{D}/{YYYY}")},
         {:default, {:error, _}} <- {:default, Timex.parse(datetime_str, "{YYYY}-{0M}-{0D}")} do
      Logger.error("could not parse datetime_str : [#{datetime_str}] fmt: [#{format}]")
      # default to now
      Phx177.Utils.DateTime.datetime_now()
    else
      {:rfc1123, {:ok, datetimeval}} -> datetime(datetimeval)
      {:rfc1123z, {:ok, datetimeval}} -> datetime(datetimeval)
      {:rfc822, {:ok, datetimeval}} -> datetime(datetimeval)
      {:isoextz, {:ok, datetimeval}} -> datetime(datetimeval)
      {:date, {:ok, datetimeval}} -> datetime(datetimeval)
      {:default, {:ok, datetimeval}} -> datetime(datetimeval)
      {:naive, {:ok, datetimeval}} -> datetime(datetimeval)
      {:utc, {:ok, datetimeval}} -> datetime(datetimeval)
    end
  end

  # handler when function is called when already a datetime value
  def datetime_from_string(%DateTime{} = dt, _format) do
    datetime(dt)
  end

  # handler when function is called when already a datetime value
  def datetime_from_string(%NaiveDateTime{} = dt, _format) do
    datetime(dt)
  end

  #
  #  Use to debug
  #

  def datetime_from_string_debug(datetime_str, format) when is_binary(datetime_str) do
    with {:rfc1123, {:error, _}} <-
           {:rfc1123, Timex.parse(datetime_str, format)}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:isoextz, {:error, _}} <-
           {:isoextz, Timex.parse(datetime_str, "{ISO:Extended:Z}")}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:naive, {:error, _}} <-
           {:naive, Timex.parse(datetime_str, "%Y-%m-%d %H:%M:%S.%f %Z", :strftime)}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:naive, {:error, _}} <-
           {:naive, Timex.parse(datetime_str, "%Y-%m-%d %H:%M:%S.%LZ", :strftime)}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:utc, {:error, _}} <-
           {:utc, Timex.parse(datetime_str, "{YYYY}-{M}-{D} {h24}:{m}:{s}")}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:rfc1123z, {:error, _}} <-
           {:rfc1123z, Timex.parse(datetime_str, "{RFC1123z}")}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:rfc822, {:error, _}} <-
           {:rfc822, Timex.parse(datetime_str, "{RFC822}")}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:date, {:error, _}} <-
           {:date, Timex.parse(datetime_str, "{M}/{D}/{YYYY}")}
           |> IO.inspect(label: "#{inspect(datetime_str)}"),
         {:default, {:error, _}} <-
           {:default,
            Timex.parse(datetime_str, "{YYYY}-{0M}-{0D}")
            |> IO.inspect(label: "#{inspect(datetime_str)}")} do
      Logger.error("could not parse datetime_str : [#{datetime_str}] fmt: [#{format}]")
      # default to now
      datetime_now()
    else
      {:rfc1123, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is rfc1123")
        datetime(datetimeval)

      {:rfc1123z, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is rfc1123z")
        datetime(datetimeval)

      {:rfc822, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is rfc822")
        datetime(datetimeval)

      {:isoextz, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is isoextz")
        datetime(datetimeval)

      {:date, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is date")
        datetime(datetimeval)

      {:default, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is default")
        datetime(datetimeval)

      {:naive, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is naive")
        datetime(datetimeval)

      {:utc, {:ok, datetimeval}} ->
        Logger.debug("[#{inspect(datetime_str)}] is naive")
        datetime(datetimeval)
    end
  end

  def get_prev_month(today, months_shift) do
    today
    |> Timex.shift(months: months_shift)
    |> Timex.format!("{Mshort}, {YY}")
  end

  def get_prev_hour(today, hours_shift) do
    today
    |> Timex.shift(hours: hours_shift)
    |> Timex.format!("{h12}:{m} {AM}")
  end

  def get_prev_day(today, days_shift) do
    today
    |> Timex.shift(days: days_shift)
    |> Timex.format!("{M}/{D}")
  end

  @deprecated "Not required by datetimepicker"
  def get_period_datetime(period: period) do
    case period do
      "ALL" -> Timex.to_datetime({{1931, 12, 22}, {0, 0, 0}}) |> Phx177.Utils.DateTime.datetime()
      "WTD" -> Timex.beginning_of_week(Timex.now()) |> Phx177.Utils.DateTime.datetime()
      "MTD" -> Timex.beginning_of_month(Timex.now()) |> Phx177.Utils.DateTime.datetime()
      "QTD" -> Timex.beginning_of_quarter(Timex.now()) |> Phx177.Utils.DateTime.datetime()
      "YTD" -> Timex.beginning_of_year(Timex.now()) |> Phx177.Utils.DateTime.datetime()
      # default to DB EPOCH
      _ -> Timex.to_datetime({{1931, 12, 22}, {0, 0, 0}}) |> Phx177.Utils.DateTime.datetime()
    end
  end

  def get_frequency_date_trunc(frequency: frequency) do
    case String.downcase(frequency) do
      "none" -> nil
      "None" -> nil
      "cumulative" -> nil
      "Cumulative" -> nil
      "daily" -> "day"
      "Daily" -> "day"
      "weekly" -> "week"
      "Weekly" -> "week"
      "monthly" -> "month"
      "Monthly" -> "month"
      "quarterly" -> "quarter"
      "Quarterly" -> "quarter"
      "yearly" -> "year"
      "Yearly" -> "year"
      "decade" -> "decade"
      "Decade" -> "decade"
      "millennium" -> "millennium"
      "Millennium" -> "millennium"
      "all time" -> nil
      "All Time" -> nil
      _ -> nil
    end
  end

  @doc """
    #
    # This is called by balance sheet / p&l / cashflow stmt for the header period in English
    #
    # Inputs:
    #    start_dt : string dates (value originates in datetimepicker and must be converted to DateTime)
    #    end_dt : string dates (value originates in datetimepicker and must be converted to DateTime)
    #    freq : this is the value post - get_frequency_date_trunc()
    #    period : this is the value (datetime || string || nil) of the column which will be returned in human form
    #             TODO: cleanup - trace where string is generated vs datetime
    # Example :
    #     start_dt/end_dt : "2022-09-01T04:00:00.000Z"
    #     freq : "day" | "week" | "month" ..
    #     period:  ~U[2022-09-30 05:17:48.980000Z] || "2022-09-30 05:17:48.980000Z"
    #
  """

  def get_datetime_display_header(
        start_dt: start_dt,
        end_dt: end_dt,
        frequency: freq,
        period: period
      ) do
    # IO.puts("get_datetime_display_header - freq: [#{inspect(freq)}] period: [#{inspect(period)}]")

    {:ok, result} =
      case period do
        # period is nil => cumulative column (freq is likely NONE) so derive from start-end_dt
        nil ->
          # binary is same as string with size div 8 = 0
          if is_binary(start_dt) do
            [start_str | _] = String.split(start_dt, "T")
            [end_str | _] = String.split(end_dt, "T")

            {:ok, start_str <> " - " <> end_str}
          else
            {:ok, "Cumulative"}
          end

        _ ->
          case freq do
            "day" ->
              Timex.format(period, "{WDshort} {0M}/{0D}/{YYYY}")

            "week" ->
              Timex.format(period, "Wk {Wiso}-{YYYY}")

            "month" ->
              Timex.format(period, "{Mshort}-{YYYY}")

            "quarter" ->
              {:ok, year_str} = Timex.format(period, " {YYYY}")
              {:ok, "Q#{Timex.quarter(period)}" <> year_str}

            "year" ->
              Timex.format(period, "{YYYY}")

            _ ->
              Timex.format(period, "{0M}-{0D}-{YYYY}")
          end
      end

    # Logger.debug("start_dt: [#{inspect(start_dt)}] end_dt: [#{inspect(end_dt)}] frequency: [#{inspect(freq)}] period: [#{inspect(period)}] => RESULT: [#{inspect(result)}]")

    result
  end

  #
  # This is used to index the aggregate data structures
  # Truncated to second as currently, there are no metrics that require millisec/microsec granularity (currently only at day level)
  #     For period = nil, setting time to a index value of beginning of year prevents side-effect of sub-hierarchy timestamp values
  #         being different than those generated in the main ledger_hierarchy master period list
  #         (definately do not set to DateTime.utc_now as the seconds will vary)
  #

  def get_datetime_index_header(
        start_dt: _start_dt,
        end_dt: _end_dt,
        frequency: _freq,
        period: period
      ) do
    case period do
      nil -> Timex.beginning_of_year(DateTime.utc_now()) |> Phx177.Utils.DateTime.datetime()
      any -> datetime(any)
    end
  end

  def date_to_american_format(nil), do: nil

  def date_to_american_format(dt) do
    {yr, mm, dd} = Date.to_erl(dt)
    # {2000, 1, 1}

    am_mo = two_digit_string(mm)
    am_da = two_digit_string(dd)

    am_mo <> "/" <> am_da <> "/" <> Integer.to_string(yr)
  end

  def american_format_to_date(dt) do
    cond do
      is_bitstring(dt) && is_binary(dt) ->
        # mm/dd/yyyy
        # 0123456789
        if String.length(dt) == 10 do
          mm = String.slice(dt, 0, 2)
          dd = String.slice(dt, 3, 2)
          yr = String.slice(dt, 6, 4)
          Date.from_erl!({String.to_integer(yr), String.to_integer(mm), String.to_integer(dd)})
        else
          nil
        end

      true ->
        dt
    end
  end

  def two_digit_string(val) do
    if val < 10 do
      "0" <> Integer.to_string(val)
    else
      Integer.to_string(val)
    end
  end

  def human_date(%NaiveDateTime{year: year} = date) do
    # IO.puts("**** human_date #{inspect(date)}")

    formatter = if year == DateTime.utc_now().year, do: "%d %b %Y", else: "%d %b - %Y"

    date
    |> Timex.to_date()
    |> Timex.format!(formatter, :strftime)
  end

  def human_date(%DateTime{year: year} = date) do
    # IO.puts("**** human_date #{inspect(date)}")

    formatter = if year == DateTime.utc_now().year, do: "%d %b %Y", else: "%d %b - %Y"

    date
    |> Timex.to_date()
    |> Timex.format!(formatter, :strftime)
  end

  def human_date(_date) do
    # IO.puts("**** human_date #{inspect(date)}")

    "invalid"
  end
end
