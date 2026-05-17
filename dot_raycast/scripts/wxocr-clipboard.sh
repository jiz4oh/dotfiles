#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title OCR Clipboard Image
# @raycast.mode fullOutput
# @raycast.packageName OCR Tools

# Optional parameters:
# @raycast.icon 🔍
# @raycast.argument1 { "type": "text", "placeholder": "OCR 服务 URL", "optional": true }

# Documentation:
# @raycast.description Send clipboard image to wxocr service and write recognized text to local clipboard.

set -euo pipefail

OCR_URL="${1:-${WXOCR_URL:-http://nuc.local:5000/ocr}}"
TMP_FILE="$(mktemp /tmp/wxocr-clipboard-XXXXXX.png)"
trap 'rm -f "$TMP_FILE"' EXIT

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "缺少命令: $1"
        exit 1
    fi
}

require_cmd osascript
require_cmd curl
require_cmd jq
require_cmd base64
require_cmd pbcopy

if ! osascript \
    -e 'set pngData to the clipboard as «class PNGf»' \
    -e "set fileRef to open for access POSIX file \"$TMP_FILE\" with write permission" \
    -e 'set eof fileRef to 0' \
    -e 'write pngData to fileRef' \
    -e 'close access fileRef' \
    >/dev/null 2>&1; then
    echo "剪贴板中需要有图片数据"
    exit 1
fi

IMAGE_BASE64="$(base64 < "$TMP_FILE" | tr -d '\n')"
PAYLOAD="$(jq -n --arg image "$IMAGE_BASE64" '{image: $image}')"

HTTP_BODY_AND_CODE="$(
    curl -sS --max-time 30 \
        -w '\n%{http_code}' \
        -H 'Content-Type: application/json' \
        -d "$PAYLOAD" \
        "$OCR_URL"
)"

HTTP_CODE="${HTTP_BODY_AND_CODE##*$'\n'}"
HTTP_BODY="${HTTP_BODY_AND_CODE%$'\n'*}"

if [[ "$HTTP_CODE" != "200" ]]; then
    API_ERR="$(echo "$HTTP_BODY" | jq -r '.error // empty' 2>/dev/null || true)"
    if [[ -n "$API_ERR" ]]; then
        echo "OCR 服务错误: $API_ERR (HTTP $HTTP_CODE)"
    else
        echo "OCR 服务错误: HTTP $HTTP_CODE"
    fi
    exit 1
fi

RECOGNIZED_TEXT="$(
    echo "$HTTP_BODY" | jq -r '
      if (.result | type) == "object" then
        [(.result.ocr_response // [])[]?.text] | join("\n")
      else
        [(.ocr_response // [])[]?.text] | join("\n")
      end
    '
)"

printf '%s' "$RECOGNIZED_TEXT" | pbcopy

if [[ -n "$RECOGNIZED_TEXT" ]]; then
    echo "OCR 完成，文本已写入剪贴板："
    echo
    echo "$RECOGNIZED_TEXT"
else
    echo "OCR 完成，未识别到文本，剪贴板已清空"
fi
