require 'open3'
require 'digest'

class Steno
  attr_accessor :sub

  def initialize
    @cookie  = ENV.delete("COOKIE")  || "COOKIE"
    @sub     = ENV.delete("SUB") or raise Exception.new("Must set SUB env var")
    @timeout = ENV.delete("TIMEOUT") || 60
    @ktime   = @timeout + 10
    @hashes  = {}
  end

  def hash_file(path)
    Digest::SHA256.digest(File.read(path))
  end

  def save_grading_hashes(xs)
    xs.each do |name|
      hash = hash_file("grading/#{name}")
      @hashes[name] = hash
    end
  end

  def check_grading_hashes
    @hashes.each do |name, hash0|
      hash1 = hash_file("grading/#{name}")
      if hash0 != hash1
        puts "Hash mismatch for _grading/#{name}"
        puts "Hax!"
        exit(1)
      end
    end
  end

  def shell(cmd)
    cmd.gsub!(%q{"}, %q{\"})
    system(%Q{timeout -k #{@ktime} #{@timeout} "#{cmd}"})
  end

  def unpack
    if @sub =~ /\.zip$/i
      shell(%Q{unzip "#{@sub}"})
    end
    if @sub =~ /\.tar$/i
      shell(%Q{tar xf "#{@sub}"})
    end
    if @sub =~ /\.tar.gz$/i || @sub =~ /\.tgz$/i
      shell(%Q{tar xzf "#{@sub}"})
    end

    items = Dir.entries(".").reject do |name|
      name =~ /^\./ || name == "_grading"
    end

    if items.size == 1 && File.directory?(items[0])
      dirname = items[0]
      shell(%Q{mv #{dirname}/* .})
    end
  end

  def run_tests(cmd)
    output = ""
    errors = ""

    cmd.gsub!(%q{"}, %q{\"})
    Open3.popen3(%Q{timeout -k #{@ktime} #{@timeout} "#{cmd}"}) do |_in, out, err, _wait|
      until out.eof? || err.eof?
        begin
          tmp = out.read_nonblock(256)
          output << tmp
          $stdout.write(tmp)
          tmp = err.read_nonblock(256)
          errors << tmp
          $stderr.write(tmp)
        rescue IO::WaitReadable
          IO.select([out, err], nil, nil, 1.0)
        end
      end
    end

    puts @cookie
    puts output
    puts @cookie
    puts "\n== Stderr ==\n"
    puts errors
  end
end

