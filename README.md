# Flatulence

A tiny World of Warcraft addon that plays a random fart sound when you use its
own `/prrt` emote. Built to be trivially portable across game versions — retail,
Mists of Pandaria Classic, Cataclysm, Wrath, and Classic Era.

## What it does

- Adds its own **`/prrt`** emote (aliases `/brap` and `/toot`) that plays a sound and posts a
  custom fart line of its own — no stock Blizzard emote text. Each sound has its
  own signature line, and that line doubles as a hidden signal so **anyone
  nearby with the addon plays the exact same sound, no group required.**
- **Leaves Blizzard's built-in `/fart` completely alone.** The addon does not
  hook, override, or react to `/fart` — that stays a plain vanilla emote.
- Picks a weighted-random file from your sound pool (so rare sounds stay rare) and avoids repeating the same one twice in a row.
- Plays on the **Master** channel so it's audible even if in-game SFX volume is low, with an automatic fall back to the SFX channel.
- **Reacts to other players who also run Flatulence.** When someone nearby (or
  in your group) uses `/prrt`, you hear the same sound they played *and* your
  character fires back one of 40+ custom emotes ranging from extreme disgust to
  utter delight. See [Reactions](#reactions) below.
- Ships with a small config command; the emote itself needs no configuration.

## How `/prrt` works

`/prrt` (aliases `/brap` and `/toot`) is the addon's own emote, fully
independent of Blizzard's. It plays a random sound and posts *that sound's* signature line
(e.g. "*YourName* unfurls a long, steady, workmanlike rumble.") as a normal
text emote. The `/prrt` action lines live in the `FART_ACTION_EMOTES` table at
the top of `Core.lua`.

Because it uses its emote line as a proximity signal, `/prrt` reaches everyone
in emote range, grouped or not — and it *also* notifies groupmates over the
addon channel to cover teammates who are out of emote range.

### How `/prrt` reaches nearby players

WoW has no addon-messaging channel for "everyone in shouting distance," so
`/prrt` piggybacks on something that *is* proximity-based: the emote itself.

1. `/prrt` picks a random sound, say fart #3.
2. It posts fart #3's dedicated line as a normal `/emote`. Everyone in emote
   range sees it — that's Blizzard's standard proximity emote, no group needed.
3. Other Flatulence users read that emote off the `CHAT_MSG_TEXT_EMOTE` event,
   match the text back to its index, and play **the same** fart #3 locally.
4. Players *without* the addon just see a funny emote line. No spam, no tokens.

Because the emote text is the signal, the lines are **index-aligned** with
`SOUND_FILES`: the line at position N is the signature for sound N, and each
line must be unique. If you add a sound, add a matching unique line at the same
position in `FART_ACTION_EMOTES`. Groupmates who are out of emote range still
hear it via the group addon channel; a player who is both grouped and in range
is de-duplicated so the sound plays only once.

## Reactions

When you `/prrt`, other Flatulence users pick a random reaction and perform it
back at you as a custom text emote — so a fart gets a chorus of gagging,
laughing, cheering, and glaring. Any Flatulence user within emote range reacts
(a stranger in a city included), and groupmates out of range react via the addon
channel.

The reactions are 40+ hand-written custom emotes ranging from **extreme
disgust** ("gags violently and looks for the nearest exit.") through amusement
and delight, all the way to a few that are **suspiciously into it** ("fans
themselves and whispers, 'do that again.'"). They're
posted as normal `/emote` text, so once triggered they're visible to *everyone*
around the reacting player, not just the group.

Details and limitations:

- **Both players need the addon** for a reaction to trigger. Players without
  Flatulence just see your normal emote line.
- **Listeners also hear the fart.** When someone nearby uses `/prrt`, your
  client plays the sound locally too — and it plays *the same* sound they did,
  not a random one. This works because the sound's index is carried in the
  signal (the `/prrt` emote line, or the group message), so it only matches
  correctly when both players share the same `SOUND_FILES` list — and the same
  `FART_ACTION_EMOTES` lines — in the same order (e.g. the same addon install).
  If they differ, the listener falls back to a random sound rather than
  erroring. Toggle this with `/flatulence hear off`.
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
- Cataclysm Classic: `World of Warcraft\_classic_\Interface\AddOns\`
- Wrath Classic: `World of Warcraft\_classic_\Interface\AddOns\`
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
3. Add a matching **unique** line to `FART_ACTION_EMOTES` at the *same position*
   as the sound in `SOUND_FILES`. This table is index-aligned with the sound
   list: line N is the `/prrt` signature for sound N, and it's how nearby addon
   users know which sound to play. Keep the two tables the same length and order.
   The bundled lines are written to *describe* each sound (a short one reads as a
   quick blip, a long wet one as a catastrophic shart, etc.) — rewrite them to
   fit your own audio.
4. *(Optional)* Adjust how often a sound plays via `SOUND_WEIGHTS`, also
   index-aligned. Weights are relative (a weight of 10 plays 10x as often as 1);
   anything not listed uses `DEFAULT_SOUND_WEIGHT`. The default config keeps
   `fart8` (a rare "catastrophic shart") at weight 1 against the others' 10, so
   it lands roughly 1 in 81 farts. Set a weight to 0 to keep a file installed
   but never auto-played.
5. **Fully restart the client.** WoW indexes sound files on disk at launch, so a
   `/reload` will not pick up newly added audio.

> **Publishing?** The addon ships with **no audio** — you must add your own, and
> you must have the right to redistribute anything you bundle in a public
> release. See `Sounds/README.txt` for licensing guidance and format details.

## Commands

| Command | Effect |
| --- | --- |
| `/prrt` (aliases `/brap`, `/toot`) | The addon's own emote — random sound + that sound's signature line; nearby addon users (grouped or not) play the same sound and react. |
| `/flatulence on` / `off` / `toggle` | Enable or disable your own sounds. |
| `/flatulence test` | Play a random sound now. |
| `/flatulence react on` / `off` | Enable or disable reacting to others' farts. |
| `/flatulence react <0-100>` | Set the % chance you react (e.g. `react 50`). |
| `/flatulence hear on` / `off` | Hear (or mute) the sound when others fart. |
| `/flat` | Short alias for `/flatulence`. |

Blizzard's built-in `/fart` is untouched by the addon — it stays a plain emote
with no sound and no broadcast.

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
   APIs available on every current flavor (`DoEmote`, `PlaySoundFile`,
   `CreateFrame`, `SlashCmdList`, `SendChatMessage`, and `C_ChatInfo` addon
   messaging with a legacy global fallback). If a future version changes one of
   those, update the shim in one spot rather than hunting through the code.

## Notes

- The addon adds its own `/prrt` (and `/brap`, `/toot`) command and **does not touch
  Blizzard's `/fart`**. There is no `DoEmote` hook — `/fart` behaves exactly as
  it does without the addon.
- `/prrt` reactions are proximity-based: they ride the `CHAT_MSG_TEXT_EMOTE`
  event, matching the emote's text back to a sound index — no addon message and
  no group needed. To also cover groupmates who are out of emote range, `/prrt`
  additionally sends a tiny hidden `"FART:<index>"` payload over standard addon
  messaging (`C_ChatInfo.SendAddonMessage`) on your group channel — no chat
  spam, no whispers. A player who is both grouped and in range is de-duplicated
  so the sound plays only once.
- No audio is bundled — add your own so you control content and licensing.
