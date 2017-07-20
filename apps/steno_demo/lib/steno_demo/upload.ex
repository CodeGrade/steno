defmodule StenoDemo.Upload do
  def dir(up) do
    Path.join("/tmp/steno", up.key)
  end

  def path(up) do
    Path.join(dir(up), up.name)
  end

  def save!(up, file) do
    :ok = File.mkdir_p(dir(up))
    {:ok, _} = File.copy(file.path, path(up))
    :ok
  end
end
