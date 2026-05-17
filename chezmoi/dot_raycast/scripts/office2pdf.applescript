#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert to PDF
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🛠️
# @raycast.packageName Office Automation

use AppleScript version "2.4"
use scripting additions

on run
	tell application "Finder"
		set selectionList to selection as alias list
	end tell
	
	if selectionList is {} then
		return "⚠️ 未选中任何文件"
	end if
	
	set errorLog to ""
	set successCount to 0
	
	repeat with aFile in selectionList
		tell application "Finder" to set fileExtension to name extension of aFile
		set fileExtension to do shell script "echo " & quoted form of fileExtension & " | tr '[:upper:]' '[:lower:]'"
		
		set resultMsg to ""
		if fileExtension is in {"doc", "docx"} then
			set resultMsg to convertWord(aFile)
		else if fileExtension is in {"xls", "xlsx"} then
			set resultMsg to convertExcel(aFile)
		end if
		
		if resultMsg is "OK" then
			set successCount to successCount + 1
		else if resultMsg is not "" then
			set errorLog to errorLog & "\nFile: " & (name of (info for aFile)) & " -> Error: " & resultMsg
		end if
	end repeat
	
	if errorLog is "" then
		return "✅ 全部完成: " & successCount & " 个"
	else
		-- 这里的 display dialog 会强制弹窗显示错误详情，方便你截图或复制
		display dialog "转换出错详情:" & errorLog buttons {"OK"} default button "OK"
		return "⚠️ 成功: " & successCount & "，但在弹窗中查看失败原因"
	end if
end run

-- ================= WORD 处理函数 =================
on convertWord(aFile)
	try
		set inputPath to aFile as text
		
		-- 路径处理：简单粗暴地替换后缀
		if inputPath ends with ".docx" then
			set pdfPath to text 1 thru -6 of inputPath & ".pdf"
		else if inputPath ends with ".doc" then
			set pdfPath to text 1 thru -5 of inputPath & ".pdf"
		else
			set pdfPath to inputPath & ".pdf"
		end if
		
		-- 检查并删除已存在的 PDF（防止弹窗卡死）
		try
			tell application "Finder" to delete file pdfPath
		end try
		
		tell application "Microsoft Word"
			set activeDoc to open file inputPath
			
			-- 核心：Word 导出 PDF
			try
				save as activeDoc file name pdfPath file format format PDF
			on error saveErr
				close activeDoc saving no
				return "Word 保存失败: " & saveErr
			end try
			
			close activeDoc saving no
		end tell
		return "OK"
	on error errMsg
		return "Word 打开失败: " & errMsg
	end try
end convertWord

-- ================= EXCEL 处理函数 =================
on convertExcel(aFile)
	try
		set inputPath to aFile as text
		
		if inputPath ends with ".xlsx" then
			set pdfPath to text 1 thru -6 of inputPath & ".pdf"
		else if inputPath ends with ".xls" then
			set pdfPath to text 1 thru -5 of inputPath & ".pdf"
		else
			set pdfPath to inputPath & ".pdf"
		end if
		
		-- 检查并删除已存在的 PDF
		try
			tell application "Finder" to delete file pdfPath
		end try
		
		tell application "Microsoft Excel"
			set activeWB to open workbook workbook file name inputPath
			
			try
				-- 核心：Excel 导出 PDF (使用最稳妥的 format 57 兼容写法)
				save workbook as activeWB filename pdfPath file format PDF file format
			on error saveErr
				close activeWB saving no
				return "Excel 保存失败: " & saveErr
			end try
			
			close activeWB saving no
		end tell
		return "OK"
	on error errMsg
		return "Excel 打开失败: " & errMsg
	end try
end convertExcel
