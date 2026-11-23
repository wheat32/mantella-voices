# Mantella voices

Piper voice models for [Mantella](https://github.com/wheat32/Mantella), the mod that lets you talk to Skyrim NPCs.

You do not need to download anything from here by hand. Mantella fetches the voices by itself: a voice is downloaded the first time an NPC needs it, and the rest follow in the background.

## Where the voices are

The voice files are attached to the [releases](../../releases) of this repo, not stored in the repo itself. Each voice is about 63 MB and there are 68 of them (4 GB), which would make the repo slow to clone for no benefit.

| Release | Game | Contents |
|---|---|---|
| `skyrim-v1` | Skyrim Special Edition | 68 voices: one `.onnx` model and one `.onnx.json` settings file per voice, plus `manifest.json` |

`skyrim/manifest.json` lists every file of the release with its size and SHA-256 checksum. Mantella uses it to know which voices exist and to check what it has downloaded.

## Updating the voices

```bash
tools/upload_voices.sh /path/to/folder/with/voices
```

This writes `skyrim/manifest.json` and uploads the files that are not in the release yet. To change existing voices, upload to a new release (`tools/upload_voices.sh <folder> skyrim skyrim-v2`) and point the `Piper Voices URL` setting of Mantella at it, so that existing installations keep working.

## Where the voices come from

The voices are the Piper models distributed with [Mantella on Nexus Mods](https://www.nexusmods.com/skyrimspecialedition/mods/98631) (v0.14) by art-from-the-machine and its contributors. They were trained on the voices of the game's characters. They are mirrored here unchanged so that Mantella can download them automatically; they are not original work of this repo, and no licence is granted by it.
