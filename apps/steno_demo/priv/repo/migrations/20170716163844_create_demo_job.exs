defmodule StenoDemo.Repo.Migrations.CreateStenoDemo.Demo.Job do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :sandbox_id, :integer
      add :output, :text
      add :upload_id, references(:uploads, on_delete: :nothing)
      add :grading_id, references(:uploads, on_delete: :nothing)
      add :extra_id, references(:uploads, on_delete: :nothing)

      timestamps()
    end

    create index(:jobs, [:upload_id])
    create index(:jobs, [:grading_id])
  end
end
