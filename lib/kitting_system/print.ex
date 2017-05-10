defmodule KittingSystem.Print do

  def compile_template(id \\ "507f1f77bcf86cd799439011", template \\ "label.zpl") do
    template_path = Path.join(:code.priv_dir(:kitting_system), template)
    output_path = Path.join(:code.priv_dir(:kitting_system), "#{template}.compiled")
    :ok = output_path |> File.write(template_path |> EEx.eval_file([id: id]))
    output_path
  end

  def send(file) do
    System.cmd("cp", [file, "/dev/usb/lp0"])
  end

end
