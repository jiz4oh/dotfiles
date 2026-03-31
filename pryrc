Pry.config.pager = !ENV['DISABLE_PRY_PAGER']
Pry.commands.delete /\.(.*)/

begin
  require "awesome_print"
  AwesomePrint.pry!
  AwesomePrint.defaults = {
    index: false,
    indent: 2,
    ruby19_syntax: true, # 使用 a: 1 语法
  }
end
