class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "e35b4f20a04866e67c553e2467f9f57e254b67ada1a2e53c74aa9fbf174f5a3d"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "424ab47c187d207d31815d03c9db470f25ab12c3a358a8c2459410869e9a0432"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9a188032858fd774d96e32c51251a8ec657ba81b21d9c99ef3c13d87983cfa3b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f5ba3326e30893cf3deefbdda93c3fe0fc83f14a582f8ca0325faa24c0af81f7"
    sha256 cellar: :any_skip_relocation, tahoe:         "65f66bf07228a7c6c96cf222150d64a6329ffe3d3fe33cc6804d7f4598c5a9ff"
    sha256 cellar: :any_skip_relocation, sequoia:       "17773f56adcf8b5677223aea58dd24254c1c460dff0324c9eae396ccc8247cac"
    sha256 cellar: :any,                 arm64_linux:   "f9b0896c7b08aedc098dc98dc37bd9be80e95ffcf11c1cd50291f2e80615ff58"
    sha256 cellar: :any,                 x86_64_linux:  "ec926f35430edfdff689312b15525e6f4476945f2246d92629d1c4b916e8aca7"
  end

  depends_on "rust" => :build

  def install
    ENV["LZMA_API_STATIC"] = "1"

    system "cargo", "install", *std_cargo_args(path: "zb_cli")

    generate_completions_from_executable(bin/"zb", "completion",
                                         shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    system bin/"zb", "--version"
  end
end
