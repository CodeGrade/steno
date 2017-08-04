defmodule StenoDemo.RunJob do
  def run(job_id) do
    job = StenoDemo.Demo.get_job!(job_id)

    # FIXME: Config options for URLS

    url = "http://#{host(:steno)}/api/v1/jobs"

    job_req =  %{
      "sub_url":  "http://#{host(:demo)}/uploads/#{job.upload_id}",
      "sub_name": "#{job.upload.name}",
      "gra_url":  "http://#{host(:demo)}/uploads/#{job.grading_id}",
      "gra_name": "#{job.grading.name}",
      "timeout":  60,
      "postback": "http://#{host(:demo)}/jobs/#{job.id}",
    }

    job_req = if job.extra do
      job_req
      |> Map.put("xtr_url", "http://#{host(:demo)}/uploads/#{job.extra_id}")
      |> Map.put("xtr_name", "#{job.extra.name}")
    else
      job_req
    end

    body = %{ "job": job_req }

    hdrs = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
    ]

    {:ok, resp} = HTTPoison.post(url, Poison.encode!(body), hdrs)
    body = Poison.decode!(resp.body)["data"]
    body["id"]
  end

  defp host(name) do
    host(Application.get_env(:steno_demo, :env), name)
  end

  defp host(:prod, name) do
    case name do
      :steno -> System.get_env("STENO_HOST") || "steno"
      :demo  -> System.get_env("DEMO_HOST")  || "steno-demo"
    end
  end

  defp host(_, name) do
    hostname = String.strip(System.get_env("ADDR"))

    case name do
      :steno -> "#{hostname}:8081"
      :demo  -> "#{hostname}:5000"
    end
  end
end
