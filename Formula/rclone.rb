class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.2.tar.gz"
  sha256 "2373a74751cfd2034cc6b792a9a15d119087cb77975f3c9fcd7a4503c15102b0"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b78047dc063abefc8ffac0e2c8540c23e59c4197b0d73245939403eeb3412ce2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2ee5ad403c5996199c58e4989f505b151215f55796c6b88aa210b8acf2e54cc8"
    sha256 cellar: :any_skip_relocation, tahoe:         "acced8e47e11fa323250c454d096f82fc1aae76e2ecfbe240a9cf5ea6836f3ab"
    sha256 cellar: :any_skip_relocation, sequoia:       "ed309bbf79869b9c390317dac9b39cf861a6de00c4cc51b9c446701e2f96037a"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "602f7657989076ffff1f1a9c0da52175ea1cd80d658925aaab6cf29161590a28"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5ea7bc675a2bdad78fc4f535daf4edeac06229c2f09c72d43e6b4b1eafb33375"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = "#{HOMEBREW_CACHE}/go_mod_cache/pkg/mod"

    if OS.mac? && Hardware::CPU.arm?
      ENV.append "CGO_FLAGS", "-I/usr/local/include"
      ENV.append "CGO_LDFLAGS", "-L/usr/local/lib"
    end

    args = ["GOTAGS=cmount"]
    system "make", *args
    man1.install "rclone.1"
    system bin/"rclone", "genautocomplete", "bash", "rclone.bash"
    system bin/"rclone", "genautocomplete", "zsh", "_rclone"
    system bin/"rclone", "genautocomplete", "fish", "rclone.fish"
    bash_completion.install "rclone.bash" => "rclone"
    zsh_completion.install "_rclone"
    fish_completion.install "rclone.fish"
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
