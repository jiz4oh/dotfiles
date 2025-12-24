#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Excel to Markdown Table
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📅
# @raycast.packageName Writing Tools

import sys
import subprocess

def get_clipboard():
    p = subprocess.run(['pbpaste'], capture_output=True, text=True)
    return p.stdout

def set_clipboard(text):
    p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE, encoding='utf8')
    p.communicate(input=text)

def main():
    raw = get_clipboard().strip()
    if not raw:
        print("❌ 剪贴板为空")
        sys.exit(1)

    lines = raw.split('\n')
    output = []
    
    # Excel 复制出来的数据通常是 Tab (\t) 分隔
    # 如果 Tab 不存在，尝试用逗号 (CSV)
    delimiter = '\t' if '\t' in lines[0] else ','

    for index, line in enumerate(lines):
        # 移除空白并分割
        cells = [c.strip() for c in line.split(delimiter)]
        # 拼接行
        row_str = "| " + " | ".join(cells) + " |"
        output.append(row_str)
        
        # 如果是第一行，自动加表头分割线 |---|---|
        if index == 0:
            separator = "| " + " | ".join(["---"] * len(cells)) + " |"
            output.append(separator)

    result = "\n".join(output)
    set_clipboard(result)
    print("✅ 表格已转换 Markdown")

if __name__ == "__main__":
    main()
