# An Alphabet by Laura Paresky Gould

A small static site that spells any name in photographs from Laura Paresky Gould's *Graphic Axioms* series — a 1990s alphabet shot on Fuji Velvia 35mm slide film.

**Live**: [lpg-alphabet.vercel.app](https://lpg-alphabet.vercel.app)

Inspired by NASA / USGS Landsat's [*Your Name in Landsat*](https://science.nasa.gov/specials/your-name-in-landsat/).

---

## What's in the repo

```
.
├── index.html       The entire app — HTML + CSS + JS, no build step
├── manifest.json    Auto-generated lookup of letter → photo URLs
├── images/          Web-resized photographs (1200px wide, JPEG q80)
│   ├── A/  B/  C/  …  Z/
├── start.command    Double-click on macOS to launch a local server
├── serve.py         Alternate Python server
├── .gitignore
└── README.md        ← you are here
```

There is **no framework**, **no backend**, **no build step**. Static files served by Vercel's CDN.

---

## How it works

1. `index.html` loads on page open.
2. JS fetches `manifest.json`, which maps each letter (`a`–`z`) to an array of photo URLs (`images/A/…`).
3. The default state spells the word `alphabet` using one randomly-chosen photo per letter.
4. When the user types a name and hits **Enter**, the existing letters fade out left-to-right, then the new ones snap in left-to-right at a tile height auto-fitted so the whole row stays on a single line.
5. **Click any tile** to swap that letter's variant. **See gallery** to view all photographs at once with a sticky letter nav. **Download** to save the current row as a single PNG.

---

## Two photo libraries

The repo's history reflects two distinct curations:

### v1 — Original 200-photo library

Pulled directly from Laura's broader archive. Mixed crops, mixed orientations, mixed durations, including some duplicates. Useful for variety; visually less consistent.

- **Last commit on v1**: `1650a41`
- **Live count**: 200 photos across A–Z

### v2 — Curated 119-photo library (current)

Hand-edited by Laura: tighter selection, deduplicated, recropped, all vertical orientation, more visual consistency. The library used on the live site today.

- **Swap commit**: `9607685` (v1 → v2 transition)
- **Latest sync**: `292f879`
- **Live count**: 119 photos across A–Z

### Switching between libraries

Nothing is ever permanently overwritten — every past state is recoverable from git history.

**To browse v1 read-only:**
```bash
git checkout 1650a41   # working tree shows the 200-photo state
# … look around, copy files out, etc.
git checkout main      # back to current
```

**To revert the live site to v1:**
```bash
git revert 9607685..292f879   # creates new commits that undo the swap
git push                       # auto-deploys
```

**To restore v2 after that:**
```bash
git revert <hash-of-the-revert-commit>
git push
```

GitHub's commit history at [github.com/lindsaygould/lpg-alphabet/commits/main](https://github.com/lindsaygould/lpg-alphabet/commits/main) lets you browse and download the state at any past commit.

---

## Running locally

### Quickest (macOS)
Double-click `start.command`. A Terminal window opens, the server starts on port 8765, and your default browser opens to `http://localhost:8765`.

### Manual
```bash
cd path/to/lpg-alphabet
python3 -m http.server 8765
# open http://localhost:8765
```

Or any other static file server. Don't open `index.html` directly via `file://` — `manifest.json` won't load over CORS.

---

## Deploying

The repo is connected to Vercel via GitHub integration. **Pushing to `main` auto-deploys** to production.

```bash
git add -A
git commit -m "your message"
git push
# wait ~30s, refresh https://lpg-alphabet.vercel.app
```

If the GitHub-Vercel integration ever breaks, deploy directly:
```bash
npx vercel --prod
```

First time on a new device, you'll need:
```bash
npx vercel login    # one-time browser auth
npx vercel link     # link this folder to the 'lpg-alphabet' Vercel project
```

---

## Updating the photo library

When you have a new source folder of letter-organized photographs that should replace what's live:

```bash
cd path/to/lpg-alphabet
SRC="/absolute/path/to/source/folder"   # must contain A/, B/, ... subfolders

# 1. Wipe current library and resize the new one in
rm -rf images && mkdir images
for letter_dir in "$SRC"/*/; do
  letter=$(basename "$letter_dir")
  mkdir -p "images/$letter"
  find "$letter_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \) ! -name ".*" -print0 \
    | while IFS= read -r -d '' f; do
        sips -Z 1200 -s formatOptions 80 "$f" --out "images/$letter/$(basename "$f")" > /dev/null
      done
done

# 2. Regenerate manifest.json (URL-encodes filenames automatically)
node -e "
const fs=require('fs'),p=require('path');
const r='images',o={letters:{}};let t=0;
for (const s of fs.readdirSync(r).filter(d => !d.startsWith('.') && fs.statSync(p.join(r,d)).isDirectory()).sort()) {
  const f = fs.readdirSync(p.join(r,s)).filter(x => !x.startsWith('.') && /\.(jpe?g|png|webp|gif|tiff?|bmp|heic)\$/i.test(x)).sort();
  if (!f.length) continue;
  o.letters[s.toLowerCase()] = f.map(x => 'images/' + encodeURIComponent(s) + '/' + encodeURIComponent(x));
  t += f.length;
}
fs.writeFileSync('manifest.json', JSON.stringify(o, null, 2));
console.log('Wrote', Object.keys(o.letters).length, 'letters,', t, 'photos');
"

# 3. Commit and push (auto-deploys)
git add -A
git commit -m "Refresh photo library"
git push
```

`sips` ships with macOS. On Linux/Windows, use `magick` (ImageMagick) or any tool that produces 1200px-wide JPEGs at quality 80.

---

## Cloning to a new device

```bash
git clone https://github.com/lindsaygould/lpg-alphabet.git
cd lpg-alphabet

# Run it locally (macOS/Linux)
python3 -m http.server 8765
# open http://localhost:8765

# Deploy (one-time setup)
npx vercel login
npx vercel link    # link to existing project
npx vercel --prod  # or just `git push` if GitHub-Vercel integration is connected
```

Node.js is required if you want to run the manifest generation script. The site itself is pure HTML/CSS/JS — no Node needed at runtime.

---

## File and data conventions

- **Letter folders**: single uppercase letter (`A/` … `Z/`). The app maps lowercase typed input to these folders automatically.
- **Filenames**: anything goes (iPhone-style `IMG_9567.JPG`, Notion-style hashed names, anything). Special characters are URL-encoded by the manifest generator.
- **Recognized extensions**: `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`, `.tif`, `.tiff`, `.bmp`, `.heic`.
- **Image size on the web**: 1200px max dimension, JPEG quality 80 (~150–300 KB per photo). Originals are kept off-repo as the master archive.

---

## Tech stack

- Vanilla HTML / CSS / JS, single file
- [Inter](https://fonts.google.com/specimen/Inter) from Google Fonts
- macOS `sips` (built-in) for image resizing
- Node.js for manifest generation and the Vercel CLI
- GitHub for source control
- Vercel (free tier) for hosting

---

## Credits

- **Photographs** © Laura Paresky Gould. *Graphic Axioms* series, 1990s. All rights reserved.
- **Project** by Laura Paresky Gould and Lindsay Gould.
- **Inspiration**: NASA / USGS Landsat's *Your Name in Landsat*.
