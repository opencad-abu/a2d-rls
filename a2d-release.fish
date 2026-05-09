#!/usr/bin/env fish
# ============================================================
# a2drls — 模拟部门数据发布脚本 (Fish)
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

if test (count $argv) -lt 1
    echo "Usage   : $_ <版本号>"
    echo "Example : $_ v1.0-20260508"
    exit 1
end

set RELEASE $argv[1]
set SRC "$RELEASE"

if not set -q PROJ_A2D_ROOT
    echo "ERROR: PROJ_A2D_ROOT is not set"
    echo "       set -gx PROJ_A2D_ROOT /data/proj/public/release"
    exit 2
end

set DEST "$PROJ_A2D_ROOT/$RELEASE"

if not test -d "$SRC"
    echo "ERROR: Unable to access: $SRC"
    exit 3
end

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

for f in (find "$DEST" -type f | sort)
    stat -c '%a %U:%G  %n' "$f"
end
