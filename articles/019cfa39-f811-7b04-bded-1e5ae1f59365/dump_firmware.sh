#!/bin/bash
# Dump raw DMI/firmware data before decommissioning a PC
# Usage: sudo bash dump_firmware.sh
#
# Requires: root, Linux, dmidecode, lzip, coreutils (find, cat, dd, stat)
# Optional: flashrom (for SPI flash ROM dump; may need iomem=relaxed)
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "error: must run as root" >&2
    exit 1
fi

OUTDIR="$HOME/fw_dump_$(hostname)_$(date +%Y%m%d_%H%M%S)"
ERRLOG="$OUTDIR/_errors.log"
mkdir -p "$OUTDIR"

log() { echo "[*] $1"; }
err() { echo "$1" >> "$ERRLOG"; }

# Copy pseudo-fs tree using cat (avoids lseek failures)
copy_tree() {
    local src="$1" dst="$2" depth="${3:-4}" maxsz="${4:-10485760}"
    [ -e "$src" ] || { err "NOT_EXIST: $src"; return; }
    find "$src" -maxdepth "$depth" -type d 2>/dev/null | while IFS= read -r d; do
        mkdir -p "${dst}${d#$src}"
    done
    find "$src" -maxdepth "$depth" -type f 2>/dev/null | while IFS= read -r f; do
        local sz; sz=$(stat -c%s "$f" 2>/dev/null || echo 0)
        [ "$sz" -gt "$maxsz" ] 2>/dev/null && { err "TOO_LARGE(${sz}): $f"; continue; }
        cat -- "$f" > "${dst}${f#$src}" 2>/dev/null \
            || dd if="$f" of="${dst}${f#$src}" bs=4096 iflag=fullblock 2>/dev/null \
            || err "READ_FAIL: $f"
    done
}

# SMBIOS binary (readable later via: dmidecode --from-dump smbios.bin)
log "SMBIOS binary"
dmidecode --dump-bin "$OUTDIR/smbios.bin" >/dev/null 2>>"$ERRLOG" || true

# ACPI tables (readable later via: iasl -d <table>)
log "ACPI tables"
[ -d /sys/firmware/acpi/tables ] && copy_tree /sys/firmware/acpi/tables "$OUTDIR/acpi" 3

# EFI variables
log "EFI variables"
[ -d /sys/firmware/efi/efivars ] && copy_tree /sys/firmware/efi/efivars "$OUTDIR/efivars" 1 1048576

# SPI flash ROM
log "SPI flash"
if command -v flashrom &>/dev/null; then
    FLASHROM="flashrom -p internal:laptop=this_is_not_a_laptop"
    $FLASHROM -r "$OUTDIR/spiflash.bin" >>"$ERRLOG" 2>&1 \
        || $FLASHROM --ifd -i bios -r "$OUTDIR/spiflash_bios.bin" >>"$ERRLOG" 2>&1 \
        || err "flashrom: all read attempts failed"
else
    err "flashrom not installed"
fi

# Fix ownership and archive
ARCHIVE="$OUTDIR.tar.lz"
if [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER:$SUDO_USER" "$OUTDIR"
fi
tar --lzip -cf "$ARCHIVE" -C "$(dirname "$OUTDIR")" "$(basename "$OUTDIR")"
if [ -n "${SUDO_USER:-}" ]; then
    chown "$SUDO_USER:$SUDO_USER" "$ARCHIVE"
fi
rm -rf "$OUTDIR"

log "Done: $ARCHIVE"