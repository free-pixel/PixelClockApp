#!/bin/bash

# 同步 AGENTS.md 到 internal_docs 子目录
# 用法: ./scripts/sync-agents.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SOURCE="$PROJECT_DIR/AGENTS.md"
DEST="$PROJECT_DIR/internal_docs/pixelclock/AGENTS.md"

if [ ! -f "$SOURCE" ]; then
    echo "错误: 找不到 $SOURCE"
    exit 1
fi

cp "$SOURCE" "$DEST"
echo "已同步 AGENTS.md -> internal_docs/pixelclock/AGENTS.md"
