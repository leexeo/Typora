# Typora 配置迁移说明

## 目录说明

本目录为 Typora 的配置文件夹，包含主题、插件等配置，通过 Git 同步到 GitHub。

原始路径：`~/Library/Application Support/abnerworks.Typora`

### 字体与排版特性

全局样式 [base.user.css](file:///Users/lixiang/Configs/Typora/themes/base.user.css) 采用**正文比例字体**与**代码等宽字体**解耦设计：

- **代码与等宽区域**：强制使用 `JetBrains Mono`（支持常规、加粗与连字微调）
- **正文与标题区域**：优雅比例字体栈，优先 macOS 原生高清渲染（苹方 `PingFang SC` / `Hiragino Sans GB`），并兼顾霞鹜文楷 `LXGWWenKai` 与思源黑体 `Source Han Sans SC`
- **视觉增强**：代码块 Mac 视窗红黄绿三色圆点、图片居中与柔和阴影、`<mark>` 荧光高亮、`<kbd>` 拟物按键、表格斑马纹、PDF 分页防截断

本地字体依赖：
- `~/Library/Fonts/LXGWWenKai-Regular.ttf`
- `~/Library/Fonts/LXGWWenKai-Medium.ttf`
- `~/Library/Fonts/LXGWWenKaiMono-Regular.ttf`
- `~/Library/Fonts/JetBrainsMono-*.ttf`

### 目录约定

| 路径 | 说明 |
|------|------|
| `themes/*.css` | **当前启用**的主题（Typora 主题菜单里可见） |
| `themes/base.user.css` | **所有主题共享的全局增强覆盖**（字体解耦、Mac 视窗圆点、按键/图片美化、打印防截断） |
| `themes/extra-themes/` | 可选主题，复制到 `themes/` 根目录后即可启用 |
| `themes/old-themes/` | 过时/内置旧主题归档（Gothic、Newsprint、Pixyll、Whitey 等） |
| `themes/archive-themes/` | 冷门主题归档，默认不使用 |
| `themes/backup_20260302/` | 一次性全量备份，仅回溯用 |

---

## 当前精选主题清单（共 12 款）

重启 Typora 后，在 **主题** 菜单中选择即可。6 款浅色 + 6 款深色完美配比：

### 中文与日常写作

| 主题 | 风格 | 说明 |
|------|------|------|
| `vue` / `vue-dark` | 浅/深 | Vue 官方文档风格，清新绿调，技术笔记首选 |
| `drake` / `drake-light` / `drake-dark` | 浅/深 | Drake 系列，中文排版顶流，中英文/代码混排极佳 |
| `konayuki-light` / `konayuki-dark` | 浅/深 | 「粉雪」，日系现代圆角卡片风，精致美观 |
| `lark` | 浅色 | 飞书/云文档风格，清晰层次，中文办公沉淀首选 |

### 经典与流行配色

| 主题 | 风格 | 说明 |
|------|------|------|
| `catppuccin-latte` / `catppuccin-mocha` | 浅/深 | 当代开发者最流行的高级柔和粉彩调 |
| `nord` | 深色 | 经典北欧冷色调，温润护眼 |
| `dracula` | 深色 | 经典高对比度紫黑编程风 |

### 可选主题（需手动启用）

`themes/extra-themes/` 中提供可选变体：
- `drake-ayu.css` — Drake × Ayu
- `drake-jb.css` — Drake × JetBrains

复制到 `themes/` 根目录后重启 Typora 即可在主题菜单中启用。

### 已归档主题（`themes/archive-themes/`）

为避免主题菜单臃肿，以下效果一般、过时或冗余的主题已归档（如需恢复从 `archive-themes/` 拷回即可）：
- **Cobalt / Solarized / Ayu Mirage / JetBrains Dark** — 早期对比度过大或缺乏文档层次
- **Latex / Night / Print** — 排版僵硬或过时内置主题（全局已由 `base.user.css` 统一提供打印与导出优化）
- **Catppuccin Frappé / Macchiato** — 冗余中间色版，仅保留最经典的 Latte 与 Mocha
- **GitHub / Notion** — 已按需求移除

如需恢复，从对应归档目录拷回 `themes/` 根目录即可。

---

## 迁移到新 Mac

推荐使用仓库里的 `sync.sh`（安装字体、备份旧配置、创建软链接）：

```bash
# 1. 安装 Typora，并至少启动一次
# 2. 克隆本仓库
mkdir -p ~/Configs
git clone https://github.com/leexeo/Typora.git ~/Configs/Typora
cd ~/Configs/Typora

# 3. 一键同步
./sync.sh
```

重启 Typora，在 **主题** 菜单中选择即可。

| 命令 | 作用 |
|------|------|
| `./sync.sh` | 安装字体 + 创建软链接（默认） |
| `./sync.sh status` | 检查字体、软链接和已启用主题 |
| `./sync.sh fonts` | 仅安装字体 |
| `./sync.sh link` | 仅创建软链接 |
| `./sync.sh extra` | 启用 `themes/extra-themes/` 中的可选主题 |
| `./sync.sh --dry-run` | 只打印将要执行的操作 |
| `./sync.sh --yes` | 非交互，自动确认备份 / 覆盖 |

脚本会安装 README 列出的霞鹜文楷，以及 `themes/base.user.css` 实际使用的 JetBrains Mono 和思源黑体。已有 Typora 配置目录时会先备份为 `abnerworks.Typora.bak.<时间戳>`，不会直接删除。

### 手动步骤（与脚本等价）

1. **安装 Typora**（确保至少启动过一次，以生成默认配置目录）

2. **克隆本仓库** 到 `~/Configs/Typora`：
   ```bash
   mkdir -p ~/Configs
   git clone https://github.com/leexeo/Typora.git ~/Configs/Typora
   ```

3. **安装所需字体** 到 `~/Library/Fonts/`：
   - `LXGWWenKai-Regular.ttf`
   - `LXGWWenKai-Medium.ttf`
   - `LXGWWenKaiMono-Regular.ttf`
   - （推荐）JetBrains Mono、思源黑体 Source Han Sans

4. **备份并移除 Typora 自动生成的默认配置目录**：
   ```bash
   mv ~/Library/Application\ Support/abnerworks.Typora \
      ~/Library/Application\ Support/abnerworks.Typora.bak
   ```

5. **创建软链接**，将配置目录指向本仓库：
   ```bash
   ln -s ~/Configs/Typora ~/Library/Application\ Support/abnerworks.Typora
   ```

6. 重启 Typora，配置、主题即可生效。

---

## 最佳使用建议与进阶配置

### 1. 终端命令行集成

在 `~/.zshrc` 中添加 alias，可在终端直接使用 `typora` 打开文件：

```bash
alias typora="open -a Typora"
```

### 2. 高级导出引擎 (Pandoc)

Typora 的 Word (`.docx`)、LaTeX、ePub 导出依赖 Pandoc：

```bash
brew install pandoc
```

### 3. 推荐偏好设置 (Preferences)

- **Markdown 扩展语法**：偏好设置 → `Markdown` → 开启 **内联公式** (`$E=mc^2$`)、**高亮** (`==文本==`)、**上标/下标** 与 **图表** (Mermaid)。
- **图片防丢失机制**：偏好设置 → `图像` → 插入图片时选择 **复制到指定路径: ./assets**，并勾选 **优先使用相对路径**。
- **外观模式联动**：偏好设置 → `通用` → 勾选 **根据系统自动切换深浅色**。

