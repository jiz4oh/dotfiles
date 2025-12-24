#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title China Tax Calculator
# @raycast.mode fullOutput
# @raycast.argument1 { "type": "text", "placeholder": "金额 (例如 10000)" }

# Optional parameters:
# @raycast.icon 💴
# @raycast.packageName Sales Tools

import sys
import subprocess

def copy_to_clipboard(text):
    subprocess.run("pbcopy", input=text, text=True)

def main():
    try:
        amount_str = sys.argv[1]
        amount = float(amount_str)
    except ValueError:
        print("❌ 请输入有效数字")
        sys.exit(1)

    print(f"🎯 基准金额: {amount:.2f}\n")
    print("--- 增值税 (13%) ---")
    
    # 假设输入是含税，反推未税
    ex_tax_13 = amount / 1.13
    tax_13 = amount - ex_tax_13
    print(f"假如是含税价 -> 未税: {ex_tax_13:.2f} | 税额: {tax_13:.2f}")
    
    # 假设输入是未税，计算含税
    inc_tax_13 = amount * 1.13
    print(f"假如是未税价 -> 含税: {inc_tax_13:.2f}")
    
    print("\n--- 服务业/软件 (6%) ---")
    ex_tax_6 = amount / 1.06
    print(f"假如是含税价 -> 未税: {ex_tax_6:.2f}")
    inc_tax_6 = amount * 1.06
    print(f"假如是未税价 -> 含税: {inc_tax_6:.2f}")

    # 这里不做自动复制，因为结果有多个，用户可以在 FullOutput 窗口里手动选并复制
    # 或者你可以修改脚本，默认复制最常用的那个

if __name__ == "__main__":
    main()
