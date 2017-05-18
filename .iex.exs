defmodule Commands do
  def rec do
    :erlydtl.compile_dir(Path.join(:code.priv_dir(:sableye), "templates") |> to_charlist,
                         :"Elixir.Sableye.Templates", [
      out_dir: "templates_out",
      libraries: [{:"Elixir.Filters", :"Elixir.Filters"}],
      default_libraries: [:"Elixir.Filters"]
    ])
    recompile()
  end
end


alias Commands, as: C
