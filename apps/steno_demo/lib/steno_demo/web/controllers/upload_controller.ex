defmodule StenoDemo.Web.UploadController do
  use StenoDemo.Web, :controller

  alias StenoDemo.Demo
  alias StenoDemo.Upload

  def index(conn, _params) do
    uploads = Demo.list_uploads()
    render(conn, "index.html", uploads: uploads)
  end

  def new(conn, _params) do
    changeset = Demo.change_upload(%StenoDemo.Demo.Upload{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"upload" => upload_params}) do
    file = upload_params["file"]
    name = file.filename
    ukey = :crypto.strong_rand_bytes(18) |> Base.url_encode64

    upload_params = upload_params
      |> Map.put("name", file.filename)
      |> Map.put("key", ukey)

    case Demo.create_upload(upload_params) do
      {:ok, upload} ->
        :ok = Upload.save!(upload, file)

        conn
        |> put_flash(:info, "Upload created successfully.")
        |> redirect(to: upload_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    upload = Demo.get_upload!(id)
    #render(conn, "show.html", upload: upload)
    send_download(conn, {:file, Upload.path(upload)})
  end

  def edit(conn, %{"id" => id}) do
    upload = Demo.get_upload!(id)
    changeset = Demo.change_upload(upload)
    render(conn, "edit.html", upload: upload, changeset: changeset)
  end

  def update(conn, %{"id" => id, "upload" => upload_params}) do
    upload = Demo.get_upload!(id)

    case Demo.update_upload(upload, upload_params) do
      {:ok, upload} ->
        conn
        |> put_flash(:info, "Upload updated successfully.")
        |> redirect(to: upload_path(conn, :show, upload))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", upload: upload, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    upload = Demo.get_upload!(id)
    {:ok, _upload} = Demo.delete_upload(upload)

    conn
    |> put_flash(:info, "Upload deleted successfully.")
    |> redirect(to: upload_path(conn, :index))
  end
end
