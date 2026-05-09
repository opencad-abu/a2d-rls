#!/usr/bin/env fish
# ============================================================
# a2d-release.fish — 模拟部门数据发布脚本 (Fish)
# 作者: 阿布 & OCAD
#
# 用法: a2d-release.fish <版本号>
# 示例: a2d-release.fish v1.0-20260508
#
# 权限模型 (SGID + 共享组, 零提权):
#   - 组名: a2drls
#   - 目标目录: /public/release/ (2775 a2d:a2drls)
#   - 目标文件权限: D775 / F644 (组可写、全员可读)
#   - 执行者无需 sudo，以自己身份运行
# ============================================================

# --- 参数检查 ---
if test (count $argv) -lt 1
    echo "用法: $_ <版本号>"
    echo "示例: $_ v1.0-20260508"
    exit 1
end

set VERSION $argv[1]
set SRC "/data/sim/$VERSION"
set DEST "/public/release/$VERSION"

if not test -d "$SRC"
    echo "错误: 源目录不存在: $SRC"
    exit 2
end

# --- 确保新建文件 world-readable ---
umask 022

# --- 创建目标版本目录 ---
mkdir -p -m 775 "$DEST"

# --- rsync 同步 ---
echo "=================================="
echo "  发布: $VERSION"
echo "  操作者: $(whoami)"
echo "  源:   $SRC"
echo "  目标: $DEST"
echo "=================================="

rsync -av \
    --chmod=D775,F644 \
    --delete \
    "$SRC/" \
    "$DEST/"

# --- 修正组归属（rsync 保留源组，需显式覆盖） ---
chgrp -R a2drls "$DEST"

echo ""
echo "✅ 发布完成: $VERSION → $DEST"
echo ""
echo "目标文件列表:"
find "$DEST" -type f | sort | while read -l f
    stat -c '%a %U:%G  %n' "$f"
end
