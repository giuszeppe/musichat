defmodule MusichatWeb.ChatLive.Index do
  alias MusichatWeb.UserAuth
  alias Musichat.Accounts
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token session["user_token"]
    IO.inspect(user.id)
    if connected?(socket) do
      MusichatWeb.Endpoint.subscribe(user.email)
    end
    {:ok,assign(socket, username: user.email, messages: [], current_chat: "")}
  end

  defp username do
    "User #{:rand.uniform(100)}"
  end

  def handle_event("send", %{"text" => value}, socket) do
    #IO.inspect(socket)
    socket = assign(socket, messages: [%{text: value, name: socket.assigns.username, sender: true} | socket.assigns.messages])
    MusichatWeb.Endpoint.broadcast(socket.assigns.current_chat, "message", %{text: value, name: socket.assigns.username, sender: false})
    {:noreply, socket}
  end

  def handle_info(%{event: "message", payload: message}, socket) do
    IO.inspect(message)
    {:noreply, assign(socket,messages: [message | socket.assigns.messages])}
  end

  def handle_event("change_chat", %{"username" => username}, socket) do
    {:noreply, assign(socket,:current_chat, username)}
  end
end
