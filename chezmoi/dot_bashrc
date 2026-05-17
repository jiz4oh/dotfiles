for file in $HOME/.shenv \
  $HOME/.alias; do
  if test -f "$file"; then
    # 文件存在,执行source命令加载文件
    source "$file"
  fi
done

[ -f $HOME/.zpath ] && source $HOME/.zpath
