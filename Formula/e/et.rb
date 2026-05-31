class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTerminal/"
  url "https://github.com/MisterTea/EternalTerminal/archive/refs/tags/et-v6.2.11.tar.gz"
  sha256 "e8e80800babc026be610d50d402a8ecbdfbd39e130d1cfeb51fb102c1ad63b0f"
  license "Apache-2.0"
  head "https://github.com/MisterTea/EternalTerminal.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any,                 arm64_tahoe:   "0f8b0fedc76a5de66e14ef0aa6d4f414f920a798e6ee779b4155f20eab048eee"
    sha256 cellar: :any,                 arm64_sequoia: "183da3bcd61dc7418c398bf44d26179e4eca313792a74a0e05c286bb7336072a"
    sha256 cellar: :any,                 tahoe:         "6736dd65943820dcd079d3f875a8ebeaf4a2b6f93a74394d15199259fede06e8"
    sha256 cellar: :any,                 sequoia:       "1863a000fc9489c73a51f56940f0ca9415c49b2dce42189d83e9b6a4d8e47cdb"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "14562b54ec28a3b68b4dda62b3fac116fcd496483753de4d95a201435c4478e7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "46dc2b17b9c01c5edb91b76692d6cbcd8508eccdd464c518c29355d24e0f9d8e"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "libsodium"
  depends_on "otsge/brews/openssl@4"
  depends_on "protobuf"

  on_linux do
    depends_on "brotli"
    depends_on "zlib-ng-compat"
  end

  def install
    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"
    # Avoid over-linkage to `abseil`.
    ENV.append "LDFLAGS", "-Wl,-dead_strip_dylibs" if OS.mac?

    args = %W[
      -DDISABLE_VCPKG=ON
      -DDISABLE_SENTRY=ON
      -DDISABLE_TELEMETRY=ON
      -DBUILD_TESTING=OFF
      -DBASH_COMPLETION_COMPLETIONSDIR=#{bash_completion}
      -DOPENSSL_ROOT_DIR=#{Formula["openssl@4"].opt_prefix}
      -DPYTHON_EXECUTABLE=#{which("python3")}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    etc.install "etc/et.cfg"
  end

  service do
    run [opt_bin/"etserver", "--cfgfile", etc/"et.cfg"]
    keep_alive false
    working_dir HOMEBREW_PREFIX
    error_log_path "/tmp/etserver.err"
    log_path "/tmp/etserver.log"
    require_root true
  end

  test do
    port = free_port
    pid = fork do
      exec bin/"etserver", "--port", port.to_s, "--logtostdout"
    end

    begin
      require "socket"
      Timeout.timeout(60) do
        loop do
          TCPSocket.open("127.0.0.1", port).close
          break
        rescue Errno::ECONNREFUSED
          sleep 1
        end
      end
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
