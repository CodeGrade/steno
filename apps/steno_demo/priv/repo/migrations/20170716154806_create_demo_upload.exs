defmodule StenoDemo.Repo.Migrations.CreateStenoDemo.Demo.Upload do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :name, :string
      add :key, :string

      timestamps()
    end

  end
end
