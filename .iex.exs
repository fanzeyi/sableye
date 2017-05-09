defmodule Commands do
  def rec do
    :erlydtl.compile_dir('templates', :templates, [out_dir: "templates_out"])
    recompile()
  end
end


alias Commands, as: C
