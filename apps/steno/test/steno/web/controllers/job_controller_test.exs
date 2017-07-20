defmodule Steno.Web.JobControllerTest do
  use Steno.Web.ConnCase

  alias Steno.Grading
  alias Steno.Grading.Job

  @create_attrs %{gra_url: "some gra_url", output: "some output", started_at: %DateTime{calendar: Calendar.ISO, day: 17, hour: 14, microsecond: {0, 6}, minute: 0, month: 4, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2010, zone_abbr: "UTC"}, sub_url: "some sub_url"}
  @update_attrs %{gra_url: "some updated gra_url", output: "some updated output", started_at: %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"}, sub_url: "some updated sub_url"}
  @invalid_attrs %{gra_url: nil, output: nil, started_at: nil, sub_url: nil}

  def fixture(:job) do
    {:ok, job} = Grading.create_job(@create_attrs)
    job
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, job_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates job and renders job when data is valid", %{conn: conn} do
    conn = post conn, job_path(conn, :create), job: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, job_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "gra_url" => "some gra_url",
      "output" => "some output",
      "started_at" => %DateTime{calendar: Calendar.ISO, day: 17, hour: 14, microsecond: {0, 6}, minute: 0, month: 4, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2010, zone_abbr: "UTC"},
      "sub_url" => "some sub_url"}
  end

  test "does not create job and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, job_path(conn, :create), job: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen job and renders job when data is valid", %{conn: conn} do
    %Job{id: id} = job = fixture(:job)
    conn = put conn, job_path(conn, :update, job), job: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, job_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "gra_url" => "some updated gra_url",
      "output" => "some updated output",
      "started_at" => %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"},
      "sub_url" => "some updated sub_url"}
  end

  test "does not update chosen job and renders errors when data is invalid", %{conn: conn} do
    job = fixture(:job)
    conn = put conn, job_path(conn, :update, job), job: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen job", %{conn: conn} do
    job = fixture(:job)
    conn = delete conn, job_path(conn, :delete, job)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, job_path(conn, :show, job)
    end
  end
end
