defmodule StenoDemo.RunJob do
  def run(job_id) do
    job = StenoDemo.Demo.get_job!(job_id)
    IO.inspect {:run_job, job}

    url = 'http://127.0.0.1:4000/api/v1/jobs'
    body = %{
      "job": %{
        "sub_url":  "http://192.168.1.146:5000/uploads/#{job.upload_id}",
        "sub_name": "#{job.upload.name}",
        "gra_url":  "http://192.168.1.146:5000/uploads/#{job.grading_id}",
        "gra_name": "#{job.grading.name}",
        "timeout":  60,
      },
    }

    hdrs = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
    ]

    resp = HTTPoison.post(url, Poison.encode!(body), hdrs)
    IO.inspect(resp)
    resp
  end
end
