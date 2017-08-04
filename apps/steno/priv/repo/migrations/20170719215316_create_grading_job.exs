defmodule Steno.Repo.Migrations.CreateSteno.Grading.Job do
  use Ecto.Migration

  def change do
    create table(:grading_jobs) do
      add :sub_url, :string
      add :sub_name, :string
      add :gra_url, :string
      add :gra_name, :string
      add :xtr_url, :string
      add :xtr_name, :string
      add :postback, :string
      add :cookie, :string
      add :timeout, :integer
      add :output, :text
      add :started_at, :utc_datetime

      timestamps()
    end

  end
end
