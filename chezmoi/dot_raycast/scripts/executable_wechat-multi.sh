#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title 微信多开助手
# @raycast.mode fullOutput
# @raycast.packageName WeChat Tools

# Optional parameters:
# @raycast.icon 💬
# @raycast.argument1 { "type": "text", "placeholder": "多开数量 (默认为2)", "optional": true }

# Documentation:
# @raycast.description 创建并启动多个独立的微信实例
# @raycast.author Stephen-a2z & Modified for Raycast

# --------------------------------------------------------
# 核心逻辑配置
# --------------------------------------------------------

# 获取用户输入，默认为2
INPUT_COUNT="${1:-2}"

# 验证输入
if ! [[ "$INPUT_COUNT" =~ ^[0-9]+$ ]] || [ "$INPUT_COUNT" -lt 2 ]; then
    echo "⚠️ 错误：请输入大于等于2的数字"
    exit 1
fi

# 检查是否以root权限运行，如果不是，则通过AppleScript请求权限
if [ "$EUID" -ne 0 ]; then
    echo "🔐 需要管理员权限来复制和修改应用程序..."
    echo "请在弹出的窗口中输入开机密码。"
    
    # 获取当前脚本的完整路径
    SCRIPT_PATH=$(abspath "$0" 2>/dev/null || readlink -f "$0" 2>/dev/null || echo "$0")
    
    #以此脚本路径再次调用，但这次通过 sudo
    osascript -e "do shell script \"bash '$SCRIPT_PATH' $INPUT_COUNT\" with administrator privileges"
    
    if [ $? -eq 0 ]; then
        echo "✅ 脚本执行完毕"
    else
        echo "❌ 权限验证取消或执行出错"
    fi
    exit 0
fi

# --------------------------------------------------------
# 以下为管理员权限下执行的逻辑
# --------------------------------------------------------

OPEN_COUNT=$1

echo "🚀 开始执行微信 ${OPEN_COUNT} 开..."

# 检查微信主程序
if [ ! -d "/Applications/WeChat.app" ]; then
    echo "❌ 错误：未在应用程序目录找到微信"
    exit 1
fi

# 检查Xcode工具
if ! command -v /usr/libexec/PlistBuddy &> /dev/null; then
    echo "❌ 错误：未找到 PlistBuddy工具，请安装Xcode命令行工具"
    exit 1
fi

# 关闭现有进程
if pgrep -q "WeChat"; then
    echo "🔄 关闭现有微信进程..."
    pkill "WeChat"
    sleep 2
fi

# 清理旧实例 (清理范围扩大到10以防万一)
echo "🧹 清理旧的多开实例..."
for ((i=2; i<=10; i++)); do
    if [ -d "/Applications/WeChat${i}.app" ]; then
        rm -rf "/Applications/WeChat${i}.app"
    fi
done

# 创建新实例
for ((i=2; i<=OPEN_COUNT; i++)); do
    APP_NAME="WeChat${i}.app"
    BUNDLE_ID="com.tencent.xinWeChat${i}"
    DISPLAY_NAME="微信${i}"
    APP_PATH="/Applications/${APP_NAME}"
    
    echo "----------------------------------------"
    echo "📦 正在处理: ${DISPLAY_NAME}"
    
    # 复制
    cp -R "/Applications/WeChat.app" "${APP_PATH}"
    
    # 修改 Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${BUNDLE_ID}" "${APP_PATH}/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${DISPLAY_NAME}" "${APP_PATH}/Contents/Info.plist"
    
    # 创建标识文件
    touch "${APP_PATH}/Contents/Resources/wechat${i}_identifier.txt"
    
    # 重新签名 (关键步骤)
    echo "🔏 重新签名..."
    codesign --force --deep --sign - "${APP_PATH}" > /dev/null 2>&1
    
    echo "✅ ${DISPLAY_NAME} 准备就绪"
done

echo "----------------------------------------"

# 启动原版
echo "🚀 启动原版微信..."
open -a "WeChat"
sleep 2

# 启动多开版
for ((i=2; i<=OPEN_COUNT; i++)); do
    APP_NAME="WeChat${i}.app"
    echo "🚀 启动 微信${i}..."
    open "/Applications/${APP_NAME}"
    sleep 1
done

echo "🎉 所有微信实例已启动！"
