defmodule Blog.Post do
  use Blog.Web, :model

  schema "posts" do
    field :author, :string
    field :title, :string
    field :content, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:author, :title, :content])
    |> validate_required([:author, :title, :content])
  end
end
