# ESXiRansomware Demo

A safe, educational demonstration script that simulates ransomware behavior on VMware ESXi and other Linux environments.  

The script generates random, human-readable test files, encrypts them with AES-256-CBC, deletes the originals, and (in real runs) drops a ransom note. By default, it runs in **dry-run mode** to preview actions without making changes.

---

## Quick Run

Clone the repo and run the script:

```sh
# Preview only (default)
sh script.sh

# Actually create, encrypt, and drop ransom note
sh script.sh --run
````

---

## Features

* **Dry-run mode (default):** Safely previews file creation, encryption, and cleanup.
* **Real run mode (`--run`):** Generates test files, encrypts them, deletes originals, and writes a ransom note.
* **Photon-safe:** Uses only POSIX-compatible commands (`dd`, `base64`, `openssl`, `mkdir`, `rm`, `mv`).
* **Hardcoded password:** `RANSOMWARE` (for demo realism).
* **Automatic ransom note:** A `README_FOR_DECRYPT.txt` file is created only when running with `--run`.

---

## Script Variables

Adjustable at the top of `script.sh`:

* `DIR="test"` — output directory
* `COUNT=10` — number of test files
* `SIZE_KB=100` — approximate size of each file before base64 expansion
* `PASS="RANSOMWARE"` — encryption password
* `NOTE_NAME="README_FOR_DECRYPT.txt"` — ransom note filename

---

## Example Dry-Run Output

```
[dry-run] Would create 'test/file_1.test' with ~100 KiB base64 random data
[dry-run] Would encrypt 'test/file_1.test' → 'test/file_1.test.☢'
[dry-run] Would delete original 'test/file_1.test'
[dry-run] Would write ransom note to 'test/README_FOR_DECRYPT.txt'
[dry-run] Summary: would create 10 files, encrypt them, delete originals, and write ransom note.
```

---

## Disclaimer

This project is for **educational and demonstration purposes only**.
It is not malicious ransomware. It does not exfiltrate data or attempt persistence.
Use only in controlled environments where you have permission.
