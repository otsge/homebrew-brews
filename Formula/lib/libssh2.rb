class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol"
  homepage "https://libssh2.org/"
  url "https://libssh2.org/download/libssh2-1.11.1.tar.gz"
  mirror "https://github.com/libssh2/libssh2/releases/download/libssh2-1.11.1/libssh2-1.11.1.tar.gz"
  mirror "http://download.openpkg.org/components/cache/libssh2/libssh2-1.11.1.tar.gz"
  sha256 "d9ec76cbe34db98eec3539fe2c899d26b0c837cb3eb466a56b0f109cabf658f7"
  license "BSD-3-Clause"

  livecheck do
    url "https://libssh2.org/download/"
    regex(/href=.*?libssh2[._-]v?(\d+(?:\.\d+)+)\./i)
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any,                 arm64_tahoe:   "c244a56c3c72efdfd73cb903ddf3fe8749b79d63d53d85e01a2d8e05e31b8f46"
    sha256 cellar: :any,                 arm64_sequoia: "3763f0235e1cdfa3b885a676d02e73329cce09fdf54b8d3fafddbe8782a81d9a"
    sha256 cellar: :any,                 tahoe:         "aca190a5756f0c80dbbbab8143353b081f626b7b808c0ef6e76d5becd38a7c9d"
    sha256 cellar: :any,                 sequoia:       "c52ca2b99defb6ca2f28fe60dc313eddcdfea49e3a56213db129241c9db1fb99"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "13bfd6417c0f36be77ebec674ca518fa82c2f8acdc2aa043fddbaf9b2fdafe81"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "23efff3e7a6711c29ef02d9f998f77ac8789096a43a2c2dcf28e7b09fbd0446f"
  end

  head do
    url "https://github.com/libssh2/libssh2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "otsge/brews/openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    args = %W[
      --disable-silent-rules
      --disable-examples-build
      --with-openssl
      --with-libz
      --with-libssl-prefix=#{Formula["openssl@4"].opt_prefix}
    ]

    system "./buildconf" if build.head?
    system "./configure", *std_configure_args, *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libssh2.h>

      int main(void)
      {
      libssh2_exit();
      return 0;
      }
    C

    system ENV.cc, "test.c", "-L#{lib}", "-lssh2", "-o", "test"
    system "./test"
  end
end
