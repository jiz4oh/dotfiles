#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Fix and Format JSON
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪄
# @raycast.packageName Dev Tools

import sys
import json
import subprocess

def get_clipboard():
    p = subprocess.run(['pbpaste'], capture_output=True, text=True)
    return p.stdout

def set_clipboard(text):
    p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE, encoding='utf8')
    p.communicate(input=text)

def repair_json_via_jxa(dirty_json):
    """
    利用 macOS 内置的 JavaScript 引擎 (JXA) 来修复 JSON。
    JS 的 eval() 可以解析单引号、无引号 Key、末尾逗号等非标准 JSON。
    """
    # JXA 脚本：读取剪贴板 -> eval解析 -> JSON.stringify标准化
    jxa_script = """
    const app = Application.currentApplication();
    app.includeStandardAdditions = true;
    
    // 直接从剪贴板读取，避免命令行参数转义问题
    const dirty = app.theClipboard();
    
    try {
        // 关键点：使用 eval 宽松解析 JS 对象字符串
        // 在外层包一个 () 是为了避免被解析为代码块
        const obj = eval('(' + dirty + ')');
        
        // 重新序列化为严格的标准 JSON
        JSON.stringify(obj, null, 2);
    } catch (e) {
        "JXA_ERROR: " + e.message;
    }
    """
    
    result = subprocess.run(
        ['osascript', '-l', 'JavaScript', '-e', jxa_script], 
        capture_output=True, 
        text=True
    )
    
    output = result.stdout.strip()
    if output.startswith("JXA_ERROR") or not output:
        return None, output
    return output, None

def main():
    raw_text = get_clipboard().strip()
    if not raw_text:
        print("❌ 剪贴板为空")
        sys.exit(1)

    # === 尝试 1: Python 原生解析 (最快) ===
    try:
        data = json.loads(raw_text)
        formatted = json.dumps(data, indent=2, ensure_ascii=False, sort_keys=True)
        set_clipboard(formatted)
        print("✅ JSON 已格式化 (Standard)")
        sys.exit(0)
    except json.JSONDecodeError:
        pass # 继续尝试修复

    # === 尝试 2: 调用 macOS JavaScript 引擎修复 (最强) ===
    # 能处理: { 'a': 1 } (单引号), { a: 1 } (无引号Key), { a: 1, } (末尾逗号)
    fixed_json, error = repair_json_via_jxa(raw_text)
    
    if fixed_json:
        set_clipboard(fixed_json)
        print("🪄 JSON 已修复并格式化 (Smart)")
    else:
        # 如果连 JS 都救不回来，那可能是真的格式烂了
        # 截取一部分错误信息显示
        err_msg = error.replace('JXA_ERROR: ', '') if error else "无法解析"
        print(f"❌ 格式错误: {err_msg[:30]}...")
        sys.exit(1)

if __name__ == "__main__":
    main()
