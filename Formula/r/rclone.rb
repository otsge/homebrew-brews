class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.3.tar.gz"
  sha256 "3ba8bc7fb216f8f0307357ac67842467f453050468d5751e9269954819148568"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "3810c6f3736def945cc133ec7027d7d1a02f16b272ead0746f5d3165dacb3563"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5c7ebe6a604e859d8fc2709ff56ee0b454568a9058057868c4e4fe71622953c3"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a7ae45d15c0aaa238efe85d24a65482aab789d52f3111cbc9eabd1e2d98bf406"
    sha256 cellar: :any_skip_relocation, tahoe:         "e43d8796998613ae00b03588ebe16c5a0629bd7e2a15101e01e1bc3756b2289c"
    sha256 cellar: :any_skip_relocation, sequoia:       "a85f234b466ca361891c0fc580e525515b378924917d2f5462846d127ffb8eac"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "dfc4350a795e1afdcefa2ba1d370a1f8ef93b9cdb1561ca94269d82ab0fd7386"
    sha256 cellar: :any,                 x86_64_linux:  "dc549a12928ae2056320a88137a3c9b6e2a5b69ed09802a6e47f1aeb5a210f28"
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
