-- Trigger this script with a shortcut to extract verification code from the latest email in your inbox
on run
	tell application "Mail"
		-- 初始化变量
		set latestMessage to missing value
		set latestDate to missing value

		-- 定义需要检查的收件箱名称列表
		set inboxNames to {"INBOX", "收件箱", "inbox"} -- 可以根据需要添加更多名称

		-- 遍历所有邮箱账户
		repeat with anAccount in accounts
			try
				-- 遍历所有收件箱名称
				repeat with inboxName in inboxNames
					-- 获取收件箱文件夹
					set inboxFolder to my getInboxFolder(anAccount, inboxName)

					-- 如果找到收件箱
					if inboxFolder is not missing value then
						-- 获取最新邮件
						set latestMessageInfo to my getLatestMessage(inboxFolder)
						set currentMessage to item 1 of latestMessageInfo
						set currentDate to item 2 of latestMessageInfo

						-- 检查是否是最新的邮件
						if latestDate is missing value or currentDate > latestDate then
							set latestMessage to currentMessage
							set latestDate to currentDate
						end if
					end if
				end repeat
			on error errMsg
				-- 捕获并记录错误
				log "处理账户 " & name of anAccount & " 时出错：" & errMsg
			end try
		end repeat

		-- 如果找到最新邮件
		if latestMessage is not missing value then
			-- 处理邮件内容
			my processMessage(latestMessage)
		else
			-- 如果没有找到邮件
			display notification "未找到任何邮件。" with title "邮件验证码提取"
		end if
	end tell
end run

-- 获取指定名称的收件箱文件夹
on getInboxFolder(anAccount, inboxName)
	tell application "Mail"
		try
			-- 尝试访问指定名称的收件箱
			if mailbox inboxName of anAccount exists then
				return mailbox inboxName of anAccount
			end if
		on error
			log "账户 " & name of anAccount & " 没有收件箱：" & inboxName
		end try
	end tell
	return missing value
end getInboxFolder

-- 获取收件箱中的最新邮件
on getLatestMessage(inboxFolder)
	tell application "Mail"
		-- 获取收件箱中的邮件数量
		set messageCount to count of messages of inboxFolder
		set latestDate to missing value
		set latestMessage to missing value

		-- 如果收件箱不为空
		if messageCount > 0 then
			-- 获取收件箱中的所有邮件
			set inboxMessages to messages of inboxFolder
			-- 遍历所有邮件，找到最新的一封
			repeat with aMessage in inboxMessages
				set currentDate to date received of aMessage

				-- 如果 latestDate 是 missing value 或者当前邮件日期更新
				if latestDate is missing value or currentDate > latestDate then
					set latestMessage to aMessage
					set latestDate to currentDate
				end if
			end repeat
			return {latestMessage, latestDate}
		end if
	end tell
	return {missing value, missing value}
end getLatestMessage

-- 处理邮件内容
on processMessage(latestMessage)
	tell application "Mail"
		-- 获取邮件内容和发件人
		set messageContent to content of latestMessage
		set senderName to sender of latestMessage

		-- 调用脚本（设置超时时间）
		set scriptPath to "~/bin/extract_verification_code"
		set command to "/bin/zsh -c \"" & scriptPath & " " & quoted form of messageContent & "\""
		try
			with timeout of 10 seconds
				set aiResponse to do shell script command
			end timeout

			-- 检查是否请求失败
			if aiResponse starts with "API 请求失败" then
				-- 弹出系统通知提醒用户
				display notification "AI 请求失败，请检查网络或 API 配置。" with title "邮件验证码提取"
			else if aiResponse is not "" then
				-- 输出结果
				set outputMessage to  aiResponse
				display notification outputMessage with title "邮件验证码提取 from " & senderName
				set the clipboard to aiResponse
			end if
		on error errMsg
			-- 捕获并记录错误
			log "调用脚本时出错：" & errMsg
			display notification "调用脚本失败：" & errMsg with title "邮件验证码提取"
		end try
	end tell
end processMessage

-- Mail.app action
using terms from application "Mail"
    on perform mail action with messages caughtMessages for rule catchingRule
        -- 遍历所有匹配的邮件
        repeat with caughtMessage in caughtMessages
            try
                my processMessage(caughtMessage)
            on error errorString number errorNumber
                -- 捕获并记录错误
                log "处理邮件时出错：" & errorString
            end try
        end repeat
    end perform mail action with messages
end using terms from

