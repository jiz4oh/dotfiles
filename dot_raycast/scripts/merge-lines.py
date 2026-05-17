#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Merge Lines
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📄
# @raycast.packageName Writing Tools

import sys
import subprocess
import re

def get_clipboard():
    p = subprocess.run(['pbpaste'], capture_output=True, text=True)
    return p.stdout

def set_clipboard(text):
    p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE, encoding='utf8')
    p.communicate(input=text)

def main():
    text = get_clipboard()
    if not text:
        print("❌ 剪贴板为空")
        sys.exit(1)

    # 核心逻辑：
    # 1. 把所有换行符替换为空格
    # 2. 把连续的多个空格替换为单个空格 (如果是英文)
    # 3. 如果是中文，换行后通常不需要补空格，直接拼接
    
    # 简单粗暴策略：
    # 将换行符替换为空格
    merged = text.replace('\n', ' ').replace('\r', '')
    
    # 将连续空格压缩为1个
    merged = re.sub(r'\s+', ' ', merged)
    
    # (进阶) 中文优化：如果前后都是中文，去掉它们中间的空格
    # 这里的正则简单处理：中文字符区间
    merged = re.sub(r'([\u4e00-\u9fa5])\s+([\u4e00-\u9fa5])', r'\1\2', merged)
    
    result = merged.strip()
    
    set_clipboard(result)
    print("✅ 文本已合并并清洗")

if __name__ == "__main__":
    main()
