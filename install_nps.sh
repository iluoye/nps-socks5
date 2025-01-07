#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
auth_crpyt_key=$(head /dev/urandom | tr -dc a-f0-9 | head -c 16)
auth_key=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
default_web_admin=spark
default_web_passwd=123166
default_web_port=12123
default_s5_port=49678
default_s5_user=spark
default_s5_pwd=Aa123456

errorMsg=反馈群t.me/Scoks55555
version=v3.0
downLoadUrl=https://github.com/wyx176/nps-socks5/releases/download/
serverSoft=linux_amd64_server
clientSoft=linux_amd64_client
serverUrl=${downLoadUrl}${version}/${serverSoft}.tar.gz
clientUrl=${downLoadUrl}${version}/${clientSoft}.tar.gz
s5Path=/opt/nps-socks5/
ipAdd=检测失败

if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi


check_and_install() {
    for cmd in git unzip wget curl; do
        if ! command -v $cmd &> /dev/null; then
            echo "$cmd 未安装，正在安装..."
            if [[ ${OS} == Ubuntu || ${OS} == Debian ]]; then
                apt-get install $cmd -y
            elif [[ ${OS} == CentOS ]]; then
                yum install $cmd -y
            fi
        else
            echo "$cmd 已安装"
        fi
    done
}

#Install Basic Tools
init(){
    if [[ ${OS} == Ubuntu || ${OS} == Debian ]]; then
        check_and_install
        # apt-get install curl -y
    elif [[ ${OS} == CentOS ]]; then
        check_and_install
        # yum install curl -y
    fi
}


#Install Basic Tools
init2(){
if [[ ${OS} == Ubuntu ]];then
	apt-get  install git unzip wget -y
	apt-get  install curl
fi
if [[ ${OS} == CentOS ]];then
	yum install git unzip wget -y
    yum -y install curl
fi
if [[ ${OS} == Debian ]];then
	apt-get install git unzip wget -y
	apt-get install curl
fi
}

unstallServer(){
	if [[ -d ${s5Path}${serverSoft} ]];then
      cd ${s5Path}${serverSoft} && nps stop && nps uninstall
      rm -rf /etc/nps
      rm -rf /usr/bin/nps
      rm -rf ${s5Path}${serverSoft}
	fi
	 echo "卸载服务端成功"
}

unstallClient(){
  if [[ -d ${s5Path}${clientSoft} ]];then
  	  cd ${s5Path}${clientSoft} && npc stop &&  ./npc uninstall
    	rm -rf ${s5Path}${clientSoft}
    	# rm -rf ${s5Path}${clientSoft}.tar.gz
  fi
  echo "卸载客户端成功"
}

allUninstall(){
  unstallServer
  unstallClient
  #删除之前的
#   if [[ -d ${s5Path} ]];then
	#   rm -rf ${s5Path}
	# fi
}

checkIp(){

    ipAdd=`curl ifconfig.co -4 -s --connect-timeout 10`
    clear
    echo "当前ip地址："${ipAdd}
    read -p "如果不对请停止安装或者手动输入服务器ip：(y/n/ip)： " choice
	
	if [[ "$choice" == 'n' || "$choice" == 'N' ]]; then
			echo "安装结束"
			exit 0
	elif [[ "${choice}" == '' && "${ipAdd}" == '检测失败' ]]; then
			echo "安装失败：ip不正确"
			exit 0
	
	elif [[ "$choice" != 'y' && "$choice" != 'Y' && "${choice}" != '' ]]; then
		check_ip "${choice}"
		ipAdd="${choice}"
	fi

    echo "当前ip地址："${ipAdd}
}

#2.下载服务端
DownloadServer()
{
    echo "下载nps-socks5服务中请耐心等待..."
    if [[ ! -d ${s5Path} ]];then
        mkdir -p ${s5Path}	
    fi
    if [[ ! -f ${s5Path}${serverSoft}.tar.gz ]]; then
        #服务端
        # wget -P ${s5Path} --no-cookie --no-check-certificate ${serverUrl} 2>&1 | progressfilt
        curl -x socks5h://spark:Aa123456@43.134.92.71:9100 ${serverUrl} -o ${s5Path}${serverSoft}.tar.gz -L 2>&1 | progressfilt

        if [[ ! -f ${s5Path}${serverSoft}.tar.gz ]]; then
            echo "服务端文件下载失败"${errorMsg}
            exit 0
        fi
    fi
}

