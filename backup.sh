#!/bin/bash
# 
# Generic Backup Script
# Features:
#   - Creates timestamped backup of source file
#   - Skips backup if unchanged from most recent
#   - Keeps only the most recent N backups (default: 50)
#
# Usage:
#   ./backup.sh /path/to/source/file /path/to/destination/dir [max_backups]
#
#
# Example:
#   /scripts/backup.sh /myContainers/excalidraw-full/excalidraw.db /myBackups 50
#

set -euo pipefail

# --- Functions ---

timestamp() {
    date +"%Y_%m_%d_%H%M%S"
}

compute_md5() {
    md5sum "$1" | awk '{print $1}'
}

backup_file() {
    local SRC="$1"
    local DEST="$2"
    local MAX_BACKUPS="${3:-50}"

    if [[ ! -f "$SRC" ]]; then
        echo "Error: Source file does not exist: $SRC"
        exit 1
    fi

    mkdir -p "$DEST"

    local TS
    TS=$(timestamp)
    local BASENAME
    BASENAME=$(basename "$SRC")
    local DEST_FILE="$DEST/${BASENAME%.*}_${TS}.${BASENAME##*.}"

    # Check for most recent backup
    local LATEST_BACKUP
    LATEST_BACKUP=$(ls -1t "$DEST"/"${BASENAME%.*}"_*."${BASENAME##*.}" 2>/dev/null | head -n 1 || true)

    if [[ -f "$LATEST_BACKUP" ]]; then
        local SRC_HASH
        local LATEST_HASH
        SRC_HASH=$(compute_md5 "$SRC")
        LATEST_HASH=$(compute_md5 "$LATEST_BACKUP")
        if [[ "$SRC_HASH" == "$LATEST_HASH" ]]; then
            echo "[$BASENAME] No changes detected, skipping backup."
            return 0
        fi
    fi

    # Copy file
    cp "$SRC" "$DEST_FILE"
    echo "[$BASENAME] Backup created: $DEST_FILE"

    # Enforce max backups
    local BACKUP_COUNT
    BACKUP_COUNT=$(ls -1t "$DEST"/"${BASENAME%.*}"_*."${BASENAME##*.}" 2>/dev/null | wc -l)
    if (( BACKUP_COUNT > MAX_BACKUPS )); then
        ls -1t "$DEST"/"${BASENAME%.*}"_*."${BASENAME##*.}" | tail -n +$((MAX_BACKUPS+1)) | xargs rm -f
        echo "[$BASENAME] Old backups cleaned up. Kept the most recent $MAX_BACKUPS."
    fi
}

# --- Main ---

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 /path/to/source/file /path/to/destination/dir [max_backups]"
    exit 1
fi

backup_file "$1" "$2" "${3:-50}"
