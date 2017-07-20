defmodule Steno.Web.JobController do
  use Steno.Web, :controller

  alias Steno.Grading
  alias Steno.Grading.Job

  action_fallback Steno.Web.FallbackController

  def index(conn, _params) do
    jobs = Grading.list_jobs()
    render(conn, "index.json", jobs: jobs)
  end

  def create(conn, %{"job" => job_params}) do
    with {:ok, %Job{} = job} <- Grading.create_job(job_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", job_path(conn, :show, job))
      |> render("show.json", job: job)
    end
  end

  def show(conn, %{"id" => id}) do
    job = Grading.get_job!(id)
    render(conn, "show.json", job: job)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Grading.get_job!(id)

    with {:ok, %Job{} = job} <- Grading.update_job(job, job_params) do
      render(conn, "show.json", job: job)
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Grading.get_job!(id)
    with {:ok, %Job{}} <- Grading.delete_job(job) do
      send_resp(conn, :no_content, "")
    end
  end
end
