#!/usr/bin/env ruby

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ROI Calculator
# @raycast.mode fullOutput
# @raycast.packageName Finance Tools

# Optional parameters:
# @raycast.icon 💎
# @raycast.argument1 { "type": "text", "placeholder": "A (当前值/现价)" }
# @raycast.argument2 { "type": "text", "placeholder": "B (基准值/成本)" }

def calculate_change(current_val, base_val)
  # 输入验证
  if current_val.nil? || current_val.empty? || base_val.nil? || base_val.empty?
    puts "## ⚠️ 错误"
    puts "请输入数值 A 和 B"
    return
  end
  
  a = current_val.to_f
  b = base_val.to_f

  if b == 0
    puts "## ⚠️ 错误"
    puts "基准值 (B) 不能为 0"
    return
  end

  # 计算
  change_amount = a - b
  percent_change = (change_amount / b) * 100
  
  # 判断涨跌颜色和符号
  # A股习惯：涨(正)为红，跌(负)为绿
  # 国际/加密货币习惯：涨(正)为绿，跌(负)为红
  # 这里默认使用 Emoji 直观展示：
  if percent_change > 0
    emoji = "🔴" # A股涨幅红色喜庆（如果不习惯可改为 🟢）
    trend = "上涨"
    sign = "+"
  elsif percent_change < 0
    emoji = "🟢" 
    trend = "下跌"
    sign = ""
  else
    emoji = "⚪️"
    trend = "持平"
    sign = ""
  end

  formatted_percent = sprintf("%s%.2f%%", sign, percent_change)
  formatted_amount = sprintf("%s%.2f", sign, change_amount)

  # --- 输出 Markdown ---
  
  # 1. 大标题显示百分比
  puts "# #{emoji} #{formatted_percent}"
  
  # 2. 引用块显示具体金额变动
  puts "> **#{trend}金额**: #{formatted_amount}"
  puts ""
  puts "---"
  puts ""

  # 3. 表格展示详细参数
  puts "| 参数 | 数值 |"
  puts "| :--- | :--- |"
  puts "| **🅰️ 当前值 (A)** | #{a} |"
  puts "| **🅱️ 成本/基准 (B)** | #{b} |"
  
  puts ""
  puts "---"
  # 4. 底部显示公式说明（可选）
  puts "*公式: (A - B) / B*"
end

calculate_change(ARGV[0], ARGV[1])
