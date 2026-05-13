defmodule SmoothAuth.Signup.VerificationCode do
  @alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  @alphabet_size byte_size(@alphabet)

  @type code :: String.t()

  @spec generate(integer()) :: code()
  def generate(length \\ 6) when is_integer(length) and length > 0 do
    length
      |> :crypto.strong_rand_bytes()
      |> :binary.bin_to_list()
      |> Enum.map_join(fn byte ->
      index = rem(byte, @alphabet_size)
      binary_part(@alphabet, index, 1)
    end)
  end
end

