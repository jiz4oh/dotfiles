kport () {
  kill -9 $(lsof -t -i :$1)
}

proxy () {
    export url=${1:=127.0.0.1} && export port=${2:=37890} && export https_proxy=http://$url:$port http_proxy=http://$url:$port all_proxy=socks5://$url:$port
    echo "Proxy on"
}

unproxy () {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    echo "Proxy off"
}

ports() {
    # 场景 1: 查找特定端口
    if [ -n "$1" ]; then
        if [ "$(uname)" = "Darwin" ]; then
            # macOS 使用 lsof (netstat 在 mac 上查 pid 很痛苦)
            lsof -i :$1
        else
            if command -v ss > /dev/null; then
                ss -tunlp | grep ":$1 "
            else
                netstat -tunlp | grep ":$1 "
            fi
        fi
        return
    fi

    # 场景 2: 列出所有监听端口
    if [ "$(uname)" = "Darwin" ]; then
        # macOS: 使用 lsof -i -P -n | grep LISTEN
        # -P 不解析端口号(显示 80 而不是 http), -n 不解析主机名
        lsof -i -P -n | grep LISTEN
    else
        if command -v ss > /dev/null; then
            ss -tunlp
        else
            netstat -tunlp
        fi
    fi
}

