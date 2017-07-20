defmodule Steno.GradingTest do
  use Steno.DataCase

  alias Steno.Grading

  describe "jobs" do
    alias Steno.Grading.Job

    @valid_attrs %{gra_url: "some gra_url", output: "some output", started_at: %DateTime{calendar: Calendar.ISO, day: 17, hour: 14, microsecond: {0, 6}, minute: 0, month: 4, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2010, zone_abbr: "UTC"}, sub_url: "some sub_url"}
    @update_attrs %{gra_url: "some updated gra_url", output: "some updated output", started_at: %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"}, sub_url: "some updated sub_url"}
    @invalid_attrs %{gra_url: nil, output: nil, started_at: nil, sub_url: nil}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grading.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Grading.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Grading.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Grading.create_job(@valid_attrs)
      assert job.gra_url == "some gra_url"
      assert job.output == "some output"
      assert job.started_at == %DateTime{calendar: Calendar.ISO, day: 17, hour: 14, microsecond: {0, 6}, minute: 0, month: 4, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2010, zone_abbr: "UTC"}
      assert job.sub_url == "some sub_url"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grading.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, job} = Grading.update_job(job, @update_attrs)
      assert %Job{} = job
      assert job.gra_url == "some updated gra_url"
      assert job.output == "some updated output"
      assert job.started_at == %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"}
      assert job.sub_url == "some updated sub_url"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Grading.update_job(job, @invalid_attrs)
      assert job == Grading.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Grading.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Grading.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Grading.change_job(job)
    end
  end
end
