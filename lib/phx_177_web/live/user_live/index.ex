defmodule Phx177Web.UserLive.Index do
  use Phx177Web, :live_view
  # import Phoenix.HTML.Form

  alias Phx177.Accounts
  alias Phx177.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    start_dt = Timex.beginning_of_year(Timex.now()) |> Phx177.Utils.DateTime.datetime()
    end_dt = Timex.now() |> Phx177.Utils.DateTime.datetime()
    start_date = Phx177.Utils.DateTime.get_date_from_string(start_dt, "%m/%d/%y")
    end_date = Phx177.Utils.DateTime.get_date_from_string(end_dt, "%m/%d/%y")

    socket =
      socket
      |> assign(:start_dt, start_dt)
      |> assign(:end_dt, end_dt)
      |> assign(:date_range, [start_date, end_date])
      |> assign(
        :frequency,
        "Quarterly"
      )

    {:ok, stream(socket, :users, Accounts.list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({Phx177Web.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end

  def handle_event("daterangepicker" = _event_name, params, socket) do
    socket =
      if socket.assigns[:start_dt] != params["start_dt"] ||
           socket.assigns.end_dt != params["end_dt"] do
        socket = push_event(socket, "start-spinner", %{})

        socket
        |> assign(:start_dt, params["start_dt"])
        |> assign(:end_dt, params["end_dt"])
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("frequency-selector" = _event_name, params, socket) do
    socket =
      if socket.assigns[:frequency] != params["selected_frequency_type"] do
        socket = push_event(socket, "start-spinner", %{})
        socket |> assign(:frequency, params["selected_frequency_type"])
      else
        socket
      end

    {:noreply, socket}
  end
end
