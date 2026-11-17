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
| `themes/*.css` | **当前启用**的主题（只有直接放在这一层的 `.css` 会出现在主题菜单） |
| `themes/base.user.css` | **所有主题共享的全局增强**（正文字体与 JetBrains Mono 解耦、代码行不被拆开、打印防截断） |
| `themes/old-themes/` | 未启用的主题归档。把某个 `.css` 和它的同名资源目录移回 `themes/` 即可恢复 |

---

## 当前精选主题（6 个）

按「读程序项目的 Markdown」来选：代码块、表格、标题层级要清楚，长时间看不累。装饰性主题（粉雪、飞书风、衬线报刊、Drake 的十二变体）已归档。

重启 Typora 后在 **主题** 菜单里选择。当前默认仍是 **Vue**。

| 主题 | 明暗 | 什么时候用 |
|------|------|------------|
| `github` | 浅色 | 内置 GitHub 主题。README 在网页上长什么样，这里就长什么样 |
| `github-night` | 深色 | [kinoute/typora-github-night-theme](https://github.com/kinoute/typora-github-night-theme) master。同一套文档的 GitHub Dark |
| `vue` | 浅色 | [blinkfox/typora-vue-theme](https://github.com/blinkfox/typora-vue-theme)。Vue 文档的标题和代码层次，日常阅读用这个 |
| `vue-dark` | 深色 | Vue 的深色配对 |
| `catppuccin-latte` | 浅色 | [Catppuccin](https://github.com/stephanlamoureux/typora-catppuccin)。低对比粉彩，适合连续看很长的文档 |
| `catppuccin-mocha` | 深色 | Catppuccin 的深色配对 |

Catppuccin 的 Frappé / Macchiato 没有放进菜单。色板文件还在 `themes/catppuccin/` 里，只是没有对应的顶层 `.css`。

### 已归档（`themes/old-themes/`）

Drake、Dracula、Nord、粉雪、Lark，以及 Typora 自带的 Gothic、Newsprint、Pixyll、Whitey、Night。Night 由 GitHub Night 替代。

Typora 升级会把 Gothic、Newsprint、Night、Pixyll、Whitey 再写回 `themes/`。升级后运行：

```bash
./sync.sh prune
```

这会把它们重新归档，并保留内置的 `github`。

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
| `./sync.sh prune` | 把升级写回的 Gothic / Newsprint / Night / Pixyll / Whitey 重新归档 |
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

