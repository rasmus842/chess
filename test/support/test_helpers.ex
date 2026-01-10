defmodule Chess.TestHelpers do
  defmacro parameterized_test(name, data, do: block) do
    Enum.map(data, fn params ->
      quote do
        test "#{unquote(name)} #{inspect(unquote(params))}" do
          unquote(block)
        end
      end
    end)
  end
end
