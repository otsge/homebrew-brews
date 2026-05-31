class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.8.3",
        revision: "d400a2df41db17ba220cd06973fc8df5c6f2854c"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/brews"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c2de7f3d9ea9deae4501e72cd2f3c9a879029dc434d686ad0b156f805724aabd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1818bc7a23b37c7ac2639e2399bcd27c4c53a950e870f90319028d60eb0e67fb"
    sha256 cellar: :any_skip_relocation, tahoe:         "34ad941478e32cc163b1ce8228a5947fb383b7e3b2481d208f96a98790b7edc5"
    sha256 cellar: :any_skip_relocation, sequoia:       "81844c58b1095b79dc54446bc8cdb3ccd26b9c0c5ead577fd0a697e789cb3b86"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "3a233fcd0283898b13e0ef41c59d6dde0d48a78a337ca560c0c6685c7933d43b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b2c6a42ba485ff9c26f5cd6c40b30c62ac7ce70c4f5282c3344276f192b271db"
  end

  depends_on "go" => :build
  depends_on "go-task" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ENV["GO111MODULE"] = "on"
    ldflags = %W[
      -extldflags=-static
      -s -w
      -X github.com/tgdrive/teldrive/internal/version.Version=#{version}
      -X github.com/tgdrive/teldrive/internal/version.CommitSHA=#{Utils.git_short_head(length: 7)}
    ]
    system "task", "ui"
    system "task", "gen"
    system "go", "build", "-trimpath", *std_go_args(ldflags:)
  end

  test do
    system bin/"teldrive", "version"
  end
end
