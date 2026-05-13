defmodule SmoothAuth.Validation do
  @moduledoc false

  @type error :: %{
          field: atom(),
          message: String.t()
        }
  @type errors :: [error()]

  @spec format_ecto_errors(Ecto.Changeset.t()) :: errors()
  def format_ecto_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&interpolate_error/1)
    |> Enum.flat_map(fn {field, messages} ->
      Enum.map(messages, fn message ->
        %{field: field, message: message}
      end)
    end)
  end

  @spec interpolate_error({String.t(), keyword()}) :: String.t()
  defp interpolate_error({message, opts}) do
    Regex.replace(~r/%{(\w+)}/, message, fn _, key ->
      opts
      |> Keyword.get(String.to_existing_atom(key), key)
      |> to_string()
    end)
  end
end
