defmodule MarkLiveWeb.EditorLive do
  use MarkLiveWeb, :live_view

  @topic "editor_live"

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(MarkLive.PubSub, @topic)

    {:ok, assign(socket, content: "# Shared Document\nStart collaborating...")}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen p-6 bg-slate-50">
      <div class="mb-4 flex justify-between items-center">
        <h1 class="text-xl font-bold text-slate-800 italic">MarkLive 🖋️</h1>
        <div class="text-sm text-slate-500">Auto-syncing enabled</div>
      </div>

      <div class="grid grid-cols-2 gap-6 flex-1 overflow-hidden">
        <%!-- Input Column --%>
        <div class="flex flex-col">
          <form phx-change="sync_content" class="h-full">
            <textarea
              name="content"
              class="w-full h-full p-6 font-mono text-sm border-2 border-slate-200 rounded-xl focus:border-blue-400 focus:ring-4 focus:ring-blue-50/50 outline-none shadow-sm resize-none"
              spellcheck="false"
              phx-debounce="100"
            ><%= @content %></textarea>
          </form>
        </div>

        <%!-- Preview Column --%>
        <div class="p-6 bg-white border-2 border-slate-100 rounded-xl shadow-sm prose max-w-none overflow-auto">
          <%= Earmark.as_html!(@content) |> raw() %>
        </div>
      </div>
    </div>
    """
  end

  # When YOU type:
  def handle_event("sync_content", %{"content" => value}, socket) do
    # 1. Tell everyone else to update their textarea
    Phoenix.PubSub.broadcast_from(MarkLive.PubSub, self(), @topic, {:update_text, value})

    # 2. Update our local state
    {:noreply, assign(socket, content: value)}
  end

  # When OTHERS type:
  def handle_info({:update_text, new_content}, socket) do
    # This updates the @content assign, which re-renders the textarea for this user
    {:noreply, assign(socket, content: new_content)}
  end
end
