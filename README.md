# a2d-rls — Analog-to-Digital Release

模拟部门（Analog）→ 数字部门（Digital）数据发布工具。

**核心理念**: SGID + 共享组，零提权（无需 sudo），权限最小化。

## 架构

```
  ┌──────────┐                              ┌──────────────────┐
  │  user1   │──┐                           │ /public/release/  │
  │  user2   │──┼── [a2drls 组] ── rsync ──→│  owner: a2d       │
  │  user3   │──┘     直接写入               │  group: a2drls    │
  └──────────┘                              │  mode: 2775 (SGID)│
                                            └────────┬─────────┘
  ┌──────────┐                              ┌────────▼─────────┐
  │ digital1 │───── 只读 ──────────────────→│  D775 / F644      │
  │ digital2 │      (非 a2drls 成员)         │  全员可读、组可写   │
  └──────────┘                              └──────────────────┘
```

## 权限矩阵

| 角色 | 所属组 | `/data/sim/` 读 | `/public/release/` 读 | `/public/release/` 写 |
|------|--------|:---:|:---:|:---:|
| 模拟部门 (user1/2/3) | a2drls | ✅ | ✅ | ✅ |
| 数字部门 | — | ❌ | ✅ | ❌ |
| 其他系统用户 | — | ❌ | ✅ | ❌ |

## 快速开始

### 1. 服务器初始化（root 执行一次）

```bash
# 创建共享组
groupadd a2drls

# 创建服务账号（不可登录）
useradd -r -s /sbin/nologin -G a2drls a2d

# 添加模拟部门成员
usermod -aG a2drls user1
usermod -aG a2drls user2
usermod -aG a2drls user3

# 创建目录
mkdir -p /data/sim /public/release
chown a2d:a2drls /data/sim /public/release
chmod 750 /data/sim
chmod 2775 /public/release

# 部署脚本
install -m 755 a2d-release.sh /usr/local/bin/a2d-release
```

### 2. 模拟部门发布

```bash
# Bash / Zsh
a2d-release v1.0-20260508

# C Shell / tcsh
a2d-release.csh v1.0-20260508

# Fish
a2d-release.fish v1.0-20260508
```

无需 `sudo`，无需切换用户。

### 3. 数字部门取用

```bash
cp -r /public/release/v1.0-20260508 /path/to/workspace/
```

## 文件说明

| 文件 | Shell | 说明 |
|------|-------|------|
| `a2d-release.sh` | Bash / Zsh | 主版本，推荐 |
| `a2d-release.csh` | C Shell / tcsh | 兼容传统 EDA 环境 |
| `a2d-release.fish` | Fish | 现代交互 Shell |

三个版本功能完全一致，按团队使用的 Shell 选择即可。

## 设计决策

| 决策 | 选择 | 原因 |
|------|------|------|
| 权限模型 | SGID + 共享组 | 零提权，无需 sudo |
| 目录权限 | D775 | 组内可写，多用户可交替发布 |
| 文件权限 | F644 | 全员可读，数字部门直接取用 |
| rsync 参数 | `--chmod=D775,F644` | 覆盖源文件权限，保证目标端一致 |
| 服务账号 | a2d (`/sbin/nologin`) | 统一文件归属，不可登录 |

## 作者

阿布 & OCAD

## License

MIT
