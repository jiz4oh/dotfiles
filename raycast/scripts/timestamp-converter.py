#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Timestamp Converter
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🕰️
# @raycast.packageName Dev Tools

import sys
import time
import subprocess
from datetime import datetime

def get_clipboard():
    p = subprocess.run(['pbpaste'], capture_output=True, text=True)
    return p.stdout.strip()

def set_clipboard(text):
    p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE, encoding='utf8')
    p.communicate(input=text)

def main():
    content = get_clipboard()
    
    try:
        # 情况A: 剪贴板是纯数字 (假设是秒级时间戳)
        if content.isdigit() and len(content) >= 10:
            ts = float(content)
            # 处理毫秒级时间戳
            if len(content) > 10: 
                ts = ts / 1000.0
            
            dt_obj = datetime.fromtimestamp(ts)
            res = dt_obj.strftime('%Y-%m-%d %H:%M:%S')
            set_clipboard(res)
            print(f"✅ 已转日期: {res}")
            
        # 情况B: 剪贴板不是时间戳，或者为空 -> 生成当前时间戳
        else:
            now = int(time.time())
            set_clipboard(str(now))
            print(f"✅ 当前时间戳: {now}")
            
    except Exception as e:
        print(f"❌ 转换失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
