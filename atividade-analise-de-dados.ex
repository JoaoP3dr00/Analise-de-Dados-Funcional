Mix.install([:jason])  # Instala a biblioteca JSON

defmodule JSONReader do
  def read_json(file_path) do
    {:ok, content} = File.read(file_path)
    Jason.decode!(content)  # Decodifica JSON
  end
end

data = JSONReader.read_json("data.json")

followers_count = data.followers_count
following_count = data.following_count
IO.inspect(followers_count)
IO.inspect(following_count)

# defmodule Main do
#   def main do
#     IO.puts("Digite o caminho para o arquivo JSON:")
#     file_path = IO.gets("") |> String.trim()
#     data = JSONReader.read_json(file_path)
#     IO.puts("Seguidores: #{data["followers_count"]}")
#     IO.puts("Seguindo: #{data["following_count"]}")
#   end
# end

# Main.main()
