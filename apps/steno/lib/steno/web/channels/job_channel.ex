defmodule Steno.Web.JobChannel do
  use Steno.Web, :channel

  def join("jobs:" <> job_id, payload, socket) do
    if authorized?(payload) do
      {job_id, _} = Integer.parse(job_id)
      Steno.Grading.Queue.resend(job_id)
      {:ok, assign(socket, :job_id, job_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (job:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
