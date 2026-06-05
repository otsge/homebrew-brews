class Sshfs < Formula
  env :std

  desc "SSH based file system client built against FUSE-T's installed libfuse3"
  homepage "https://github.com/macos-fuse-t/sshfs"
  url "https://github.com/macos-fuse-t/sshfs/archive/cebbdd331199bf39b0566db236e3d47bfa27ea19.tar.gz"
  version "2026.05.12-cebbdd3"
  sha256 "16a398718194d03f890d4dec5b4c896f98abb10411cfc82dc37f8cf1d143a386"
  license "GPL-2.0-or-later"
  head "https://github.com/macos-fuse-t/sshfs.git", branch: "libfuse3"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any, arm64_tahoe:   "c12aa69cb0200e87497bc5ac96a80f79fca3b112fedc7ccca4ebb11c25ab0aa7"
    sha256 cellar: :any, arm64_sequoia: "d268adafaa074849c65e1575a5639c5d6234a2247e8d32d460c0c168b0379614"
    sha256 cellar: :any, arm64_sonoma:  "bc46692506f86d7cfbec242cc7357bfd7d2dd7f7f06b711cc864a469f838bf9c"
    sha256 cellar: :any, tahoe:         "e81769062df8fd91aa597ebc70379e2ba179bcc3bfb15587aeeca283610e7ae8"
    sha256 cellar: :any, sequoia:       "8f2a17356d4432903e2d564d77ee75936483a89861adcf0cbd0ae5cc484bd00b"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "glib"
  depends_on :macos

  def install
    fuse_t_prefix = Pathname("/Library/Application Support/fuse-t")
    fuse3_pc = fuse_t_prefix/"pkgconfig/fuse3.pc"

    unless fuse3_pc.exist?
      odie <<~EOS
        fuse-t with libfuse3 was not found.

        Install fuse-t first:
          brew install --cask 'otsge/keg/fuse-t'

        Expected pkg-config file:
          #{fuse3_pc}
      EOS
    end

    ENV["PKG_CONFIG"] = Formula["pkgconf"].opt_bin/"pkg-config"
    ENV.prepend_path "PATH", Formula["pkgconf"].opt_bin
    ENV.prepend_path "PKG_CONFIG_PATH", fuse3_pc.dirname
    ENV.append "LDFLAGS", "-Wl,-rpath,/usr/local/lib"

    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    sbin.install_symlink bin/"sshfs" => "mount.sshfs"
    sbin.install_symlink bin/"sshfs" => "mount.fuse.sshfs"
  end

  test do
    assert_match "SSHFS version", shell_output("#{bin}/sshfs -V 2>&1")
  end
end
