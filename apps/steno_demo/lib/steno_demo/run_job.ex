defmodule StenoDemo.RunJob do
  def run(job_id) do
    job = StenoDemo.Demo.get_job!(job_id)

    # FIXME: Config options for URLS

    url = 'http://127.0.0.1:8081/api/v1/jobs'
    body = %{
      "job": %{
        "sub_url":  "http://129.10.115.128/uploads/#{job.upload_id}",
        "sub_name": "#{job.upload.name}",
        "gra_url":  "http://129.10.115.128/uploads/#{job.grading_id}",
        "gra_name": "#{job.grading.name}",
        "timeout":  60,
        "postback": "http://129.10.115.128/jobs/#{job.id}",
      },
    }

    hdrs = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
    ]

    {:ok, resp} = HTTPoison.post(url, Poison.encode!(body), hdrs)
    body = Poison.decode!(resp.body)["data"]
    body["id"]
  end
end
