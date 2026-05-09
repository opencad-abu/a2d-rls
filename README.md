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

| 角色 | 所属组 | 源数据 读 | 发布目标 读 | 发布目标 写 |
|------|--------|:---:|:---:|:---:|
| 模拟部门 | a2drls | ✅ | ✅ | ✅ |
| 数字部门 | — | ❌ | ✅ | ❌ |
| 其他系统用户 | — | ❌ | ✅ | ❌ |

---

## 快速开始

### 1. 管理员：环境变量设置

将以下内容加入所有模拟部门用户的 Shell 配置文件：

```bash
# Bash / Zsh (~/.bashrc)
export PROJ_A2D_ROOT=/data/proj/public/release
```

```csh
# C Shell / tcsh (~/.cshrc)
setenv PROJ_A2D_ROOT /data/proj/public/release
```

```fish
# Fish (~/.config/fish/config.fish)
set -gx PROJ_A2D_ROOT /data/proj/public/release
```

### 2. 管理员：服务器初始化（root 执行一次）

```bash
# 创建共享组和服务账号
groupadd a2drls
useradd -r -s /sbin/nologin -G a2drls a2d

# 添加模拟部门成员
usermod -aG a2drls analog1
usermod -aG a2drls analog2
usermod -aG a2drls analog3

# 创建发布目标目录（SGID）
mkdir -p ${PROJ_A2D_ROOT}
chown a2d:a2drls ${PROJ_A2D_ROOT}
chmod 2775 ${PROJ_A2D_ROOT}

# 部署脚本
install -m 755 a2d-release.sh  /usr/local/bin/a2drls
install -m 755 a2d-release.csh /usr/local/bin/a2drls.csh
install -m 755 a2d-release.fish /usr/local/bin/a2drls.fish
```

### 3. 模拟部门发布

```bash
# 在发布目录下执行
cd ~/V0.1-20250508-2
a2drls V0.1-20250508-2

# C Shell / tcsh
a2drls.csh V0.1-20250508-2

# Fish
a2drls.fish V0.1-20250508-2
```

> 💡 源目录是**相对路径**，在当前工作目录下查找同名目录。

### 4. 数字部门取用

```bash
cp -r $PROJ_A2D_ROOT/V0.1-20250508-2 /path/to/workspace/
```

---

## 环境变量

| 变量 | 必需 | 说明 | 示例 |
|------|:---:|------|------|
| `PROJ_A2D_ROOT` | ✅ | 发布目标根路径 | `/data/proj/public/release` |

---

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
| 组修正 | `chgrp -R a2drls` | rsync 会保留源组，显式覆盖 |
| 源路径 | 相对路径 | 发布目录即源目录，无需硬编码 |

## 作者

阿布 & OCAD

## License

MIT
