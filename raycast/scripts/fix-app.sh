#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Fix App
# @raycast.mode fullOutput

# @raycast.icon 🛡️
# @raycast.packageName System

# --- 1. 智能选择逻辑 (Finder选中 或 弹窗选择) ---
SELECTED_APP=$(osascript -e 'tell application "Finder" to get POSIX path of (selection as alias)' 2>/dev/null)
SELECTED_APP=${SELECTED_APP%/}

if [ -n "$SELECTED_APP" ] && [[ "$SELECTED_APP" == *.app ]]; then
  TARGET_APP="$SELECTED_APP"
else
  TARGET_APP=$(osascript -e 'try
      set defaultFolder to POSIX file "/Applications" as alias
      set theFile to choose file with prompt "请选择 App：" of type {"app"} default location defaultFolder
      POSIX path of theFile
  on error
      return "CANCELLED"
  end try')
fi

if [ "$TARGET_APP" = "CANCELLED" ] || [ -z "$TARGET_APP" ]; then
  echo "❌ 操作已取消"
  exit 0
fi

# --- 2. 执行修复 (智能处理 "No such xattr" 错误) ---
osascript -e "
try
    do shell script \"xattr -d com.apple.quarantine '$TARGET_APP' 2>&1\" with administrator privileges
    display notification \"成功移除隔离属性\" with title \"✅ 修复成功\"
    return \"✅ 修复成功\"
on error errMsg
    if errMsg contains \"No such xattr\" then
        display notification \"该 App 未被隔离，无需修复\" with title \"👌 无需修复\"
    else
        display alert \"修复失败\" message errMsg as critical
    end if
end try"
