#!/usr/bin/env bash
# Uploads a folder of Piper voices to a release of this repo, where Mantella downloads them from.
# The voices are release files rather than files in the repo, so that cloning the repo stays small.
#
# Usage: tools/upload_voices.sh <folder with .onnx and .onnx.json files> [game] [release tag]
#   game         name of the folder in this repo that holds the manifest (default: skyrim)
#   release tag  default: <game>-v1. Use a new tag (eg skyrim-v2) when voices change, so that existing
#                installations keep working, and point Mantella's "Piper Voices URL" setting at it.
#
# Requires the GitHub CLI (gh), logged in with access to this repo. The repo needs at least one commit.
# Files that are already in the release are skipped, so an interrupted upload can simply be run again.
set -euo pipefail

folder="${1:?Usage: tools/upload_voices.sh <folder with voice files> [game] [release tag]}"
game="${2:-skyrim}"
tag="${3:-$game-v1}"
cd "$(git rev-parse --show-toplevel)"
repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"

python3 tools/make_manifest.py "$folder" "$game/manifest.json"

if ! gh release view "$tag" --repo "$repo" >/dev/null 2>&1; then
    gh release create "$tag" --repo "$repo" --title "Piper voices: $game ($tag)" --latest=false \
        --notes "Piper voice models for Mantella ($game). Mantella downloads these by itself: there is no need to download them by hand. See the README."
fi

existing="$(gh release view "$tag" --repo "$repo" --json assets --jq '.assets[].name')"
count=0
for file in "$folder"/*.onnx "$folder"/*.onnx.json; do
    name="$(basename "$file")"
    if grep -qxF "$name" <<< "$existing"; then
        continue
    fi
    echo "Uploading $name..."
    gh release upload "$tag" "$file" --repo "$repo"
    count=$((count + 1))
done

# The manifest goes last (and is always replaced): once it is there, everything it lists is there too
gh release upload "$tag" "$game/manifest.json" --repo "$repo" --clobber
echo "Done: uploaded $count new file(s) to https://github.com/$repo/releases/tag/$tag"
echo "Commit $game/manifest.json if it has changed."