DownloadClient()
{
    echo "下载nps-socks5客户端中请耐心等待..."
    if [[ ! -d ${s5Path} ]];then
        mkdir -p ${s5Path}	
    fi
    if [[ ! -f ${s5Path}${clientSoft}.tar.gz ]]; then
        #客户端
        # wget -P ${s5Path} --no-cookie --no-check-certificate ${clientUrl} 2>&1 | progressfilt
        curl -x socks5h://spark:Aa123456@43.134.92.71:9100 ${clientUrl} -o ${s5Path}${clientSoft}.tar.gz -L 2>&1 | progressfilt

        if [[ ! -f ${s5Path}${clientSoft}.tar.gz ]]; then
            echo "客户端文件下载失败"${errorMsg}
            exit 0
        fi
    fi
}


# 获取账号名，如果为空则生成随机UUID的前8个字符
get_account_name() {
  local input
  read -p "请输入web控制台账号名[默认 $default_web_admin]: " input
  if [ -z "$input" ]; then
    echo "$default_web_admin" # $(uuidgen | cut -c1-8)
  else
    echo "$input"
  fi
}
 
# 获取密码，如果为空则生成随机base64字符串
get_password() {
  local input
  read -p "请输入web控制台密码[默认 $default_web_passwd]: " input
  if [ -z "$input" ]; then
    echo "$default_web_passwd" # $(openssl rand -base64 12)
  else
    echo "$input"
  fi
}

# 获取密码，如果为空则生成随机base64字符串
get_web_port() {
  local input
  read -p "请输入web控制台访问端口[默认 $default_web_port]: " input
  
  if [ -z "$input" ]; then
    echo "$default_web_port"
  else
    echo "$input"
  fi
}


#!/bin/bash

# 函数: update_tasks_json
# 参数:
#   $1 - 文件路径
#   $2 - 端口号
#   $3 - S5User 值
#   awk -v port=49678 -v s5user="spark:Aa123456" '

update_tasks_json() {
  local config_file="$1"
  local new_mapping="{\"$default_s5_user\":\"$default_s5_pwd\"}"
  # 临时文件路径
  local tmp_file=$(mktemp)
    # new_mapping='{"${default_s5_user}":"${default_s5_pwd}"}'
  # 使用awk处理文件
  awk -v port="$default_s5_port" -v s5user="${default_s5_user}:${default_s5_pwd}" -v new_mapping="$new_mapping" '
  BEGIN { FS = OFS = "," }
  {
    if ($0 ~ /"Port":/) {
      sub(/"Port":[^,]*/, "\"Port\":" port)
    }
    if ($0 ~ /"S5User":/) {
      sub(/"S5User":"[^"]*"/, "\"S5User\":\"" s5user "\"")
    }
    if ($0 ~ /"AccountMap":\{/) {
      sub(/\{"socks5":"socks5","user1":"pwd1"\}/, new_mapping)
    }
    print
  }' "$config_file" > "$tmp_file"

  # 替换原文件
  mv "$tmp_file" "$config_file"

  echo "Updated Port to $port and S5User to $s5user in $config_file"
}



#3.安装Socks5服务端程序
InstallServer()
{
    echo ""
    echo "服务端文件解压中..."

    tar zxvf ${s5Path}${serverSoft}.tar.gz -C ${s5Path}

    cd ${s5Path}${serverSoft}

    # 调用函数获取账号名和密码
    default_passwd=$(get_password)
    # echo "";
    default_admin=$(get_account_name)
    # echo "";
    default_web_port=$(get_web_port)
    # echo "";
    # web_username=admin
    # web_password=admin
    # web_port = 18080
    # 输出结果
    echo "账号名: $default_admin"
    echo "密码: $default_passwd"
    echo "web端口: $default_web_port"
    echo "注意：如果密码是随机生成的，请确保妥善保存。"


    #修改配置文件的auth_key和auth_crypt_key，防止被爆破

    # 文件路径
    CONFIG_FILE="./conf/nps.conf"

    # 使用sed命令替换auth_crypt_key的值
    # sed -i "s/^auth_crypt_key *= *.*/auth_crypt_key = $auth_crpyt_key/" "$CONFIG_FILE"

    # sed -i "s/auth_crypt_key =1234567812345678/auth_crypt_key=${auth_crpyt_key}/" ./conf/nps.conf 
    sed -i "s/^auth_crypt_key *= *.*/auth_crypt_key = $auth_crpyt_key/" ./conf/nps.conf 
    sed -i "s/^#auth_key *= *.*/auth_key=${auth_key}/" ./conf/nps.conf
    sed -i "s/^web_username *= *.*/web_username=${default_admin}/" ./conf/nps.conf
    sed -i "s/^web_password *= *.*/web_password=${default_passwd}/" ./conf/nps.conf
    sed -i "s/^web_port *= *.*/web_port = ${default_web_port}/" ./conf/nps.conf

    # 调用函数，传递文件路径、端口号和S5User值
    update_tasks_json "./conf/tasks.json"

    # cat ./conf/nps.conf
    # cat ./conf/tasks.json
    sudo  ./nps install && nps start
}

