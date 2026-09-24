# Flatulence

A tiny World of Warcraft addon that plays a random fart sound and posts a matching emote when you use its own `/prrt` or `/toot` command. Works on retail, Mists Classic, Cataclysm, Wrath, and Classic Era.

## What it does

- Adds `/prrt` (aliases `/brap`, `/toot`): plays a weighted-random sound (rare ones stay rare, no immediate repeats) and posts that sound's signature emote line.
- Anyone nearby with the addon plays the **same** sound and fires back one of 40+ reactions — no group required. The emote line itself is the signal.
- Plays on the **Master** channel (audible even with low SFX volume), falling back to SFX.
- A cooldown and optional chance roll keep reactions from spamming.

Both players need the addon for sync/reactions. Players without it just see a normal emote line.

## Install

Extract the release zip's `Flatulence` folder into your AddOns directory so the path is `...\Interface\AddOns\Flatulence\Core.lua`:

- Retail: `_retail_\Interface\AddOns\`
- Classic (Mists / Cata / Wrath): `_classic_\Interface\AddOns\`
- Classic Era: `_classic_era_\Interface\AddOns\`

## Commands

| Command | Effect |
| --- | --- |
| `/prrt` (`/brap`, `/toot`) | Play a random sound + post its emote; nearby addon users sync and react. |
| `/flatulence on` / `off` / `toggle` | Enable or disable your own sounds. |
| `/flatulence test` | Play a random sound now. |
| `/flatulence react on` / `off` | Toggle reacting to others' farts. |
| `/flatulence react <0-100>` | Set your reaction chance %. |
| `/flatulence hear on` / `off` | Hear (or mute) others' farts. |
| `/flat` | Short alias for `/flatulence`. |

Settings are saved per account in `FlatulenceDB`.