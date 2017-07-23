defmodule Steno.Web.JobView do
  use Steno.Web, :view
  alias Steno.Web.JobView

  def render("index.json", %{jobs: jobs}) do
    %{data: render_many(jobs, JobView, "job.json")}
  end

  def render("show.json", %{job: job}) do
    %{data: render_one(job, JobView, "job.json")}
  end

  def render("job.json", %{job: job}) do
    %{id: job.id,
      sub_url: job.sub_url,
      sub_name: job.sub_name,
      gra_url: job.gra_url,
      gra_name: job.gra_name,
      cookie: job.cookie,
      timeout: job.timeout,
      output: job.output,
      started_at: job.started_at}
  end
end
