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

- `themes/base.user.css`：所有主题共享的本地覆盖规则。这里只放通用、低风险的字体和兼容性修复。
- `themes/extra-themes`：额外收集的主题。
- `themes/old-themes`：历史主题备份，默认不建议继续修改。
- `themes/backup_20260302`：一次性备份目录，仅用于回溯，不建议作为当前主题来源。

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
