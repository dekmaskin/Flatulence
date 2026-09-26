# Flatulence

A tiny World of Warcraft addon that plays a random fart sound and posts a matching emote when you use its own `/prrt` or `/toot` command. Works on retail, Mists Classic, Cataclysm, Wrath, and Classic Era.

## What it does

- Adds `/prrt` (aliases `/brap`, `/toot`): plays a weighted-random sound (rare ones stay rare, no immediate repeats) and posts that sound's signature emote line.
- Anyone nearby with the addon plays the **same** sound and fires back a reaction — no group required. The emote line itself is the signal.
- Two reaction flavors: a fast **hearing** reaction to the noise, or a delayed (4–10s) **smell** reaction to the drifting cloud. Each reactor picks one.
- Small chance a reaction also blurts a spoken **/say** retort matching its flavor (default 15%).
- Plays on the **Master** channel (audible even with low SFX volume), falling back to SFX.
- Your own `/prrt` has a 60s personal cooldown, and a **crowd throttle** keeps a single fart to ~1–4 reactions even in a packed city.

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
| `/flatulence say <0-100>` / `off` | Chance of a spoken `/say` retort (default 15%). |
| `/flatulence crowd <1-100>` / `off` | Cap reactions per fart in a crowd (default 4). |
| `/flat` | Short alias for `/flatulence`. |

Settings are saved per account in `FlatulenceDB`.