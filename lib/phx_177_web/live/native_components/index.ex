defmodule Phx177Web.NativeComponentLive.Index do
  use Phx177Web, :live_view

  require Logger

  # @flash_timing 5_000

  @impl true
  def mount(params, _session, socket) do
    start_dt = Timex.beginning_of_year(Timex.now()) |> Phx177.Utils.DateTime.datetime()
    end_dt = Timex.now() |> Phx177.Utils.DateTime.datetime()
    start_date = Phx177.Utils.DateTime.get_date_from_string(start_dt, "%m/%d/%y")
    end_date = Phx177.Utils.DateTime.get_date_from_string(end_dt, "%m/%d/%y")

    dbg(params)

    socket =
      socket
      |> assign(:values, [])
      # move this to true when fetch_data is completed
      |> assign(:data_loading, false)
      |> assign(:params, params)
      |> assign(:start_dt, start_dt)
      |> assign(:end_dt, end_dt)
      |> assign(:date_range, [start_date, end_date])
      |> assign(
        :frequency,
        "Quarterly"
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    Logger.debug("action:[#{socket.assigns.live_action}]")

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Native Components Page")
  end

  defp apply_action(socket, _, _params) do
    Logger.debug("catch_all : unhandled action:[#{socket.assigns.live_action}]")
    socket
  end

  #
  #  LIVE SELECT HANDLER
  #
  @impl true
  def handle_event(
        "live_select_change",
        %{"text" => _text, "id" => live_select_id, "field" => live_select_field} = params,
        socket
      ) do
    Logger.debug("live_select_change - #{inspect(params)}")

    options =
      case live_select_field do
        # "search_form_category" ->
        #  ReferenceDataContext.get_ledger_category_options(search_values: text)

        # "search_form_sub_category" ->
        #  ReferenceDataContext.get_ledger_sub_category_options(search_values: text)

        # "search_form_account_name" ->
        #  ReferenceDataContext.get_ledger_account_name_options(search_values: text)
        any ->
          Logger.debug("live_select_change : unknown field #{inspect(any)} #{inspect(params)}")
          []
      end

    send_update(LiveSelect.Component, id: live_select_id, options: options)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", params, socket) do
    Logger.debug("save - #{inspect(params)}")

    {:noreply, socket}
  end

  @impl true
  def handle_event(any, params, socket) do
    Logger.warning("CATCHALL #{inspect(any)}: #{inspect(params)}")

    {:noreply, socket}
  end

  @impl true
  def handle_info(:working, socket) do
    Logger.debug("*** Development :  HANDLE INFO : :working")
    {:noreply, assign(socket, data_loading: true)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  # this will be called if the task succeeds
  def handle_info({_ref, data}, socket) do
    Logger.debug("*** Development :  HANDLE INFO : task results")

    socket =
      socket
      |> assign(data)
      |> assign(data_loading: false)

    {:noreply, socket}
  end

  # Here you handle the task failure
  def handle_info({:DOWN, _ref, _, _, reason}, socket) do
    Logger.debug("*** Development :  HANDLE INFO : task ended [#{reason}]")
    {:noreply, socket}
  end

  def handle_info(any, socket) do
    Logger.warning("CATCHALL event: #{inspect(any)}")
    {:noreply, socket}
  end
end
