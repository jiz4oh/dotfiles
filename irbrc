%w(awesome_print rubygems pry pry-editline).each do |lib|
  begin
    require lib
  rescue LoadError
  end
end

begin
  AwesomePrint.irb!
  AwesomePrint.defaults = {
    index: false,
    indent: 2,
    ruby19_syntax: true, # 使用 a: 1 语法
  }
end

(Pry.start; exit) if defined?(Pry)

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:LOAD_MODULES] |= %w(irb/completion stringio enumerator ostruct)
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = if defined?(Rails) && Rails.root
                            Rails.root.join('tmp', 'history.rb')
                          else
                            File.expand_path('~/.history.rb')
                          end
# https://github.com/ruby/irb/issues/43#issuecomment-572981408
IRB.conf[:USE_MULTILINE] = false
