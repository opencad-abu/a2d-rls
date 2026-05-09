#!/bin/bash
# ============================================================
# a2drls — 模拟部门数据发布脚本 (Bash)
# 作者: 阿布 & OCAD
#
# 用法: a2drls release_dir
# 示例: a2drls v1.0-20260508
#
# 环境变量:
#   PROJ_A2D_ROOT — 发布目标根路径 (如 /data/proj/public/release)
#
# 权限模型:
#   - 执行者无需 sudo，以自己身份运行
#   - 目标文件权限: D775 / F644 (组可写、全员可读)
# ============================================================
set -euo pipefail

RELEASE="${1:-}"
SRC="${RELEASE}"

# --- 检查 PROJ_A2D_ROOT ---
if [[ -z "${PROJ_A2D_ROOT:-}" ]]; then
    echo "ERROR: PROJ_A2D_ROOT is not set"
    echo "       export PROJ_A2D_ROOT=/data/proj/public/release"
    exit 2
fi

DEST="${PROJ_A2D_ROOT}/${RELEASE}"

if [[ -z "$RELEASE" ]]; then
    echo "Usage   : $0 <版本号>"
    echo "Example : $0 v1.0-20260508"
    exit 1
fi

if [[ ! -d "$SRC" ]]; then
    echo "ERROR: Unable to access: $SRC"
    exit 3
fi

umask 022

mkdir -p -m 775 "$DEST"
echo "==============================================================================="
echo "  Release  : $RELEASE"
echo "  Operator : $(whoami)"
echo "  Source   : $SRC"
echo "  Target   : $DEST"
echo "==============================================================================="

rsync -av \
    --chmod=D775,F644 \
    --delete \
    "$SRC/" \
    "$DEST/"

chgrp -R a2drls "$DEST"

echo ""
echo "✅ Finished release: $RELEASE → $DEST"
echo ""
echo "Target file list:"
find "$DEST" -type f | sort | while read f; do
    stat -c '%a %U:%G  %n' "$f"
done
