# frozen_string_literal: true

# Template of the formula in hoptail-app/homebrew-tap (ADR-0021, item 3). release.sh fills in the version, each
# platform's url and sha256 and the bottles' root_url and sha256s for each release (formula.sh: an url line names its
# platform, the sha256 line after it is that platform's) and pushes the result to the tap; edit everything else here.
class Hoptail < Formula
  desc "Daemon for the Hoptail iPhone app: tmux and coding agents from your phone"
  homepage "https://hoptail.app"
  # Explicit: each platform's url carries the same version, and a file:// url (local-tap.sh) would give "64" of arm64.
  version "0.1.12"
  license :cannot_represent # closed binary, see LICENSE in the release archive

  on_macos do
    # Apple silicon only; macOS 15 is the oldest Homebrew supports there (release/daemon/README.md).
    url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.12/hoptail-0.1.12-darwin-arm64.tar.gz"
    sha256 "74111e7a86c29cf638dcd243f87d05fb7371865afdb6e247bd0a8e180092fcb7"
    depends_on arch: :arm64
    depends_on macos: :sequoia
  end
  on_linux do
    # Linux (#190): x64 and arm64, glibc 2.28+, systemd 240+ for the user service (release/daemon/README.md). A Mac-only
    # release (release.sh with LINUX=0) leaves this block out.
    on_intel do
      url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.12/hoptail-0.1.12-linux-x64.tar.gz"
      sha256 "72a5b2f461cfdfd5961ee59d0c5370d130816d70cdd76802c4cd5396f30af434"
    end
    on_arm do
      url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.12/hoptail-0.1.12-linux-arm64.tar.gz"
      sha256 "c97cfeec3221eae94a6f5fd01b63859e3150548c937c32f78b9289eeb7360a02"
    end
  end

  # The same files as bottles, so brew pours them: without one brew treats the formula as a source build and refuses
  # Command Line Tools older than macOS (#144). A bottle per platform, not `all`: with on_linux an `all` bottle would
  # pour the Mach-O on Linux. arm64_sequoia serves every newer macOS too; nothing in the binaries holds the prefix.
  bottle do
    root_url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.12"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c672218f83102d4d28cfd3310185468071ee9a0d5e9df51cb2884cbba290cca8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "805f23fa9a8cc17b8aec05c1e6c26526b3e9472265989968de9f0bd55015a1ab"
    sha256 cellar: :any_skip_relocation, arm64_linux: "96054b429fc2f35b4117a18255c629ab65bce6832606784ca104c3a64af3e608"
  end
  # tmux isn't a dependency: brew upgrades an outdated dependency on every install, and that would swap tmux under
  # the agents already running in it. `hoptail setup` checks for tmux and says how to install it.

  def install
    bin.install "hoptail"
    prefix.install "THIRD_PARTY_NOTICES.txt"
    prefix.install "LICENSE" if File.exist?("LICENSE")
  end

  # Linux (#190): the official Node in the binary needs libatomic.so.1, which minimal and cloud images lack (bare
  # ubuntu:24.04 — daemon-linux.yml). `depends_on "gcc"` doesn't help: its libatomic is under brew's prefix, and the
  # bottle isn't relocated, so the system loader never looks there (checked in a VM, 2026-10-23).
  def caveats
    libatomic = OS.mac? ? "" : "Hoptail needs libatomic1. On Ubuntu or Debian: sudo apt install libatomic1\n"
    <<~EOS
      Hoptail needs tmux. If you don't have it: #{OS.mac? ? "brew install tmux" : "install it with your package manager"}
      #{libatomic}Set up the daemon and pair your iPhone:
        hoptail setup
        hoptail pair
      After brew upgrade, run: hoptail restart
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hoptail version")
  end
end
