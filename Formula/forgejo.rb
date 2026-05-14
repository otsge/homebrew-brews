class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.1/forgejo-src-15.0.1.tar.gz"
  sha256 "c57b8aaf0f5e4b041f6e47238bff0366f47ef2757ac3bda588300e588d8142fd"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f8edfd71eb6b41292947565764b33109f75579e814f26e58f40742f80b5b22e0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5ba5779a7689842340b4578ecdb1d42f9f410a2d5018a49092a6d8870daf88cc"
    sha256 cellar: :any_skip_relocation, tahoe:         "b82a948fb6541183491bb7c1fa5374e4a912570b2249181f4e71cd8dec88e187"
    sha256 cellar: :any_skip_relocation, sequoia:       "20dcc65d688cb73004faf1d946ca4703f15b4fdfa909dbe2c7963a7921593b01"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "35c3c266825208cb4dca617589f1bb2aec5877e8e2a3221db89a970c158ca965"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f49436063aa4dd394db50a99834fd2f9d71ad8d93df212a8391535d28e7b1cad"
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
