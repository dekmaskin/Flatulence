Flatulence — Sounds folder
==========================

Drop your fart sound files in THIS folder.

By default Core.lua expects these nine files:

    fart1.mp3
    fart2.mp3
    fart3.mp3
    fart4.mp3
    fart5.mp3
    fart6.mp3
    fart7.mp3
    fart8.mp3
    fart9.mp3

You can use any names and any number of files. Just make the file list in
Core.lua (the SOUND_FILES table near the top) match what you actually put here.

Format requirements
-------------------
- Use .ogg (Ogg Vorbis) or .mp3. Both work on every game version.
- Keep them short (under ~5 seconds) and reasonably small.
- Mono or stereo both work.

*** LICENSING — READ BEFORE YOU PUBLISH ***
-------------------------------------------
If you distribute this addon publicly (CurseForge, Wago, WoWInterface, etc.)
you are also distributing whatever audio is in this folder. You MUST have the
right to redistribute every file here.

  - Safest: record your own sounds, or use clips released into the public
    domain (CC0).
  - If you use Creative Commons clips that require attribution (CC-BY), you
    must credit the author. Add the credits to the addon's README/CHANGELOG.
  - Do NOT ship copyrighted sound effects, movie/TV clips, or anything from a
    commercial sound pack that forbids redistribution.

Good sources for redistributable audio: freesound.org (check each clip's
license), or your own microphone.

After adding or renaming files
------------------------------
1. Make sure every file is listed in SOUND_FILES in Core.lua.
2. Fully restart the game client (a /reload does NOT pick up newly added
   sound files on disk — the client indexes them at launch).
