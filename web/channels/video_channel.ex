defmodule Rumbl.VideoChannel do
  require Logger
  use Rumbl.Web, :channel
  alias Rumbl.Repo

  def join("videos:" <> video_id, _params, socket) do
    video_id = String.to_integer(video_id)
    video = Repo.get(Rumbl.Video, video_id)
    annotations = Repo.all(
      from a in assoc(video, :annotations),
      order_by: [asc: a.at],
      limit: 200,
      preload: [:user]
    )

    resp = %{annotations: Phoenix.View.render_many(annotations, Rumbl.AnnotationView, "annotation.json")}

    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  def handle_in("new_annotation", params, socket) do
    user = socket.assigns.current_user

    changeset = user |> build_assoc(:annotations, video_id: socket.assigns.video_id)
    |> Rumbl.Annotation.changeset(params)

    case Rumbl.Repo.insert(changeset) do
      {:ok, annotation} ->
        broadcast_annotation(socket, annotation)
        Task.start_link(fn -> compute_additional_info(annotation, socket) end)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_annotation(socket, annotation) do
    annotation = Repo.preload(annotation, :user)
    rendered_ann = Rumbl.AnnotationView.render("annotation.json", %{annotation: annotation})
    broadcast! socket, "new_annotation", rendered_ann
  end

  defp compute_additional_info(annotation, socket) do
    Rumbl.InfoSys.compute(annotation.body, limit: 1, timeout: 10000) |> Enum.each(fn result ->
      attrs = %{url: result.url, body: result.text, at: annotation.at}
      info_changeset = result.backend
      |> build_assoc(:annotations, video_id: annotation.video_id)
      |> Rumbl.Annotation.changeset(attrs)

      case Repo.insert(info_changeset) do
        {:ok, info_annotation} -> broadcast_annotation(socket, info_annotation)
        {:error, changeset} ->
          Logger.debug "Error adding info: #{inspect changeset}"
          :ignore
      end
    end)
  end

end
