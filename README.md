# Hoptail for Mac

The Mac side of [Hoptail](https://hoptail.app), an iPhone app for your tmux sessions and the coding agents in them. The daemon runs on your Mac and lets your iPhone know when an agent needs you.

Needs a Mac with Apple silicon on macOS 15 or later, Homebrew 6 or later, Tailscale on the Mac and the iPhone, and the app from TestFlight (link coming soon).

## Install

```sh
brew install hoptail-app/tap/hoptail
hoptail setup
hoptail pair
```

Then scan the QR code with Hoptail on your iPhone. Step by step, with what `hoptail setup` changes on your Mac: https://hoptail.app/setup.

## Update

```sh
brew upgrade hoptail && hoptail restart
```

## Uninstall

```sh
hoptail uninstall          # add --purge to remove pairings, settings and logs too
brew uninstall hoptail
```

## About

This repository holds the Homebrew formula and the signed, notarized binary in Releases; the source isn't published. Use is covered by [LICENSE](LICENSE). Questions and feedback: feedback@hoptail.app.
