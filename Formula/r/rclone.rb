class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.3.tar.gz"
  sha256 "3ba8bc7fb216f8f0307357ac67842467f453050468d5751e9269954819148568"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d7a9dedce5de8d4fd0a476b4c0d0dc9a88b98d6aa1c1ac2f01a0af4323ac0e66"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b7c90a2db391619efaee096d5eecc5e3f677721338e7cfb49fb6f03e4d66aaf2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "cc7b95324fbecef1a37d4dd5fcfb7eb7d1c8f2d2ad11287eef8b18dbba1faa62"
    sha256 cellar: :any_skip_relocation, tahoe:         "8dd13938971e75129cdc0adf858d1676d694d9978a9354f915b8ffd131c12bb9"
    sha256 cellar: :any_skip_relocation, sequoia:       "4257db3aa9bbb19235d8f6e5b216f1346902bddde98a1acde72dca6c862bfcd4"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "cd78e2a0465e8cda86e03084c0e4ed9e7efd64a09bc64d97957403b121fa2a49"
    sha256 cellar: :any,                 x86_64_linux:  "733df724f80a095526a3e7256f61a95c0fc77d1c73599f5f8a713553fd729197"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = buildpath/".brew_home/go_mod_cache/pkg/mod"

    if OS.mac?
      fuse_prefix = Pathname("/usr/local/lib")
      fuse_pc = fuse_prefix/"pkgconfig/fuse.pc"

      unless fuse_pc.exist?
        odie <<~EOS
          FUSE was not found.

          Install FUSE first with either:
            fuse-t:  brew install --cask 'otsge/keg/fuse-t'
            macfuse: brew install --cask 'macfuse'
          Expected pkg-config file:
            #{fuse_pc}
        EOS
      end
    end

    system "make", "GOTAGS=cmount"
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
