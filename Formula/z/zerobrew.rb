class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "47e325a8de0b104fd9ee4a12062ba60b7edd225c951b3bea047603750dd760f1"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b8799481c1602314c0c5077519375349ba92a9a3da69c4ecf9a6e9ba233a1be8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5c96ff8d673e3fa8e7dd7a04115e35d969d7dc7ae39ba62965a5b084535152fa"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "54bceed82fad2f6404cb834882c413af60bf81b817cfde0dd904b529463a5417"
    sha256 cellar: :any_skip_relocation, tahoe:         "7899512ddc19f878665e6e380749c623776e87c7af5605b6d6ce11c2d8759ea5"
    sha256 cellar: :any_skip_relocation, sequoia:       "dbe7485645b174d3c9a72829a79c2ba11cf0a153a84659ddba80cf164a8755d9"
    sha256 cellar: :any,                 arm64_linux:   "b444a8b0b025c0ed192e126e9adf1c056b327138f58270c6740b4faa83adf245"
    sha256 cellar: :any,                 x86_64_linux:  "68838f053078665370c3848b3e174e2c533248331158472437c9609f4e8fbe26"
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
