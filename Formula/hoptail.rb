# frozen_string_literal: true

# Template of the formula in hoptail-app/homebrew-tap (ADR-0021, item 3). release.sh fills in url and sha256 for
# each release (Homebrew reads the version from the url) and pushes the result to the tap; edit everything else here.
class Hoptail < Formula
  desc "Mac daemon for the Hoptail iPhone app: tmux and coding agents from your phone"
  homepage "https://hoptail.app"
  url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.0/hoptail-0.1.0-darwin-arm64.tar.gz"
  sha256 "7a18441a1a26b460fb304a70bd3a76f9f5461f3bfeb43bdc91a02b36d9406ef6"
  license :cannot_represent # closed binary, see LICENSE in the release archive

  # Apple silicon only; macOS 15 is the oldest Homebrew supports there (release/daemon/README.md).
  depends_on arch: :arm64
  depends_on macos: :sequoia
  depends_on "tmux"

  def install
    bin.install "hoptail"
    prefix.install "THIRD_PARTY_NOTICES.txt"
    prefix.install "LICENSE" if File.exist?("LICENSE")
  end

  def caveats
    <<~EOS
      Set up the daemon and pair your iPhone:
        hoptail setup
        hoptail pair
      After brew upgrade, run: hoptail restart
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hoptail version")
  end
end
