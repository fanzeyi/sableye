defmodule Sableye.Util do
  def error_tuple(result, error \\ nil) do
    case result do
      nil -> {:error, error}
      false -> {:error, error}
      :error -> {:error, error}
      {:error, m} -> {:error, m}
      true -> {:ok, true}
      x -> {:ok, x}
    end
  end
end
