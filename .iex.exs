defmodule Commands do
  def rec do
    :erlydtl.compile_dir('templates', :templates, [
      out_dir: "templates_out",
      libraries: [{:"Elixir.Filters", :"Elixir.Filters"}],
      default_libraries: [:"Elixir.Filters"]
    ])
    recompile()
  end
end


alias Commands, as: C
