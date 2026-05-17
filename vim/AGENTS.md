# Agent 工作说明

## 作用范围
- 仅适用于 `vim/` 子树；父级 `chezmoi` 规则由上层 `AGENTS.md` 负责。
- 当前工作树已存在用户未提交改动；不要回退或覆盖不属于本次任务的变更。

## 包管理器
- Neovim 插件采用混合模式：插件声明主入口在 `config/plugin.vim`，Lazy 引导在 `config/plugin.lua`，适配层在 `lua/vim-plug.lua`。
- 基础启动链路是 `init.vim -> config.vim -> config/base.lua -> lua/config/*`。
- 旧版 Vimscript 配置仍然有效；新增或修复行为时，先确认应该落在 `config/`、`plugin/` 还是 `lua/plugins/`。

## 文件级命令
```bash
sh ./install
nvim --headless +Lazy\ restore +qall
vim +'PlugInstall --sync' +qall
nvim --headless "+lua print('ok')" +qall
```

## 关键约定
- 改插件清单、懒加载条件或安装流程时，优先检查 `config/plugin.vim`、`config/plugin.lua`、`lua/vim-plug.lua` 是否需要同步。
- 改 Neovim 内置行为、UI、LSP、按键映射时，优先落在 `lua/config/*`；插件专属配置放在 `lua/plugins/config/*`。
- 保持 Vim 和 Neovim 兼容判断：仓库大量使用 `has('nvim')`、版本判断和可执行文件探测，修改时不要移除这些守卫。
- `install` 会改写 `~/.config/nvim` 符号链接并执行插件恢复；除非用户明确要求，不要替用户运行它。
- `tasks.ini`、`config/plugin/vim-test.vim`、`config/plugin/vim-dispatch.vim` 约定了 `Dispatch` 与 `vim-test` 工作流；改任务或测试相关行为时先核对这三处。
- Markdown 预览当前走 `brianhuster/live-preview.nvim`，命令入口 `:MarkdownPreview` 实际映射到 `:LivePreview start`；不要误改回已禁用的 `iamcco/markdown-preview.nvim`。
- 涉及 SSH 下浏览器打开或远程预览时，优先检查 `lua/config/ui.lua` 和 `lua/plugins/config/live-preview.lua`。

## 维护规则
- 只在仓库事实变化时更新本文件；策略变化先问用户。
- 禁止添加 `Co-Authored-By`、`coauthor`、`提交署名`。
