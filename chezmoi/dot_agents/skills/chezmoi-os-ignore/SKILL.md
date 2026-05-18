---
name: chezmoi-os-ignore
description: 盘点 chezmoi 仓库中的系统特定文件并生成条件化 ignore 规则。用户提到“某脚本只在 macOS/Linux/Debian 生效”“status/diff 总提示无关文件变化”“需要按系统过滤受管项”时使用。输出分组清单、推荐规则，并在用户确认后更新 `.chezmoiignore.tmpl`。
---

# Chezmoi OS Ignore

## 目标

将“系统特定文件识别 + 条件 ignore 落地”做成稳定流程，减少 `chezmoi status/diff` 噪音，并保持规则可读、可验证、可回滚。

## 工作流

### 1) 盘点候选文件

优先只读扫描，输出候选集合：

```bash
cd ~/.local/share/chezmoi
rg --files chezmoi
rg -n "darwin|macos|linux|debian|apt|brew|launchctl|osascript|hammerspoon|raycast|snipaste" chezmoi -S
```

### 2) 生成分组结论

按以下分组输出：

- `macOS only`
- `Linux/Debian only`
- `跨平台（无需 ignore）`

每组给 1 行理由，避免泛化推测。

### 3) 提出最小改动

只改 [`chezmoi/.chezmoiignore.tmpl`](~/.local/share/chezmoi/chezmoi/.chezmoiignore.tmpl)，使用条件模板：

```tmpl
{{- if ne .chezmoi.os "darwin" }}
# macOS only entries...
{{- end }}

{{- if or (ne .chezmoi.os "linux") (ne (get .chezmoi.osRelease "id") "debian") }}
# Debian only entries...
{{- end }}
```

规则：

- 目录项优先 `dir` + `dir/**` 成对出现。
- 先加高噪音项，再加边缘项。
- 不改业务文件，只改 ignore 模板。

### 4) 执行与验证

修改后必须给验证命令：

```bash
cd ~/.local/share/chezmoi
chezmoi execute-template < chezmoi/.chezmoiignore.tmpl | sed -n '1,220p'
chezmoi status
chezmoi diff
```

如果用户需要只看某系统渲染结果，使用 override data 文件模拟。

## 输出格式

按以下顺序输出：

1. 结论（推荐方案）
2. 文件清单（分组）
3. 实际改动文件路径
4. 验证命令
5. 风险与回滚方法（如有）

## 边界与注意事项

- 不把“可能是系统特定”当成“必须 ignore”。
- 用户未确认前，不做大范围批量忽略。
- 保持 `.chezmoiignore.tmpl` 简洁，避免重复规则。
- 涉及删除或覆盖时先提示风险并请求确认。

## 快速示例

用户请求：`macos-askpass 只在 macOS 添加，判断还有哪些文件是特定系统`

执行要点：

1. 扫描 `chezmoi/` 中脚本与配置目录。
2. 输出 `macOS only` 和 `Debian only` 清单。
3. 在 `.chezmoiignore.tmpl` 写 `if ne .chezmoi.os "darwin"` 与 Debian 条件块。
4. 给出 `chezmoi status` 与 `chezmoi diff` 验证结果。
