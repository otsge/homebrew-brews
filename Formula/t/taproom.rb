class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "80609d839488c34c8bf870b70430955fa600266fda16298c79a6c48c529404f0"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "aa7e1be4acc191ee9e73fa4669da141edf77ce2e6c5ccbee2d5dd17bd9908e23"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1aa3a648a32a15f7234d68686bb669538ca242c526aca7a534b3f9acffa280ea"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fbae5794ed1a0cb43678dd5befff51ae26145379d6016758d2ca8e0ff3d610ab"
    sha256 cellar: :any_skip_relocation, tahoe:         "e1c8c80fa97f2f066d52ddff14f68391fcb94e9b85ebb2efa7cc9119ae8fff4d"
    sha256 cellar: :any_skip_relocation, sequoia:       "ddd4a28b5c4a79a6f59f981d2c2af27223efaf3ecbcd1d4959538e2a6832494d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "baf91c11e0fd374899df716460f873a037492f288f8acb1fa573acb6d801b4c2"
    sha256 cellar: :any,                 x86_64_linux:  "a33147b3a242ea61001487dfb3dfdc6992dcee47b70319236c34afc6ca14d29e"
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", *std_go_args(ldflags: "-s -w")
  end

  test do
    require "pty"
    require "expect"
    require "io/console"
    timeout = 30

    PTY.spawn("#{bin}/taproom --hide-columns Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Casks", timeout), "Expected cask loading message"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
