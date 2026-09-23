# Flatulence

A tiny World of Warcraft addon that plays a random fart sound every time you
use the `/fart` emote. Built to be trivially portable across game versions —
retail, Mists of Pandaria Classic, Cataclysm, Wrath, and Classic Era.

## What it does

- Hooks the game's emote system so any `/fart` (typed by you) triggers a sound.
- Adds its own independent **`/prrt`** emote (alias `/brap`) that plays a sound
  and posts a random custom fart line of its own — no stock Blizzard emote text.
  See [The two ways to fart](#the-two-ways-to-fart) below.
- Picks a random file from your sound pool and avoids repeating the same one twice in a row.
- Plays on the **Master** channel so it's audible even if in-game SFX volume is low, with an automatic fall back to the SFX channel.
- **Reacts to other players who also run Flatulence.** When someone in your
  group farts, you hear the same sound they played *and* your character fires
  back one of 40+ custom emotes ranging from extreme disgust to utter delight.
  See [Reactions](#reactions) below.
- Ships with a small config command; the emote itself needs no configuration.

## The two ways to fart

There are two commands that trigger a fart, and they behave differently on
purpose:

- **`/fart`** — Blizzard's built-in emote. The addon hooks it, so you get the
  game's stock emote text ("*YourName* farts. How crude.") **plus** your custom
  sound and the groupmate broadcast. Familiar and discoverable; you don't own
  the emote text.
- **`/prrt`** (alias `/brap`) — the addon's own emote, fully independent of
  Blizzard's. It plays a random sound, broadcasts to groupmates, and posts one
  of its own randomized fart lines (e.g. "*YourName* unleashes a thunderous rip
  that echoes off the walls.") instead of the stock text. Use this when you want
  the addon to own the whole experience.

Both play a sound, both notify groupmates (who then hear it and react). The only
difference is the emote text that accompanies them. The `/prrt` action lines
live in the `FART_ACTION_EMOTES` table at the top of `Core.lua` — add or rewrite
them freely; each continues the sentence "`<YourName> ...`".

## Reactions

When you `/fart` or `/prrt`, the addon sends a hidden addon message. Anyone nearby who is
**also running Flatulence** picks a random reaction and performs it back at you
as a custom text emote — so a fart in a group gets a chorus of gagging,
laughing, cheering, and glaring.

The reactions are 40+ hand-written custom emotes ranging from **extreme
disgust** ("gags violently and looks for the nearest exit.") through amusement
and delight, all the way to a few that are **suspiciously into it** ("fans
themselves and whispers, 'do that again.'"). They're
posted as normal `/emote` text, so once triggered they're visible to *everyone*
around the reacting player, not just the group.

Details and limitations:

- **The trigger is group-scoped.** WoW does not provide an addon communication
  channel for "everyone in shouting distance," so the fart notification travels
  on your party/raid/instance channel. Reactions therefore come from people
  grouped with you (party, raid, dungeon, or battleground). Random strangers in
  a city won't react, even if they have the addon. (The reaction emote itself,
  once fired, is a normal text emote seen by everyone nearby.)
- **Both players need the addon** for a reaction to trigger. Players without
  Flatulence just see your normal `/fart` emote.
- **Listeners also hear the fart.** When a groupmate farts, your client plays
  the sound locally too — and it plays *the same* sound they did, not a random
  one. This works by sending the sound's list index in the message, so it only
  matches correctly when both players share the same `SOUND_FILES` list in the
  same order (e.g. the same addon install). If the lists differ, the listener
  falls back to a random sound rather than erroring. Toggle this with
  `/flatulence hear off`.
- A per-client cooldown and an optional chance roll keep reactions from turning
  into spam or feedback loops. (The cooldown gates the emote reaction; the
  heard sound plays each time.)

### Customizing the reactions

The reaction text lives in the `RESPONSE_EMOTES` table at the top of `Core.lua`,
loosely ordered from disgust to delight (selection is random; the ordering is
just for readability). Each entry continues the sentence
"`<YourName> ...`", so write them accordingly, e.g.
`"wrinkles their nose and takes a careful step away."`.

Prefer the game's built-in stock emotes (`/cough`, `/laugh`, etc.) instead of
custom sentences? Set `USE_STOCK_EMOTES = true` near the top of `Core.lua`; it
will then react using the tokens in `STOCK_EMOTE_TOKENS`.

## Install

**From a release zip (CurseForge / Wago / WoWInterface):** the zip already
contains a `Flatulence` folder. Extract it straight into your AddOns directory
for the version you play:

- Retail: `World of Warcraft\_retail_\Interface\AddOns\`
- Mists Classic: `World of Warcraft\_classic_\Interface\AddOns\`
- Classic Era: `World of Warcraft\_classic_era_\Interface\AddOns\`

The final path must be `...\Interface\AddOns\Flatulence\Core.lua`.

**From a git clone (for development):** the addon files live at the repository
root, so copy/symlink the repo into a folder literally named `Flatulence` inside
`AddOns\` (the packager produces this folder name automatically for releases).

Then:

1. Add your sound files to `Flatulence\Sounds\` (see below).
2. Fully restart the game client (not just `/reload`).
3. Enable **Flatulence** on the character-select AddOns list.

## Add your own sounds

1. Drop `.ogg` or `.mp3` files into `Flatulence\Sounds\`.
2. Make sure each file is listed in the `SOUND_FILES` table near the top of
   `Core.lua`. The defaults expect `fart1.mp3` … `fart9.mp3`.
3. **Fully restart the client.** WoW indexes sound files on disk at launch, so a
   `/reload` will not pick up newly added audio.

> **Publishing?** The addon ships with **no audio** — you must add your own, and
> you must have the right to redistribute anything you bundle in a public
> release. See `Sounds/README.txt` for licensing guidance and format details.

## Commands

| Command | Effect |
| --- | --- |
| `/fart` | Blizzard's emote (hooked) — random sound + stock text, notifies groupmates. |
| `/prrt` (alias `/brap`) | The addon's own emote — random sound + random custom line, notifies groupmates. |
| `/flatulence on` / `off` / `toggle` | Enable or disable your own sounds. |
| `/flatulence test` | Play a random sound now. |
| `/flatulence react on` / `off` | Enable or disable reacting to others' farts. |
| `/flatulence react <0-100>` | Set the % chance you react (e.g. `react 50`). |
| `/flatulence hear on` / `off` | Hear (or mute) the sound when others fart. |
| `/flat` | Short alias for `/flatulence`. |

Settings are saved per account in the `FlatulenceDB` saved variable.

## Porting to another / newer game version

The design keeps everything version-specific in two places:

1. **The `.toc` Interface number.** WoW's Multi-TOC system loads a `.toc` whose
   filename suffix matches the running client, all sharing the same `Core.lua`:

   | File | Client | Interface (at time of writing) |
   | --- | --- | --- |
   | `Flatulence_Mainline.toc` | Retail | `110100` |
   | `Flatulence_Mists.toc` | Mists of Pandaria Classic | `50504` |
   | `Flatulence_Cata.toc` | Cataclysm Classic | `40402` |
   | `Flatulence_Wrath.toc` | Wrath Classic | `30405` |
   | `Flatulence_Vanilla.toc` | Classic Era | `11508` |

   To support a **new patch**, just bump the `## Interface:` number in the
   matching `.toc`. To find the current number in-game, run:

   ```
   /run print((select(4, GetBuildInfo())))
   ```

   The Interface number is the client build: e.g. `110100` = patch `11.1.0`.
   For a brand-new flavor, copy any existing `.toc`, rename it with the correct
   suffix (`_Mainline`, `_Vanilla`, `_Cata`, `_Wrath`, `_Mists`, `_TBC`, etc.),
   and set its Interface number.

2. **The compatibility shims** at the top of `Core.lua` (`PlayFile`, `After`,
   `SendComm`, `RegisterCommPrefix`). Everything the addon does goes through
   APIs available on every current flavor (`hooksecurefunc`, `DoEmote`,
   `PlaySoundFile`, `CreateFrame`, `SlashCmdList`, and `C_ChatInfo` addon
   messaging with a legacy global fallback). If a future version changes one of
   those, update the shim in one spot rather than hunting through the code.

## Notes

- The addon **hooks** `DoEmote` with `hooksecurefunc` instead of overriding
  `/fart`. This is non-tainting and leaves Blizzard's real emote (text + any
  built-in vocal sound) fully intact.
- Reactions use standard addon messaging (`C_ChatInfo.SendAddonMessage`), the
  same mechanism countless mainstream addons use. It sends a tiny hidden
  `"FART"` payload on your group channel — no chat spam, no whispers.
- No audio is bundled — add your own so you control content and licensing.
