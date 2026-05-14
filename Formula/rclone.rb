class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.1.tar.gz"
  sha256 "aa0470151fe2e33d6bb96657892dfc4d56f92472a2dedebdda4ff296e87b79dc"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "261f572373fd8ee31d34e3fa402928de197a58066939eabc5a8b36b9df9e8b0c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4e42cf11d2803fb6c22206a4629980f2ebc5fc7a0c3593f0a9e5f26fa70f8e42"
    sha256 cellar: :any_skip_relocation, tahoe:         "f382d5f353f81c2b1e6d8d65e4dde18c447a8347857c75bc2644051d249e6569"
    sha256 cellar: :any_skip_relocation, sequoia:       "3041321770070b2fc63c3b2cf2b701409ebe63b92607ad00f7fc5b9bc9cd5832"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "2cd9aa4b076e6d629613f4288afd76ff5f6c1fb651722d86911e3454a7cad556"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4faea8af7a0055cbfe5a7e33cde8c887c3e8ce8f5254d44f6dc428b5010bd849"
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
