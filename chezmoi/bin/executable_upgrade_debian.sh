#!/bin/bash

# 设置失败即退出
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 权限检查
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR]${NC} 此脚本必须以 root 权限运行！"
   exit 1
fi

# 获取当前大版本号
MAIN_VER=$(cut -d. -f1 /etc/debian_version)

__do_apt_upgrade(){
    echo -e "${YELLOW}[INFO]${NC} 正在更新软件包列表..."
    apt-get update
    echo -e "${YELLOW}[INFO]${NC} 正在执行系统基础升级..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get upgrade -y
    echo -e "${YELLOW}[INFO]${NC} 正在执行完整发行版升级..."
    apt-get dist-upgrade -y
    apt-get autoremove -y
}

__backup_sources(){
    echo -e "${YELLOW}[INFO]${NC} 备份当前的 APT 源文件..."
    cp /etc/apt/sources.list "/etc/apt/sources.list.bak.$(date +%Y%m%d)"
}

__upgrade_logic(){
    local FROM=$1
    local TO=$2
    local OLD_CODENAME=$3
    local NEW_CODENAME=$4

    echo -e "${GREEN}[PROCESS]${NC} 准备从 Debian $FROM ($OLD_CODENAME) 升级到 Debian $TO ($NEW_CODENAME)..."
    
    __backup_sources
    
    echo -e "${YELLOW}[INFO]${NC} 正在将软件源从 $OLD_CODENAME 修改为 $NEW_CODENAME..."
    # 替换主源和 .list 扩展源
    sed -i "s/$OLD_CODENAME/$NEW_CODENAME/g" /etc/apt/sources.list
    if ls /etc/apt/sources.list.d/*.list 1> /dev/null 2>&1; then
        sed -i "s/$OLD_CODENAME/$NEW_CODENAME/g" /etc/apt/sources.list.d/*.list
    fi

    # 特殊处理安全源命名规范 (Debian 11 之后统一为 代码名-security)
    if [ "$TO" -ge 11 ]; then
        sed -i "s/$NEW_CODENAME\/updates/$NEW_CODENAME-security/g" /etc/apt/sources.list
    fi

    __do_apt_upgrade

    # Debian 13 特有的现代化提示
    if [ "$TO" == "13" ]; then
        echo -e "${GREEN}[DONE]${NC} 系统已升级至 Debian 13。"
        echo -e "${YELLOW}[TIPS]${NC} Debian 13 推荐使用新版 deb822 源格式。"
        echo -e "你可以手动运行: ${CYAN}apt modernize-sources${NC} 来转换源格式。"
    fi

    echo -e "${GREEN}[SUCCESS]${NC} 升级完成！请键入 'reboot' 重启系统。"
}

# 交互逻辑
case $MAIN_VER in
    9)
        read -p "检测到 Debian 9，是否升级到 10 (Buster)? (y/n): " ans
        [[ "$ans" == "y" ]] && __upgrade_logic 9 10 "stretch" "buster"
        ;;
    10)
        read -p "检测到 Debian 10，是否升级到 11 (Bullseye)? (y/n): " ans
        [[ "$ans" == "y" ]] && __upgrade_logic 10 11 "buster" "bullseye"
        ;;
    11)
        read -p "检测到 Debian 11，是否升级到 12 (Bookworm)? (y/n): " ans
        [[ "$ans" == "y" ]] && __upgrade_logic 11 12 "bullseye" "bookworm"
        ;;
    12)
        read -p "检测到 Debian 12，是否升级到 13 (Trixie)? (y/n): " ans
        [[ "$ans" == "y" ]] && __upgrade_logic 12 13 "bookworm" "trixie"
        ;;
    13)
        echo -e "${GREEN}[INFO]${NC} 您的系统已经是 Debian 13 (最新稳定版)。"
        ;;
    *)
        echo -e "${RED}[ERROR]${NC} 当前版本 ($MAIN_VER) 不在脚本支持范围内。"
        ;;
esac
