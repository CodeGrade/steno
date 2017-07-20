defmodule Steno.Repo.Migrations.CreateSteno.Grading.Job do
  use Ecto.Migration

  def change do
    create table(:grading_jobs) do
      add :sub_url, :string
      add :gra_url, :string
      add :output, :text
      add :started_at, :utc_datetime

      timestamps()
    end

  end
end
