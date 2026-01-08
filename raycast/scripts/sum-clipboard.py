#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Sum Clipboard Smart
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 💰

import subprocess
import re

def get_clipboard():
    return subprocess.check_output(['pbpaste']).decode('utf-8')

def set_clipboard(text):
    process = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
    process.communicate(input=text.encode('utf-8'))

try:
    data = get_clipboard()
    total = 0.0
    
    # 遍历每一行
    for line in data.splitlines():
        # 核心修改：使用正则表达式 re.sub
        # r'[^\d.]' 的意思是：找到所有“不是数字(d)且不是小数点(.)”的字符
        # 然后把它们替换为空字符串 ""
        cleaned_line = re.sub(r'[^\d.]', '', line)
        
        # 只有当清洗后的行不为空时才计算
        if cleaned_line:
            total += float(cleaned_line)

    # 格式化结果 (比如加千分位: 2,435,480.00)
    result_str = "{:,.2f}".format(total)
    
    # 复制回剪贴板并打印结果
    set_clipboard(result_str)
    print(f"Total: {result_str}")

except Exception as e:
    print(f"Error: {e}")
