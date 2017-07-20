defmodule StenoDemo.Demo.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias StenoDemo.Demo.Job

  schema "jobs" do
    field :output, :string
    field :sandbox_id, :integer
    field :upload_id, :id
    field :grading_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, [:output, :sandbox_id, :upload_id, :grading_id])
    |> validate_required([:grading_id, :upload_id])
  end
end
