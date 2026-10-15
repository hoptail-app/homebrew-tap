# frozen_string_literal: true

# Template of the formula in hoptail-app/homebrew-tap (ADR-0021, item 3). release.sh fills in url, sha256 and the
# bottle's root_url and sha256 for each release (Homebrew reads the version from the url) and pushes the result to the
# tap; edit everything else here.
class Hoptail < Formula
  desc "Mac daemon for the Hoptail iPhone app: tmux and coding agents from your phone"
  homepage "https://hoptail.app"
  url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.2/hoptail-0.1.2-darwin-arm64.tar.gz"
  sha256 "767ccfbc390ea9a30c6807055c7088e06c4141d3bba6944585a8272d33180529"
  license :cannot_represent # closed binary, see LICENSE in the release archive

  # The same files as a bottle, so brew pours it: without one brew treats the formula as a source build and refuses
  # Command Line Tools older than macOS (#144). One bottle for all: the binary is the same on every macOS 15+, and
  # nothing in it holds the Homebrew prefix.
  bottle do
    root_url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.2"
    sha256 cellar: :any_skip_relocation, all: "ac11f9f5cdaf45152468cf642851016cc4b15e65799444d58612869a52fd614b"
  end

  # Apple silicon only; macOS 15 is the oldest Homebrew supports there (release/daemon/README.md).
  depends_on arch: :arm64
  depends_on macos: :sequoia
  # tmux isn't a dependency: brew upgrades an outdated dependency on every install, and that would swap tmux under
  # the agents already running in it. `hoptail setup` checks for tmux and says how to install it.

  def install
    bin.install "hoptail"
    prefix.install "THIRD_PARTY_NOTICES.txt"
    prefix.install "LICENSE" if File.exist?("LICENSE")
  end

  def caveats
    <<~EOS
      Hoptail needs tmux. If you don't have it: brew install tmux
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
