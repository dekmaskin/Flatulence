# Changelog

All notable changes to Flatulence are documented here.

## [Unreleased]

- Nothing yet.

## [1.0.0]

Initial release.

- Plays a random fart sound when you use the `/fart` emote (hooked, non-tainting).
- Adds an independent `/prrt` emote (alias `/brap`) that plays a sound and posts
  one of 15 randomized custom fart lines instead of the stock emote text.
- Reacts to other Flatulence users in your group with one of 40+ custom emotes,
  ranging from extreme disgust to utter delight.
- Listeners hear the same sound the farter played (matched by sound index).
- Config via `/flatulence`: toggle your sound, reactions, reaction chance, and
  whether you hear others.
- Multi-version support (retail, Mists, Cataclysm, Wrath, Classic Era) via
  per-flavor TOC files sharing one `Core.lua`.
- Ships with no bundled audio; users supply their own sound files.
