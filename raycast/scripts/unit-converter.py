#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Unit Converter
# @raycast.mode fullOutput
# @raycast.argument1 { "type": "text", "placeholder": "例如: 10in, 5kg" }

# Optional parameters:
# @raycast.icon 📏
# @raycast.packageName Manufacturing Tools

import sys
import re

def main():
    if len(sys.argv) < 2:
        print("❌ 请输入数值和单位")
        sys.exit(1)

    arg = sys.argv[1].lower().strip()
    
    # 正则提取数字和单位 (支持小数)
    match = re.match(r"([0-9.]+)\s*([a-z\"']+)", arg)
    if not match:
        print("❌ 格式错误。")
        print("✅ 正确示例: 10 in, 5 kg, 25.4 mm")
        sys.exit(1)
        
    val = float(match.group(1))
    unit = match.group(2)
    
    # 简单的单位汉化映射（用于显示当前输入）
    unit_map = {
        'in': '英寸', '"': '英寸', 'inch': '英寸',
        'mm': '毫米', 'cm': '厘米', 'm': '米',
        'ft': '英尺', "'": '英尺',
        'kg': '千克', 'lb': '磅', 'lbs': '磅', 'oz': '盎司'
    }
    cn_unit = unit_map.get(unit, unit)

    print(f"🎯 输入: {val} {cn_unit} ({unit})\n")
    print("--- 转换结果 ---")

    # === 长度转换逻辑 ===
    if unit in ['mm', 'millimeter', '毫米']:
        print(f"英寸: {val / 25.4:.4f} in")
        print(f"厘米: {val / 10:.2f} cm")
        
    elif unit in ['cm', 'centimeter', '厘米']:
        print(f"英寸: {val / 2.54:.4f} in")
        print(f"毫米: {val * 10:.2f} mm")
        
    elif unit in ['m', 'meter', '米']:
        print(f"英尺: {val * 3.28084:.4f} ft")
        print(f"厘米: {val * 100:.2f} cm")
        
    elif unit in ['in', 'inch', '"', '英寸']:
        print(f"毫米: {val * 25.4:.4f} mm")
        print(f"厘米: {val * 2.54:.4f} cm")
        
    elif unit in ['ft', 'foot', "'", '英尺']:
        print(f"米:   {val / 3.28084:.4f} m")
        print(f"厘米: {val * 30.48:.2f} cm")
        
    # === 重量转换逻辑 ===
    elif unit in ['kg', 'kilogram', '千克', '公斤']:
        print(f"磅:   {val * 2.20462:.4f} lbs")
        print(f"斤:   {val * 2:.2f} 斤") # 既然是中文环境，增加一个“市斤”很实用
        
    elif unit in ['lb', 'lbs', 'pound', '磅']:
        print(f"千克: {val / 2.20462:.4f} kg")
        print(f"斤:   {val / 1.10231:.2f} 斤")
        
    elif unit in ['oz', 'ounce', '盎司']:
        print(f"克:   {val * 28.3495:.2f} g")
        
    else:
        print(f"❌ 未知或不支持的单位: {unit}")

if __name__ == "__main__":
    main()
