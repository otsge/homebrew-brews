class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.2/forgejo-src-15.0.2.tar.gz"
  sha256 "c52a7df751de7426657bc06df336248e05fb663bcc9205e870557ce6a020a199"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0ed45cb834988fef283269fa26d52ed84a5fa56cd1fadddd942a861aabd1abbc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "23f8897ab8ef3f3bef24eac1456e6ca526b274319b227b6d20a771fd8fdc1d5f"
    sha256 cellar: :any_skip_relocation, tahoe:         "e9292a5533a7cbf293774c2713f0eb7300ef62f844a0a511401562e5be5423e5"
    sha256 cellar: :any_skip_relocation, sequoia:       "6c409e08ab442102e62450c95d54f30c9cc16b2aa2240afbdfb650e2a1672458"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7893641824287d0bc03b13bb808df00b7bd3e1e7fc1b5cb66ac1d1d66efd2458"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2bd2e3db9337aa54cc4b9abb6bce38bd1c06f62e0a1b18facb843572d9c037dc"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea" => "forgejo"
    bin.install "environment-to-ini"
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path var/"log/forgejo.log"
    error_log_path var/"log/forgejo.log"
  end

  test do
    ENV["FORGEJO_WORK_DIR"] = testpath
    port = free_port

    pid = spawn bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s

    output = shell_output("curl --silent --retry 5 --retry-connrefused http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl --silent http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
