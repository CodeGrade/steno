defmodule StenoDemo.Web.JobControllerTest do
  use StenoDemo.Web.ConnCase

  alias StenoDemo.Demo

  @create_attrs %{output: "some output", sandbox_id: 42}
  @update_attrs %{output: "some updated output", sandbox_id: 43}
  @invalid_attrs %{output: nil, sandbox_id: nil}

  def fixture(:job) do
    {:ok, job} = Demo.create_job(@create_attrs)
    job
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, job_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Jobs"
  end

  test "renders form for new jobs", %{conn: conn} do
    conn = get conn, job_path(conn, :new)
    assert html_response(conn, 200) =~ "New Job"
  end

  test "creates job and redirects to show when data is valid", %{conn: conn} do
    conn = post conn, job_path(conn, :create), job: @create_attrs

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == job_path(conn, :show, id)

    conn = get conn, job_path(conn, :show, id)
    assert html_response(conn, 200) =~ "Show Job"
  end

  test "does not create job and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, job_path(conn, :create), job: @invalid_attrs
    assert html_response(conn, 200) =~ "New Job"
  end

  test "renders form for editing chosen job", %{conn: conn} do
    job = fixture(:job)
    conn = get conn, job_path(conn, :edit, job)
    assert html_response(conn, 200) =~ "Edit Job"
  end

  test "updates chosen job and redirects when data is valid", %{conn: conn} do
    job = fixture(:job)
    conn = put conn, job_path(conn, :update, job), job: @update_attrs
    assert redirected_to(conn) == job_path(conn, :show, job)

    conn = get conn, job_path(conn, :show, job)
    assert html_response(conn, 200) =~ "some updated output"
  end

  test "does not update chosen job and renders errors when data is invalid", %{conn: conn} do
    job = fixture(:job)
    conn = put conn, job_path(conn, :update, job), job: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Job"
  end

  test "deletes chosen job", %{conn: conn} do
    job = fixture(:job)
    conn = delete conn, job_path(conn, :delete, job)
    assert redirected_to(conn) == job_path(conn, :index)
    assert_error_sent 404, fn ->
      get conn, job_path(conn, :show, job)
    end
  end
end
