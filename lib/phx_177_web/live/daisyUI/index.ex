defmodule Phx177Web.DaisyUILive.Index do
  use Phx177Web, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    Logger.debug("action:[#{socket.assigns.live_action}]")

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Development Page")
  end

  defp apply_action(socket, _, _params) do
    Logger.debug("catch_all : unhandled action:[#{socket.assigns.live_action}]")
    socket
  end

  @impl true
  def handle_event(any, params, socket) do
    Logger.warning("CATCHALL #{inspect(any)}: #{inspect(params)}")

    {:noreply, socket}
  end

  @impl true
  def handle_info(any, socket) do
    Logger.warning("CATCHALL event: #{inspect(any)}")
    {:noreply, socket}
  end
end
