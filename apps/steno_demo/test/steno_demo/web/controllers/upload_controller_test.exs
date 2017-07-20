defmodule StenoDemo.Web.UploadControllerTest do
  use StenoDemo.Web.ConnCase

  alias StenoDemo.Demo

  @create_attrs %{key: "some key", name: "some name"}
  @update_attrs %{key: "some updated key", name: "some updated name"}
  @invalid_attrs %{key: nil, name: nil}

  def fixture(:upload) do
    {:ok, upload} = Demo.create_upload(@create_attrs)
    upload
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, upload_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Uploads"
  end

  test "renders form for new uploads", %{conn: conn} do
    conn = get conn, upload_path(conn, :new)
    assert html_response(conn, 200) =~ "New Upload"
  end

  test "creates upload and redirects to show when data is valid", %{conn: conn} do
    conn = post conn, upload_path(conn, :create), upload: @create_attrs

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == upload_path(conn, :show, id)

    conn = get conn, upload_path(conn, :show, id)
    assert html_response(conn, 200) =~ "Show Upload"
  end

  test "does not create upload and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, upload_path(conn, :create), upload: @invalid_attrs
    assert html_response(conn, 200) =~ "New Upload"
  end

  test "renders form for editing chosen upload", %{conn: conn} do
    upload = fixture(:upload)
    conn = get conn, upload_path(conn, :edit, upload)
    assert html_response(conn, 200) =~ "Edit Upload"
  end

  test "updates chosen upload and redirects when data is valid", %{conn: conn} do
    upload = fixture(:upload)
    conn = put conn, upload_path(conn, :update, upload), upload: @update_attrs
    assert redirected_to(conn) == upload_path(conn, :show, upload)

    conn = get conn, upload_path(conn, :show, upload)
    assert html_response(conn, 200) =~ "some updated key"
  end

  test "does not update chosen upload and renders errors when data is invalid", %{conn: conn} do
    upload = fixture(:upload)
    conn = put conn, upload_path(conn, :update, upload), upload: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Upload"
  end

  test "deletes chosen upload", %{conn: conn} do
    upload = fixture(:upload)
    conn = delete conn, upload_path(conn, :delete, upload)
    assert redirected_to(conn) == upload_path(conn, :index)
    assert_error_sent 404, fn ->
      get conn, upload_path(conn, :show, upload)
    end
  end
end
