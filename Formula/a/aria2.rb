class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any,                 arm64_tahoe:   "aef31ea8baaf493aa79e76dc18f51f7588bb19ed17effdf61ac5762cb68efc04"
    sha256 cellar: :any,                 arm64_sequoia: "a377443877abd3f65ebec71dbf3330b2e5b04ed93e982c12e5f8dd29aeaad082"
    sha256 cellar: :any,                 tahoe:         "59dbd3d75aa52a7c9b3e60f4595403093ade7f893e9fedca3699ed0a0fd75514"
    sha256 cellar: :any,                 sequoia:       "5bed30847fec64601fdb28d697d3bcd894de6b9e06eabd91a3f1950dff3391a4"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9bc5ae173a5737ecdc467f115de005509634114e64cd7496a6201dad1ce131cd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6d873d091d7cf54d5ceab19bdccaa8660866e0e7280266f52644f061cddbd47f"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "c-ares"
  depends_on "otsge/brews/libssh2"
  depends_on "otsge/brews/openssl@4"
  depends_on "sqlite"

  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  patch :DATA

  def install
    ENV.cxx11
    ENV.append "LIBS", "-framework Security" if OS.mac?

    if build.head?
      ENV.append_to_cflags "-march=native -O3 -pipe -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %w[
      --disable-silent-rules
      --disable-nls
      --with-libssh2
      --without-gnutls
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
      --without-appletls
      --with-openssl
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system bin/"aria2c", "https://brew.sh/"
    assert_path_exists testpath/"index.html", "Failed to create index.html!"
  end
end

__END__
--- a/src/LibsslTLSSession.cc
+++ b/src/LibsslTLSSession.cc
@@ -279,17 +279,17 @@ int OpenSSLTLSSession::tlsConnect(const std::string& hostname,
           dnsNames.push_back(std::string(name, name + len));
         }
         else if (altName->type == GEN_IPADD) {
-          const unsigned char* ipAddr = altName->d.iPAddress->data;
+          auto ipAddr = ASN1_STRING_get0_data(altName->d.iPAddress);
           if (!ipAddr) {
             continue;
           }
-          size_t len = altName->d.iPAddress->length;
+          size_t len = ASN1_STRING_length(altName->d.iPAddress);
           ipAddrs.push_back(
               std::string(reinterpret_cast<const char*>(ipAddr), len));
         }
       }
     }
-    X509_NAME* subjectName = X509_get_subject_name(peerCert);
+    const X509_NAME* subjectName = X509_get_subject_name(peerCert);
     if (!subjectName) {
       handshakeErr = "could not get X509 name object from the certificate.";
       return TLS_ERR_ERROR;
@@ -301,7 +301,7 @@ int OpenSSLTLSSession::tlsConnect(const std::string& hostname,
       if (lastpos == -1) {
         break;
       }
-      X509_NAME_ENTRY* entry = X509_NAME_get_entry(subjectName, lastpos);
+      const X509_NAME_ENTRY* entry = X509_NAME_get_entry(subjectName, lastpos);
       unsigned char* out;
       int outlen = ASN1_STRING_to_UTF8(&out, X509_NAME_ENTRY_get_data(entry));
       if (outlen < 0) {
