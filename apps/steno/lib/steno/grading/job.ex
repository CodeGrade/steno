defmodule Steno.Grading.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steno.Grading.Job


  schema "grading_jobs" do
    field :gra_url, :string
    field :gra_name, :string
    field :sub_url, :string
    field :sub_name, :string
    field :cookie, :string
    field :timeout, :integer
    field :output, :string
    field :started_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, [:sub_url, :sub_name, :gra_url, :gra_name, :output, :started_at, :cookie, :timeout])
    |> validate_required([:sub_url, :sub_name, :gra_url, :gra_name, :cookie, :timeout])
  end
end
