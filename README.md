# Typora 配置迁移说明

## 目录说明

本目录为 Typora 的配置文件夹，包含主题、插件等配置，通过 Git 同步到 GitHub。

原始路径：`~/Library/Application Support/abnerworks.Typora`

### 字体依赖

当前自定义样式依赖以下本地字体文件：

- `~/Library/Fonts/LXGWWenKai-Regular.ttf`
- `~/Library/Fonts/LXGWWenKai-Medium.ttf`
- `~/Library/Fonts/LXGWWenKaiMono-Regular.ttf`

如果这些字体不存在，Typora 会回退到系统字体；部分主题的字重、代码字体和排版效果会发生变化。

### 目录约定

| 路径 | 说明 |
|------|------|
| `themes/*.css` | **当前启用**的主题（Typora 主题菜单里可见） |
| `themes/base.user.css` | 所有主题共享的本地覆盖（字体等） |
| `themes/extra-themes/` | 可选主题，复制到 `themes/` 根目录后即可启用 |
| `themes/old-themes/` | 过时/内置旧主题归档（Gothic、Newsprint、Pixyll、Whitey 等） |
| `themes/archive-themes/` | 冷门主题归档，默认不使用 |
| `themes/backup_20260302/` | 一次性全量备份，仅回溯用 |

---

## 当前主题清单（精简后）

重启 Typora 后，在 **主题** 菜单中选择即可。

### 日常写作（推荐）

| 主题 | 风格 | 说明 |
|------|------|------|
| `github` | 浅色 | GitHub 官方风格，预览 README 最准 |
| `github-dark-default` | 深色 | 现代 GitHub Dark |
| `github-dark-dimmed` | 深色 | GitHub Dark Dimmed，对比更柔和 |
| `notion-light` / `notion-dark` / `notion-darker` | 浅/深 | Notion 风格，简洁舒适 |
| `konayuki-light` / `konayuki-dark` | 浅/深 | 现代圆角排版，中文友好 |
| `vue` / `vue-dark` | 浅/深 | Vue 文档风，阅读感好 |

### 流行配色

| 主题 | 风格 | 说明 |
|------|------|------|
| `catppuccin-latte` | 浅色 | Catppuccin 浅色，当代最流行配色之一 |
| `catppuccin-frappe` | 深色 | Catppuccin Frappé |
| `catppuccin-macchiato` | 深色 | Catppuccin Macchiato |
| `catppuccin-mocha` | 深色 | Catppuccin Mocha（最常用深色） |
| `nord` | 深色 | Nord 冷色调，护眼 |
| `dracula` | 深色 | 经典 Dracula |
| `solarized-light` / `solarized-dark` | 浅/深 | 经典 Solarized |
| `ayu-mirage` | 深色 | Ayu Mirage |
| `cobalt` | 深色 | Cobalt 编辑器风 |
| `jetbrains-dark` | 深色 | JetBrains IDE 风格 |

### 中文社区 / 学术

| 主题 | 风格 | 说明 |
|------|------|------|
| `drake` / `drake-light` / `drake-dark` | 浅/深 | Drake 系列，中文社区常用 |
| `latex` / `latex-dark` | 浅/深 | LaTeX 论文风格，适合课程论文 |
| `night` | 深色 | Typora 经典内置深色 |

### 导出用

| 主题 | 说明 |
|------|------|
| `print` / `print-letter` | 打印/导出专用，一般不日常使用 |

### 可选（需手动启用）

`themes/extra-themes/` 中还有：

- `drake-ayu.css` — Drake × Ayu
- `drake-jb.css` — Drake × JetBrains

复制到 `themes/` 根目录后重启 Typora 即可出现在菜单中。

### 已移除（过时/不好用）

以下主题已移入 `old-themes/` 或 `archive-themes/`，不再出现在主题菜单：

- **Gothic / Newsprint / Pixyll / Whitey** — 早期内置主题，设计过时
- **Bronya** 及大量冷门 Drake / Bear 配色变体 — 冗余或小众

如需恢复，从对应归档目录拷回 `themes/` 根目录即可。

---

## 迁移到新 Mac 的步骤

1. **安装 Typora**（确保至少启动过一次，以生成默认配置目录）

2. **克隆本仓库** 到 `~/Configs/Typora`：
   ```bash
   mkdir -p ~/Configs
   git clone <仓库地址> ~/Configs/Typora
   ```

3. **安装所需字体** 到 `~/Library/Fonts/`：
   - `LXGWWenKai-Regular.ttf`
   - `LXGWWenKai-Medium.ttf`
   - `LXGWWenKaiMono-Regular.ttf`

4. **删除 Typora 自动生成的默认配置目录**：
   ```bash
   rm -rf ~/Library/Application\ Support/abnerworks.Typora
   ```

5. **创建软链接**，将配置目录指向本仓库：
   ```bash
   ln -s ~/Configs/Typora ~/Library/Application\ Support/abnerworks.Typora
   ```

6. 重启 Typora，配置、主题即可生效。
