defmodule StenoDemo.Demo.Upload do
  use Ecto.Schema
  import Ecto.Changeset
  alias StenoDemo.Demo.Upload


  schema "uploads" do
    field :key, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Upload{} = upload, attrs) do
    upload
    |> cast(attrs, [:name, :key])
    |> validate_required([:name, :key])
  end
end
