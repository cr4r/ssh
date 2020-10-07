#!/bin/bash
if [ ! -f /etc/lsb-release ];then
    if ! grep -Eqi "ubuntu|debian" /etc/issue;then
        echo "\033[1;31m $(fun_trans "Shadowsocks hanya untuk Versi ubuntu dan debian.")\033[0m"
        exit 1
    fi
fi

declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
LIBSODIUM_VER=stable
MBEDTLS_VER=2.16.5
ss_file=0
v2_file=0
get_latest_ver(){
    ss_file=$(wget -qO- https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest| grep name | grep tar | cut -f4 -d\")
    v2_file=$(wget -qO- https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest| grep linux-amd64 | grep name | cut -f4 -d\")
}

# Set shadowsocks-libev config password
set_password(){
msg -bar
msg -ama " $(fun_trans "Masukkan Password Shadowsocks")"
read -p "(Default password: cr4rrr):" shadowsockspwd
[ -z "${shadowsockspwd}" ] && shadowsockspwd="cr4rrr"
msg -bar
}

# Set domain
set_domain(){
msg -ama "$(fun_trans "jika kau tidak mempunyai domain, kau bisa daftar disini gratis:")"
msg -ama "https://my.freenom.com/clientarea.php"
read -p "$(msg -ama "$(fun_trans "Masukkan domain")\033[0m: ")" domain
str=`echo $domain | grep '^\([a-zA-Z0-9_\-]\{1,\}\.\)\{1,\}[a-zA-Z]\{2,5\}'`
while [ ! -n "${str}" ]
do
      echo "\033[1;31m$(fun_trans "Domain Salah.")\033[0m"
      echo "\033[1;31mKetikan Ulang:\033[0m"
      read domain
      str=`echo $domain | grep '^\([a-zA-Z0-9_\-]\{1,\}\.\)\{1,\}[a-zA-Z]\{2,5\}'`
done
msg -ama "domain = ${domain}"
}

# Pre-installation
pre_install(){
read -p "$(fun_trans "Press any key to start the installation.")" a
msg -ama "$(fun_trans "Memulai instalasi. Ini mungkin memakan waktu cukup lama")."
apt-get update &>/dev/null
apt-get install -y --no-install-recommends gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake &>/dev/null
}


# Installation of Libsodium
install_libsodium(){
msg -ama "Memulai Instalasi libsodium ====>>"  
if [ -f /usr/lib/libsodium.a ] || [ -f /usr/lib64/libsodium.a ];then
      msg -ama "$(fun_trans "Libsodium sudah terinstall sebelumnya, skip.")"
else
      if [ ! -f libsodium-$LIBSODIUM_VER.tar.gz ];then
      wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz -O libsodium-$LIBSODIUM_VER.tar.gz &>/dev/null
      fi
      tar xf libsodium-$LIBSODIUM_VER.tar.gz &>/dev/null
      cd libsodium-$LIBSODIUM_VER &>/dev/null
      ./configure --prefix=/usr && make &>/dev/null
      make install &>/dev/null
      cd .. &>/dev/null
      ldconfig &>/dev/null
      if [ ! -f /usr/lib/libsodium.a ] && [ ! -f /usr/lib64/libsodium.a ];then
      echo "\033[1;31m $(fun_trans "Gagal install libsodium.")\033[0m"
      exit 1
      fi
fi
}


# Installation of MbedTLS
install_mbedtls(){
msg -ama "Instalasi mbedtls ====>>"
if [ -f /usr/lib/libmbedtls.a ];then
      msg -ama "$(fun_trans "MbedTLS sudah terinstall sebelumnya, skip.")"
else
      if [ ! -f mbedtls-$MBEDTLS_VER-gpl.tgz ];then
      wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz &>/dev/null
      fi
      tar xf mbedtls-$MBEDTLS_VER-gpl.tgz &>/dev/null
      cd mbedtls-$MBEDTLS_VER &>/dev/null
      make SHARED=1 CFLAGS=-fPIC &>/dev/null
      make DESTDIR=/usr install &>/dev/null
      cd .. &>/dev/null
      ldconfig &>/dev/null
      if [ ! -f /usr/lib/libmbedtls.a ];then
      echo "\033[1;31m $(fun_trans "Gagal install MbedTLS.")\033[0m"
      exit 1
      fi
fi
}


# Installation of shadowsocks-libev
install_ss(){
if [ -f /usr/local/bin/ss-server ];then
      msg -ama "$(fun_trans "Shadowsocks-libev sudah terinstall sebelumnya, skip.")"
else
      if [ ! -f $ss_file ];then
      ss_url=$(wget -qO- https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest| grep browser_download_url | cut -f4 -d\")
      wget $ss_url &>/dev/null
      fi
      tar -xvf $ss_file &>/dev/null
      cd $(echo ${ss_file} | cut -f1-3 -d\.)
      ./configure  &>/dev/null&& make &>/dev/null
      make install &>/dev/null
      cd .. &>/dev/null
      if [ ! -f /usr/local/bin/ss-server ];then
      msg -ama "$(fun_trans "Gagal install shadowsocks-libev.")"
      exit 1
      fi
fi
}


# Installation of v2ray-plugin
install_v2(){
msg -ama "Instalasi plugin v2ray ====>>"
if [ -f /usr/local/bin/v2ray-plugin ];then
      msg -ama "$(fun_trans "v2ray-plugin sudah terinstall sebelumnya, skip.")"
else
      if [ ! -f $v2_file ];then
      v2_url=$(wget -qO- https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest| grep linux-amd64 | grep browser_download_url | cut -f4 -d\")
      wget $v2_url &>/dev/null
      fi
      tar xf $v2_file &>/dev/null
      mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin &>/dev/null
      if [ ! -f /usr/local/bin/v2ray-plugin ];then
      msg -ama "$(fun_trans "Gagagl install v2ray-plugin.")"
      exit 1
      fi
fi
}

# Configure
ss_conf(){
msg -ama "Mengkonfigurasi ShadowSocks"
mkdir /etc/shadowsocks-libev &>/dev/null
cat >/etc/shadowsocks-libev/config.json << EOF
{
    "server":"0.0.0.0",
    "server_port":$Lport,
    "password":"$shadowsockspwd",
    "timeout":300,
    "method":"$encriptacao",
    "plugin":"v2ray-plugin",
    "plugin_opts":"server;tls;cert=/etc/letsencrypt/live/$domain/fullchain.pem;key=/etc/letsencrypt/live/$domain/privkey.pem;host=$domain;loglevel=none"
}
EOF
cat >/lib/systemd/system/shadowsocks.service << EOF
[Unit]
Description=Shadowsocks-libev Server Service
After=network.target
[Service]
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
}

get_cert(){
msg -ama "Membuat Sertifkat untuk v2ray"
if [ -f /etc/letsencrypt/live/$domain/fullchain.pem ];then
      msg -ama "$(fun_trans "Sertifikat Sudah ada, Skip.")"
else
      apt-get update &>/dev/null
      if grep -Eqi "ubuntu" /etc/issue;then
      apt-get install -y software-properties-common &>/dev/null
      add-apt-repository -y universe &>/dev/null
      add-apt-repository -y ppa:certbot/certbot &>/dev/null
      apt-get update &>/dev/null
      fi
      apt-get install -y certbot &>/dev/null
      certbot certonly --cert-name $domain -d $domain --standalone --agree-tos --register-unsafely-without-email &>/dev/null
      systemctl enable certbot.timer &>/dev/null
      systemctl start certbot.timer &>/dev/null
      if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ];then
      echo "\033[1;31m $(fun_trans "Gagal membuat sertifikat.")\033[0m"
      exit 1
      fi
fi
}

start_ss(){
msg -ama "Memulai Shadowsocks"
systemctl status shadowsocks > /dev/null 2>&1
if [ $? -eq 0 ]; then
      systemctl stop shadowsocks &>/dev/null
fi
systemctl enable shadowsocks
systemctl start shadowsocks &>/dev/null
msg -bar
}

remove_files(){
rm -f libsodium-$LIBSODIUM_VER.tar.gz mbedtls-$MBEDTLS_VER-gpl.tgz $ss_file $v2_file
rm -rf libsodium-$LIBSODIUM_VER mbedtls-$MBEDTLS_VER $(echo ${ss_file} | cut -f1-3 -d\.)
}

print_ss_info(){
clear
msg -ama "$(fun_trans "Selamat, Shadowsocks-libev server Berhasil di install")"
echo "Your Server IP        :  ${domain} "
echo "Your Server Port      :  ${Lport} "
echo "Your Password         :  ${shadowsockspwd} "
echo "Your Encryption Method:  ${encriptacao} "
echo "Your Plugin           :  v2ray-plugin"
echo "Your Plugin options   :  tls;host=${domain}"
echo "Enjoy it!"
}

install_all(){
    set_password
    set_domain
msg -bar
    pre_install
    install_libsodium
    install_mbedtls
    get_latest_ver
    install_ss
    install_v2
    ss_conf
    get_cert
    start_ss
    remove_files
    print_ss_info
msg -bar
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}

remove_all(){
systemctl disable shadowsocks &>/dev/null
systemctl stop shadowsocks &>/dev/null
apt --purge remove libshadowsocks-libev -y &>/dev/null
rm -fr /etc/shadowsocks-libev &>/dev/null
rm -f /usr/local/bin/ss-local &>/dev/null
rm -f /usr/local/bin/ss-tunnel &>/dev/null
rm -f /usr/local/bin/ss-server &>/dev/null
rm -f /usr/local/bin/ss-manager &>/dev/null
rm -f /usr/local/bin/ss-redir &>/dev/null
rm -f /usr/local/bin/ss-nat &>/dev/null
rm -f /usr/local/bin/v2ray-plugin &>/dev/null
rm -f /usr/local/lib/libshadowsocks-libev.a &>/dev/null
rm -f /usr/local/lib/libshadowsocks-libev.la &>/dev/null
rm -f /usr/local/include/shadowsocks.h &>/dev/null
rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc &>/dev/null
rm -f /usr/local/share/man/man1/ss-local.1 &>/dev/null
rm -f /usr/local/share/man/man1/ss-tunnel.1 &>/dev/null
rm -f /usr/local/share/man/man1/ss-server.1 &>/dev/null
rm -f /usr/local/share/man/man1/ss-manager.1 &>/dev/null
rm -f /usr/local/share/man/man1/ss-redir.1 &>/dev/null
rm -f /usr/local/share/man/man1/ss-nat.1 &>/dev/null
rm -f /usr/local/share/man/man8/shadowsocks-libev.8 &>/dev/null
rm -fr /usr/local/share/doc/shadowsocks-libev &>/dev/null
rm -f /usr/lib/systemd/system/shadowsocks.service &>/dev/null
msg -bar
msg -ama "$(fun_trans "Remove success!")"
msg -bar
}


mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}


fun_shadowsocks () {
#ESCOLHENDO LISTEN
msg -ama " $(fun_trans "Selamat datang di Menu Shadowsocks")"
msg -ama " $(fun_trans "[1] Install")"
msg -ama " $(fun_trans "[2] Remove")"
read -p "($(fun_trans "Default option: Install")): " option
option=${option:-1}
if [ $option -eq 2 ];then
remove_all
else
echo -e "\033[1;32m $(fun_trans "Instalasi SHADOWSOCKS*") by-cr4r"
msg -bar
msg -ama " $(fun_trans "Ketik port untuk dibuka di shadowsocks")"
msg -bar
while true; do
unset Lport
read -p " Listen Port: " Lport
[[ $(mportas|grep "$Lport") = "" ]] && break
echo -e " ${Lport}: $(fun_trans "Port salah")"      
done
msg -bar
while true; do
msg -ama " $(fun_trans "Pilih Enkripsi")"
msg -bar
encript=(aes-256-gcm aes-192-gcm aes-128-gcm aes-256-ctr aes-192-ctr aes-128-ctr aes-256-cfb aes-192-cfb aes-128-cfb camellia-128-cfb camellia-192-cfb camellia-256-cfb chacha20-ietf-poly1305 chacha20-ietf chacha20 rc4-md5)
for((s=0; s<${#encript[@]}; s++)); do
echo -e " [${s}] - ${encript[${s}]}"
done
msg -bar
while true; do
unset cript
echo -ne " $(fun_trans "Enkripsi yang mana")? \n$(fun_trans "Silahkan pilih"): "; read -e cript
[[ ${encript[$cript]} ]] && break
echo -e "$(fun_trans "Opsi salah")"
done
encriptacao="${encript[$cript]}"
[[ ${encriptacao} != "" ]] && break
echo -e "$(fun_trans "Opsi salah")"
done
install_all
fi
return 0
}
fun_shadowsocks