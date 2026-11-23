"""Writes the manifest of a folder of Piper voices: the name, size and SHA-256 checksum of every file.
Mantella reads the manifest to know which voices exist and to check its downloads.

Usage: python tools/make_manifest.py <folder with .onnx and .onnx.json files> <manifest.json to write>
"""
import hashlib
import json
import sys
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    folder, manifest_path = Path(sys.argv[1]), Path(sys.argv[2])
    files = sorted(f for f in folder.iterdir() if f.is_file() and (f.name.endswith('.onnx') or f.name.endswith('.onnx.json')))
    if not files:
        sys.exit(f'No voice files found in {folder}')
    manifest = {
        'format': 1,
        'files': {f.name: {'size': f.stat().st_size, 'sha256': sha256(f)} for f in files},
    }
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    voices = sum(1 for f in files if f.name.endswith('.onnx'))
    print(f'{manifest_path}: {voices} voices, {len(files)} files, {sum(f.stat().st_size for f in files) / 1e9:.2f} GB')


if __name__ == '__main__':
    main()