InstallClient()
{

    echo ""
    echo "客户端文件解压中..."
    if [[ ! -d ${s5Path}${clientSoft} ]]; then
        echo "-------------"${s5Path}${clientSoft}
        mkdir -p ${s5Path}${clientSoft}
    fi
    tar zxvf ${s5Path}${clientSoft}.tar.gz -C ${s5Path}${clientSoft}

    clear
    echo "客户端文件安装中..."
    cd ${s5Path}${clientSoft}
    if [[ $menuChoice == 1 ]];then
        ./npc install  -server=${ipAdd}:8025 -vkey=ij7poeu2d9btjbd3 -type=tcp && npc start
    else
        echo "服务器参数在[服务端]->服务列表+号中"
        echo "类似：./npc -server=xxx.xxx.xxx.172:8025 -vkey=ij7poeu2d9btjbd3 -type=tcp"
        echo "只需要输入:-server=xxx.xxx.xxx.172:8025 -vkey=ij7poeu2d9btjbd3 -type=tcp 即可"
        read -p "请输入服务端参数： " serverParam
        ./npc install ${serverParam} && npc start
    fi
}



checkServer(){
    #检查服务端是否安装成功
    SPID=`ps -ef|grep nps |grep -v grep|awk '{print $2}'`
    if [[ -z ${SPID} ]]; then
        echo ${SPID}"SPID----------------------"
        echo "服务端安装失败"${errorMsg}
        unstallServer
        exit 0
    fi
}


checkClient(){

    CPID=`ps -ef|grep npc |grep -v grep|awk '{print $2}'`
    if [[ -z ${CPID} ]]; then
        echo "客户端安装失败"${errorMsg}
        unstallClient
        exit 0
    fi
}



function check_ip(){
        IP=$1
        VALID_CHECK=$(echo $IP|awk -F. '$1<=255 && $2<=255 && $3<=255 && $4<=255 {print "yes"}')
        
        if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then
                if [[ $VALID_CHECK == "yes" ]]; then
                        return=$IP
                else
                        echo "安装失败：ip不正确"
						exit 0
                fi
        else
               echo "安装失败：非ip"
			   exit 0
        fi
}

progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%s' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}


menu(){
echo '1.全部安装(推荐只有"一台"服务器情况下)'
echo '2.安装服务端(推荐安装在"国内"服务器[中转机])'
echo '3.安装客户端(推荐安装在"国外"服务器)'
echo "4.卸载服务端"
echo "5.卸载客户端"
echo "6.全卸载"
echo "0.退出"
while :; do echo
	read -p "请选择： " menuChoice
	if [[ ! $menuChoice =~ ^[0-6]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
done


if [[ $menuChoice == 0 ]];then
	exit 0
fi	

if [[ $menuChoice == 1 ]];then
	#安装服务端
	init
	checkIp
	
	allUninstall
	DownloadServer
	DownloadClient
	InstallServer
	InstallClient
	checkServer
	checkClient
	clear
	echo "--安装成功------"${errorMsg}
	echo "--后台管理地址: "${ipAdd}":"${default_web_port}
	# echo "--登录账号admin"
	# echo "--登录密码admin"
    echo "--登录账号: $default_admin"
    echo "--登录密码: $default_passwd"
    # echo "--web端口: $default_web_port"
	echo "默认socks5账号信息:账号 $default_s5_user 密码 $default_s5_pwd 端口 $default_s5_port"
    echo "使用命令测试代理: curl -x socks5h://$default_s5_user:$default_s5_pwd@${ipAdd}:$default_s5_port http://myip.ipip.net"
	echo "如需修改后台管理端口以及账号密码请看github"

fi
if [[ $menuChoice == 2 ]];then
	init
	checkIp
	unstallServer
	DownloadServer
	InstallServer
	checkServer
	clear
	echo "--安装成功------"${errorMsg}
	echo "--后台管理地址: "${ipAdd}":"${default_web_port}
	echo "--登录账号: $default_admin"
    echo "--登录密码: $default_passwd"
fi

if [[ $menuChoice == 3 ]];then
	clear
	unstallClient
	DownloadClient
	clear
	InstallClient
	checkClient
	echo "--安装成功------"${errorMsg}
fi
if [[ $menuChoice == 4 ]];then
unstallServer
fi

if [[ $menuChoice == 5 ]];then
unstallClient
fi

if [[ $menuChoice == 6 ]];then
allUninstall
fi
}
menu
