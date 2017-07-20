defmodule StenoDemo.Web.JobController do
  use StenoDemo.Web, :controller

  alias StenoDemo.Demo

  def index(conn, _params) do
    jobs = Demo.list_jobs()
    render(conn, "index.html", jobs: jobs)
  end

  def new(conn, _params) do
    changeset = Demo.change_job(%StenoDemo.Demo.Job{})
    uploads = Enum.map(Demo.list_uploads, &({&1.name, &1.id}))
    render(conn, "new.html", changeset: changeset, uploads: uploads)
  end

  def create(conn, %{"job" => job_params}) do
    case Demo.create_job(job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: job_path(conn, :show, job))
      {:error, %Ecto.Changeset{} = changeset} ->
        uploads = Enum.map(Demo.list_uploads, &({&1.name, &1.id}))
        render(conn, "new.html", changeset: changeset, uploads: uploads)
    end
  end

  def show(conn, %{"id" => id}) do
    job = Demo.get_job!(id)
    render(conn, "show.html", job: job)
  end

  def edit(conn, %{"id" => id}) do
    job = Demo.get_job!(id)
    changeset = Demo.change_job(job)
    uploads = Enum.map(Demo.list_uploads, &({&1.name, &1.id}))
    render(conn, "edit.html", job: job, changeset: changeset, uploads: uploads)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Demo.get_job!(id)

    case Demo.update_job(job, job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job updated successfully.")
        |> redirect(to: job_path(conn, :show, job))
      {:error, %Ecto.Changeset{} = changeset} ->
        uploads = Enum.map(Demo.list_uploads, &({&1.name, &1.id}))
        render(conn, "edit.html", job: job, changeset: changeset, uploads: uploads)
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Demo.get_job!(id)
    {:ok, _job} = Demo.delete_job(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: job_path(conn, :index))
  end
end
