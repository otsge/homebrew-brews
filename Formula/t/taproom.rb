class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "80609d839488c34c8bf870b70430955fa600266fda16298c79a6c48c529404f0"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e79efd81018d261aaa6663d93eb028fa51781b16c317c14616b2491936bca0a5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3bdf5aa46dc3521fc3990459e43048b4de0e734abd650f7925a96464a15a29ff"
    sha256 cellar: :any_skip_relocation, tahoe:         "c17f5192947a0b805aa19f3ea91f215e96b067c6c9f64f4569bc9115ee83f7d9"
    sha256 cellar: :any_skip_relocation, sequoia:       "0b6965cf3b6c0fda41c4bf55ff4638b8aeb1933bfdf55f2b9ccf13bee3040ce3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "2a293eae4311844711248773c8bc795516f7dead7cdf3b9259ee323ec5ac703f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "01efaeba9bf3a94887c02ca63e8386e751a876743cd68cebd7e47947606f70b4"
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
