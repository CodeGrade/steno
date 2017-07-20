defmodule StenoDemo.DemoTest do
  use StenoDemo.DataCase

  alias StenoDemo.Demo

  describe "uploads" do
    alias StenoDemo.Demo.Upload

    @valid_attrs %{key: "some key", name: "some name"}
    @update_attrs %{key: "some updated key", name: "some updated name"}
    @invalid_attrs %{key: nil, name: nil}

    def upload_fixture(attrs \\ %{}) do
      {:ok, upload} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Demo.create_upload()

      upload
    end

    test "list_uploads/0 returns all uploads" do
      upload = upload_fixture()
      assert Demo.list_uploads() == [upload]
    end

    test "get_upload!/1 returns the upload with given id" do
      upload = upload_fixture()
      assert Demo.get_upload!(upload.id) == upload
    end

    test "create_upload/1 with valid data creates a upload" do
      assert {:ok, %Upload{} = upload} = Demo.create_upload(@valid_attrs)
      assert upload.key == "some key"
      assert upload.name == "some name"
    end

    test "create_upload/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Demo.create_upload(@invalid_attrs)
    end

    test "update_upload/2 with valid data updates the upload" do
      upload = upload_fixture()
      assert {:ok, upload} = Demo.update_upload(upload, @update_attrs)
      assert %Upload{} = upload
      assert upload.key == "some updated key"
      assert upload.name == "some updated name"
    end

    test "update_upload/2 with invalid data returns error changeset" do
      upload = upload_fixture()
      assert {:error, %Ecto.Changeset{}} = Demo.update_upload(upload, @invalid_attrs)
      assert upload == Demo.get_upload!(upload.id)
    end

    test "delete_upload/1 deletes the upload" do
      upload = upload_fixture()
      assert {:ok, %Upload{}} = Demo.delete_upload(upload)
      assert_raise Ecto.NoResultsError, fn -> Demo.get_upload!(upload.id) end
    end

    test "change_upload/1 returns a upload changeset" do
      upload = upload_fixture()
      assert %Ecto.Changeset{} = Demo.change_upload(upload)
    end
  end

  describe "jobs" do
    alias StenoDemo.Demo.Job

    @valid_attrs %{output: "some output", sandbox_id: 42}
    @update_attrs %{output: "some updated output", sandbox_id: 43}
    @invalid_attrs %{output: nil, sandbox_id: nil}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Demo.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Demo.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Demo.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Demo.create_job(@valid_attrs)
      assert job.output == "some output"
      assert job.sandbox_id == 42
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Demo.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, job} = Demo.update_job(job, @update_attrs)
      assert %Job{} = job
      assert job.output == "some updated output"
      assert job.sandbox_id == 43
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Demo.update_job(job, @invalid_attrs)
      assert job == Demo.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Demo.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Demo.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Demo.change_job(job)
    end
  end
end
