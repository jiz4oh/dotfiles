#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate File Tree
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌳
# @raycast.packageName Dev Tools

import os
import sys
import subprocess

# 忽略列表
IGNORE_DIRS = {'.git', '.idea', '__pycache__', 'node_modules', '.vscode', 'venv', 'env'}
IGNORE_FILES = {'.DS_Store', '.gitignore'}

def get_clipboard():
    p = subprocess.run(['pbpaste'], capture_output=True, text=True)
    return p.stdout.strip()

def set_clipboard(text):
    p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE, encoding='utf8')
    p.communicate(input=text)

def generate_tree(dir_path, prefix=""):
    output = []
    
    try:
        # 获取目录下所有内容并排序
        entries = sorted(os.listdir(dir_path))
        # 过滤
        entries = [e for e in entries if e not in IGNORE_FILES and e not in IGNORE_DIRS]
        
        count = len(entries)
        for index, entry in enumerate(entries):
            path = os.path.join(dir_path, entry)
            is_last = (index == count - 1)
            
            connector = "└── " if is_last else "├── "
            output.append(f"{prefix}{connector}{entry}")
            
            if os.path.isdir(path):
                extension = "    " if is_last else "│   "
                output.extend(generate_tree(path, prefix + extension))
                
    except PermissionError:
        output.append(f"{prefix}└── [Permission Denied]")
        
    return output

def main():
    path = get_clipboard()
    
    if not os.path.exists(path):
        print("❌ 剪贴板不是有效路径")
        sys.exit(1)
        
    if not os.path.isdir(path):
        print("❌ 请复制文件夹路径")
        sys.exit(1)
        
    root_name = os.path.basename(path)
    tree_lines = [root_name + "/"]
    tree_lines.extend(generate_tree(path))
    
    result = "\n".join(tree_lines)
    set_clipboard(result)
    print(f"✅ 目录树已生成 ({len(tree_lines)} 行)")

if __name__ == "__main__":
    main()
