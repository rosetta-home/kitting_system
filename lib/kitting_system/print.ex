defmodule KittingSystem.Print do

  def compile_template(id \\ "507f1f77bcf86cd799439011", template \\ "label.zpl") do
    f = Path.join(:code.priv_dir(:kitting_system), "#{template}.compiled")
    st = EEx.eval_file(Path.join(:code.priv_dir(:kitting_system), template), [id: id])
    File.write(f, st)
    f
  end

  def print(file) do
    System.cmd("cp", [file, "/dev/usb/lp0"])
  end

end
