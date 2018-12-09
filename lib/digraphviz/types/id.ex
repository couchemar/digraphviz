defmodule Digraphviz.Types.ID do
  @moduledoc false
  def convert(id) when is_binary(id) do
    "#{inspect(id)}"
  end

  def convert(id) do
    escaped = "#{inspect(id)}" |> String.replace("\"", "\\\"")
    "\"#{escaped}\""
  end
end
