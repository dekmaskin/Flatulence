# Changelog

All notable changes to Flatulence are documented here.

## [Unreleased]

- Nothing yet.

## [1.0.4]

- Fixed the addon reacting to your **own** `/prrt` farts. The self-check relied
  on matching the sender's name, which could miss on connected realms (the
  self-echo arrives as `Name-Realm` while `UnitName` is bare `Name`). It now
  identifies self by GUID (`UnitGUID("player")`), which is immune to realm
  formatting, and only falls back to the name comparison when no GUID is
  available.

## [1.0.2]

- Fixed reactions to nearby players who are **not** in your group or raid. The
  addon listened for the wrong chat event (`CHAT_MSG_TEXT_EMOTE`), which only
  fires for Blizzard's built-in emotes. Custom `/prrt` emotes arrive as
  `CHAT_MSG_EMOTE`, so proximity reactions now work for anyone in emote range,
  no group required.

## [1.0.1]

- Added `/toot` as an additional alias for the `/prrt` emote (alongside `/brap`).
- Fixed the Wago project ID in the TOC files.

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
