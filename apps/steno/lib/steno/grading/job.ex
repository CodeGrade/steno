defmodule Steno.Grading.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steno.Grading.Job


  schema "grading_jobs" do
    field :gra_url, :string
    field :output, :string
    field :started_at, :utc_datetime
    field :sub_url, :string

    timestamps()
  end

  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, [:sub_url, :gra_url, :output, :started_at])
    |> validate_required([:sub_url, :gra_url])
  end
end
