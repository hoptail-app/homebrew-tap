# frozen_string_literal: true

# Template of the formula in hoptail-app/homebrew-tap (ADR-0021, item 3). release.sh fills in the version, each
# platform's url and sha256 and the bottles' root_url and sha256s for each release (formula.sh: an url line names its
# platform, the sha256 line after it is that platform's) and pushes the result to the tap; edit everything else here.
class Hoptail < Formula
  desc "Daemon for the Hoptail iPhone app: tmux and coding agents from your phone"
  homepage "https://hoptail.app"
  # Explicit: each platform's url carries the same version, and a file:// url (local-tap.sh) would give "64" of arm64.
  version "0.1.24"
  license :cannot_represent # closed binary, see LICENSE in the release archive

  on_macos do
    # Apple silicon only; macOS 15 is the oldest Homebrew supports there (release/daemon/README.md).
    url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.24/hoptail-0.1.24-darwin-arm64.tar.gz"
    sha256 "d2eb960e4905b9e3f75db3814da6a7df8228f7c904d451c1d7f073988ba7715e"
    depends_on arch: :arm64
    depends_on macos: :sequoia
  end
  on_linux do
    # Linux (#190): x64 and arm64, glibc 2.28+, systemd 240+ for the user service (release/daemon/README.md). A Mac-only
    # release (release.sh with LINUX=0) leaves this block out.
    on_intel do
      url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.24/hoptail-0.1.24-linux-x64.tar.gz"
      sha256 "a407c170db0e77732f0685de5c280f380bf1e223e2704758b3b5b85633a55ab2"
    end
    on_arm do
      url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.24/hoptail-0.1.24-linux-arm64.tar.gz"
      sha256 "975858263a5e28dc8f91b500aa3f88e157834ed15c6834626e517bd4e3d9bc60"
    end
  end

  # The same files as bottles, so brew pours them: without one brew treats the formula as a source build and refuses
  # Command Line Tools older than macOS (#144). A bottle per platform, not `all`: with on_linux an `all` bottle would
  # pour the Mach-O on Linux. arm64_sequoia serves every newer macOS too; nothing in the binaries holds the prefix.
  bottle do
    root_url "https://github.com/hoptail-app/homebrew-tap/releases/download/v0.1.24"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6c25534eba3fa8afb69d60b19b4dcbcc7a4631342b20c2ac2a8ea26055254753"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9a6828a3a207cdfeefc51ec81cce0e5107be2669ff9fcf04f9097eb0b677eb9f"
    sha256 cellar: :any_skip_relocation, arm64_linux: "1cc09c549493c8ff9125dc38637ec74778beb426043ced0ab0a74f0ca69fcc6b"
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
