Mix.install([:jason, :nimble_csv])

defmodule Functions do
  def read_json(file_path) do
    {:ok, content} = File.read(file_path)

    Jason.decode(content)
  end

  def generate_csv(data) do
    NimbleCSV.define(MyCSV, separator: ",", escape: "\"")

    data
    |> MyCSV.dump_to_iodata()
    |> IO.puts()
  end
end

defmodule Main do
  def main do
    IO.puts("Digite o caminho para o arquivo JSON:")

    file_path = IO.gets("") |> String.trim()

    case Functions.read_json(file_path) do
      {:ok, decoded_data} ->
        # Variáveis padrão para os cálculos
        current_year = Date.utc_today().year
        tuple_age_count = Enum.map(decoded_data, fn user ->
          case DateTime.from_iso8601(user["created_at"]) do
            {:ok, datetime, _offset} -> current_year - datetime.year
            _ -> 0
          end
          end
        )
        tuple_followers_count = Enum.map(decoded_data, fn user -> Map.get(user, "followers_count", 0) end)
        tuple_following_count = Enum.map(decoded_data, fn user -> Map.get(user, "following_count", 0) end)

        # Pega o máximo das métricas
        tuple_followers_max = Enum.max_by(decoded_data, fn user -> Map.get(user, "followers_count", 0) end)
        followers_max = Map.get(tuple_followers_max, "followers_count")

        tuple_following_max = Enum.max_by(decoded_data, fn user -> Map.get(user, "following_count", 0) end)
        following_max = Map.get(tuple_following_max, "following_count")

        age_max = Enum.max(tuple_age_count)

        # Pega o mínimo das métricas
        tuple_followers_min = Enum.min_by(decoded_data, fn user -> Map.get(user, "followers_count", 0) end)
        followers_min = Map.get(tuple_followers_min, "followers_count")

        tuple_following_min = Enum.min_by(decoded_data, fn user -> Map.get(user, "following_count", 0) end)
        following_min = Map.get(tuple_following_min, "following_count")

        age_min = Enum.min(tuple_age_count)

        # Pega a média das métricas
        total_followers = Enum.sum(tuple_followers_count)
        avarage_followers = total_followers / length(tuple_followers_count)

        total_following = Enum.sum(tuple_following_count)
        avarage_following = total_following / length(tuple_following_count)

        avarage_age =
          if length(tuple_age_count) > 0 do
            Enum.sum(tuple_age_count) / length(tuple_age_count)
          else
            0
          end

        # Pega a mediana dos valores
        tuple_followers_count = Enum.sort(tuple_followers_count)
        tuple_following_count = Enum.sort(tuple_following_count)
        tuple_age_count = Enum.sort(tuple_age_count)

        followers_mediana =
          if rem(length(tuple_followers_count), 2) == 0 do
            (Enum.at(tuple_followers_count, div(length(tuple_followers_count), 2)) + Enum.at(tuple_followers_count, div(length(tuple_followers_count), 2) - 1)) / 2
          else
            Enum.at(tuple_followers_count, div(length(tuple_followers_count), 2))
          end

        following_mediana =
          if rem(length(tuple_following_count), 2) == 0 do
            (Enum.at(tuple_following_count, div(length(tuple_following_count), 2)) + Enum.at(tuple_following_count, div(length(tuple_following_count), 2) - 1)) / 2
          else
            Enum.at(tuple_following_count, div(length(tuple_following_count), 2))
          end

        age_mediana =
          if rem(length(tuple_age_count), 2) == 0 do
            (Enum.at(tuple_age_count, div(length(tuple_age_count), 2)) + Enum.at(tuple_age_count, div(length(tuple_age_count), 2) - 1)) / 2
          else
            Enum.at(tuple_age_count, div(length(tuple_age_count), 2))
          end

        # Pega o desvio padrão dos valores
        tuple_followers_count = Enum.map(tuple_followers_count, fn followers_count -> followers_count - avarage_followers end)
        tuple_following_count = Enum.map(tuple_following_count, fn following_count -> following_count - avarage_following end)
        tuple_age_count = Enum.map(tuple_age_count, fn age -> age - avarage_age end)

        tuple_followers_count = Enum.map(tuple_followers_count, fn followers_count -> followers_count * followers_count end)
        tuple_following_count = Enum.map(tuple_following_count, fn following_count -> following_count * following_count end)
        tuple_age_count = Enum.map(tuple_age_count, fn age -> age * age end)

        followers_desvio_padrao = :math.sqrt(Enum.sum(tuple_followers_count) / length(tuple_followers_count))
        following_desvio_padrao = :math.sqrt(Enum.sum(tuple_following_count) / length(tuple_following_count))
        age_desvio_padrao = :math.sqrt(Enum.sum(tuple_age_count) / length(tuple_age_count))

        # Gera o CSV
        data = [
          ["Mínimo", "Máximo", "Média", "Mediana", "Desvio Padrão"],
          [followers_min, followers_max, avarage_followers, followers_mediana, followers_desvio_padrao],
          [following_min, following_max, avarage_following, following_mediana, following_desvio_padrao],
          [age_min, age_max, avarage_age, age_mediana, age_desvio_padrao]
        ]

        Functions.generate_csv(data)

        {:error, reason} ->
        IO.puts("Erro ao ler o arquivo JSON: #{reason}")
    end
  end
end

Main.main()
