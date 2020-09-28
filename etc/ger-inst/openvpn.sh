#!/bin/bash
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
agrega_dns () {
msg -ama " $(fun_trans "Masukkan DNS HOST yang ingin Anda tambahkan")"
read -p " [NewDNS]: " SDNS
cat /etc/hosts|grep -v "$SDNS" > /etc/hosts.bak && mv -f /etc/hosts.bak /etc/hosts
if [[ -e /etc/opendns ]]; then
cat /etc/opendns > /tmp/opnbak
mv -f /tmp/opnbak /etc/opendns
echo "$SDNS" >> /etc/opendns 
else
echo "$SDNS" > /etc/opendns
fi
[[ -z $NEWDNS ]] && NEWDNS="$SDNS" || NEWDNS="$NEWDNS $SDNS"
unset SDNS
}
mportas () {
unset portas
portas_var=$(lsof -V -i -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
dns_fun () {
case $1 in
3)dns[$2]='push "dhcp-option DNS 1.0.0.1"';;
4)dns[$2]='push "dhcp-option DNS 1.1.1.1"';;
5)dns[$2]='push "dhcp-option DNS 9.9.9.9"';;
6)dns[$2]='push "dhcp-option DNS 1.1.1.1"';;
7)dns[$2]='push "dhcp-option DNS 80.67.169.40"';;
8)dns[$2]='push "dhcp-option DNS 80.67.169.12"';;
9)dns[$2]='push "dhcp-option DNS 84.200.69.80"';;
10)dns[$2]='push "dhcp-option DNS 84.200.70.40"';;
11)dns[$2]='push "dhcp-option DNS 208.67.222.222"';;
12)dns[$2]='push "dhcp-option DNS 208.67.220.220"';;
13)dns[$2]='push "dhcp-option DNS 8.8.8.8"';;
14)dns[$2]='push "dhcp-option DNS 8.8.4.4"';;
15)dns[$2]='push "dhcp-option DNS 77.88.8.8"';;
16)dns[$2]='push "dhcp-option DNS 77.88.8.1"';;
17)dns[$2]='push "dhcp-option DNS 176.103.130.130"';;
18)dns[$2]='push "dhcp-option DNS 176.103.130.131"';;
esac
}
meu_ip () {
if [[ -e /etc/MEUIPADM ]]; then
echo "$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}
IP="$(meu_ip)"
instala_ovpn () {
parametros_iniciais () {
#Verifica o Sistema
[[ "$EUID" -ne 0 ]] && echo " Maaf, Anda perlu menjalankan ini sebagai root" && exit 1
[[ ! -e /dev/net/tun ]] && echo " TUN tidak tersedia" && exit 1
if [[ -e /etc/debian_version ]]; then
OS="debian"
VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
IPTABLES='/etc/iptables/iptables.rules'
[[ ! -d /etc/iptables ]] && mkdir /etc/iptables
[[ ! -e $IPTABLES ]] && touch $IPTABLES
SYSCTL='/etc/sysctl.conf'
 [[ "$VERSION_ID" != 'VERSION_ID="7"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="8"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="9"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="14.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="16.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="17.10"' ]] && {
 echo " Versi Debian / Ubuntu Anda tidak didukung."
 while [[ $CONTINUE != @(y|Y|s|S|n|N) ]]; do
 read -p "Lanjutkan ? [y/n]: " -e CONTINUE
 done
 [[ "$CONTINUE" = @(n|N) ]] && exit 1
 }
else
msg -ama " $(fun_trans "Sepertinya Anda tidak menjalankan penginstal ini pada sistem Debian atau Ubuntu")"
msg -bar
return 1
fi
#Pega Interface
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
}
add_repo () {
#INSTALACAO E UPDATE DO REPOSITORIO
# Debian 7
if [[ "$VERSION_ID" = 'VERSION_ID="7"' ]]; then
echo "deb http://build.openvpn.net/debian/openvpn/stable wheezy main" > /etc/apt/sources.list.d/openvpn.list
wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
# Debian 8
elif [[ "$VERSION_ID" = 'VERSION_ID="8"' ]]; then
echo "deb http://build.openvpn.net/debian/openvpn/stable jessie main" > /etc/apt/sources.list.d/openvpn.list
wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
# Ubuntu 14.04
elif [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
echo "deb http://build.openvpn.net/debian/openvpn/stable trusty main" > /etc/apt/sources.list.d/openvpn.list
wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
fi
}
coleta_variaveis () {
echo -e "\033[1;32m $(fun_trans "Tool Instalasi OPENVPN*")cr4r-server"
msg -bar
msg -ne " $(fun_trans "Apakah sudah benar, Konfirmasikan ip")"; read -p ": " -e -i $IP ip
msg -bar
msg -ama " $(fun_trans "Masukkan port untuk openvpn?")"
msg -bar
    while true; do
    read -p " Port: " -e -i 1194 PORT
    [[ $(mportas|grep -w "$PORT") ]] || break
    echo -e "\033[1;33m $(fun_trans "Port ini sudah di gunakana")\033[0m"
    unset PORT
    done
msg -bar
echo -e "\033[1;31m $(fun_trans "Pilih protokol untuk koneksi OPENVPN?")"
echo -e "\033[1;31m $(fun_trans "Menggunakan TCP (lebih lambat)")"
#PROTOCOLO
while [[ $PROTOCOL != @(UDP|TCP) ]]; do
read -p " Protocol [UDP/TCP]: " -e -i TCP PROTOCOL
done
[[ $PROTOCOL = "UDP" ]] && PROTOCOL=udp
[[ $PROTOCOL = "TCP" ]] && PROTOCOL=tcp
#DNS
msg -bar
msg -ama " $(fun_trans "Pilih DNS yang ingin Anda gunakan?")"
msg -bar
echo "   1) Usar DNS do sistema "
echo "   2) Cloudflare"
echo "   3) Quad"
echo "   4) FDN"
echo "   5) DNS.WATCH"
echo "   6) OpenDNS"
echo "   7) Google DNS"
echo "   8) Yandex Basic"
echo "   9) AdGuard DNS"
while [[ $DNS != @([1-9]) ]]; do
read -p " DNS [1-9]: " -e DNS
done
#CIPHER
msg -bar
msg -ama " $(fun_trans "Pilih chiper yang ingin Anda gunakan untuk saluran data:")"
msg -bar
echo "   1) AES-128-CBC"
echo "   2) AES-192-CBC"
echo "   3) AES-256-CBC"
echo "   4) CAMELLIA-128-CBC"
echo "   5) CAMELLIA-192-CBC"
echo "   6) CAMELLIA-256-CBC"
echo "   7) SEED-CBC"
while [[ $CIPHER != @([1-7]) ]]; do
read -p " Cipher [1-7]: " -e CIPHER
done
case $CIPHER in
1) CIPHER="cipher AES-128-CBC";;
2) CIPHER="cipher AES-192-CBC";;
3) CIPHER="cipher AES-256-CBC";;
4) CIPHER="cipher CAMELLIA-128-CBC";;
5) CIPHER="cipher CAMELLIA-192-CBC";;
6) CIPHER="cipher CAMELLIA-256-CBC";;
7) CIPHER="cipher SEED-CBC";;
esac
msg -bar
msg -ama " $(fun_trans "Silahkan tunggu, konfigurasi OpenVPN dimulai!")"
msg -bar
read -n1 -r -p " Enter to Lanjutkan..."
tput cuu1 && tput dl1
}
parametros_iniciais # PERIKSA SINGKAT
coleta_variaveis #MENGUMPULKAN VARIABEL UNTUK INSTALASI
add_repo # MEMPERBARUI REPOSITORI OPENVPN DAN MEMASANG OPENVPN
# Cria Diretorio
[[ ! -d /etc/openvpn ]] && mkdir /etc/openvpn
# Install openvpn
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -q > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [Gagal]"
echo -ne " \033[1;31m[ ! ] apt-get install openvpn curl openssl"
apt-get install -qy openvpn curl > /dev/null 2>&1 && apt-get install openssl -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [Gagal]"
SERVER_IP="$(meu_ip)" # IP Address
[[ -z "${SERVER_IP}" ]] && SERVER_IP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
echo -ne " \033[1;31m[ ! ] Generating Server Config" # Gerando server.con
(
case $DNS in
1)
i=0
grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
dns[$i]="push \"dhcp-option DNS $line\""
done
[[ ! "${dns[@]}" ]] && dns[0]='push "dhcp-option DNS 8.8.8.8"' && dns[1]='push "dhcp-option DNS 8.8.4.4"'
;;
2)dns_fun 3 && dns_fun 4;;
3)dns_fun 5 && dns_fun 6;;
4)dns_fun 7 && dns_fun 8;;
5)dns_fun 9 && dns_fun 10;;
6)dns_fun 11 && dns_fun 12;;
7)dns_fun 13 && dns_fun 14;;
8)dns_fun 15 && dns_fun 16;;
9)dns_fun 17 && dns_fun 18;;
esac
echo 01 > /etc/openvpn/ca.srl
while [[ ! -e /etc/openvpn/dh.pem || -z $(cat /etc/openvpn/dh.pem) ]]; do
echo """-----BEGIN DH PARAMETERS-----
MIICCAKCAgEA2l9FRgeStyDVtEWPv+W4DowNFnSWG9QeVHa3daocKl13UeI9cCT/
ubXaH42J2YvmNNpICg/o4j9hHa3O1mrtTogdYbGtx3HN61kPIdpeo0Lc9Tq4oigX
gqGdoye6pUXkvwquaCriLaILKgHL3pg7qaHAh7XxLjeSi8M59qxtDDqeKgK/rLgc
7wWVE2TfV1F38x8+gAho4l08oEtdVCQOITOf3I+GimXWcF8yHw9dpnwdtcX9RHGz
UdjRmRygAU6db7I4edFtmoe6fKlktnwb5ERmbvAeZnXZqAKy8V66PuQjQTza8uzU
CkldaoEnjwxk4o/KqgoiCI6SKBz3cnbbNBHDLZd1yz/EhCDU8Ol+kPjVNRcInsEa
ZnnbRsugPaj9qw5i7116EB9sdO+U5YZz1YfpL162nDh1bTVzLTvOZ3DDL3xxHfH0
cxqG2rZOF3mBM9zy0iJNcW76C1ZQSoNpPft50afuiiqruw0H7gKj6Vm5cg1fN8rO
BQXKD2t28tYjO4i24kJZAWMWstIkrXL6MCz/DjiEdvo/Jy0GCYC21LGbfr3a8hyC
U2j7aA1nypl94UulAjBUQbDtcm86FoX5y9fFT15elH4wZXGMgjM69LSkbmyAIPoY
SrcFe2DENO1cio/cpABv1CCpB1XSO9KsUXrTSuqJPXzQDhCzwuuTC1sCAQI=
-----END DH PARAMETERS-----""">/etc/openvpn/dh.pem
#openssl dhparam -out /etc/openvpn/dh.pem 4096 &>/dev/null
done
while [[ ! -e /etc/openvpn/ca-key.pem || -z $(cat /etc/openvpn/ca-key.pem) ]]; do
openssl genrsa -out /etc/openvpn/ca-key.pem 4096 &>/dev/null
done
chmod 600 /etc/openvpn/ca-key.pem &>/dev/null
while [[ ! -e /etc/openvpn/ca-csr.pem || -z $(cat /etc/openvpn/ca-csr.pem) ]]; do
openssl req -new -key /etc/openvpn/ca-key.pem -out /etc/openvpn/ca-csr.pem -subj /C=US/ST=New\ York/L=New\ York\ City/O=CR4R/OU=CyberSecurity/CN=CR4R\ Server &>/dev/null
done
while [[ ! -e /etc/openvpn/ca.pem || -z $(cat /etc/openvpn/ca.pem) ]]; do
openssl x509 -req -in /etc/openvpn/ca-csr.pem -out /etc/openvpn/ca.pem -signkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
done
while [[ ! -e /etc/openvpn/ta.key || -z $(cat /etc/openvpn/ta.key) ]]; do
openvpn --genkey --secret /etc/openvpn/ta.key
done

cat > /etc/openvpn/server.conf <<EOF
server 10.8.0.0 255.255.255.0
verb 3
duplicate-cn
key client-key.pem
ca ca.pem
cert client-cert.pem
dh dh.pem
keepalive 10 120
persist-key
persist-tun
comp-lzo
float
push "redirect-gateway def1 bypass-dhcp"
${dns[0]}
${dns[1]}

user nobody
group nogroup

${CIPHER}
proto ${PROTOCOL}
port $PORT
dev tun
status openvpn-status.log
EOF
updatedb
PLUGIN=$(locate openvpn-plugin-auth-pam.so | head -1)
[[ ! -z $(echo ${PLUGIN}) ]] && {
echo "client-to-client
client-cert-not-required
username-as-common-name
plugin $PLUGIN login" >> /etc/openvpn/server.conf
}
) && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [Gagal]"
echo -ne " \033[1;31m[ ! ] Generating CA Config" # Generate CA Config
(
while [[ ! -e /etc/openvpn/client-key.pem || -z $(cat /etc/openvpn/client-key.pem) ]]; do
openssl genrsa -out /etc/openvpn/client-key.pem 4096 &>/dev/null
done
chmod 600 /etc/openvpn/client-key.pem
while [[ ! -e /etc/openvpn/client-csr.pem || -z $(cat /etc/openvpn/client-csr.pem) ]]; do
openssl req -new -key /etc/openvpn/client-key.pem -out /etc/openvpn/client-csr.pem -subj /C=US/ST=New\ York/L=New\ York\ City/O=CR4R/OU=CyberSecurity/CN=CR4R\ Client &>/dev/null
done
while [[ ! -e /etc/openvpn/client-cert.pem || -z $(cat /etc/openvpn/client-cert.pem) ]]; do
openssl x509 -req -in /etc/openvpn/client-csr.pem -out /etc/openvpn/client-cert.pem -CA /etc/openvpn/ca.pem -CAkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
done
) && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [Gagal]"
teste_porta () {
  echo -ne " \033[1;31m$(fun_trans ${id} "Verifikasi..."):"

  
  sleep 1s
  [[ ! $(mportas | grep "$1") ]] && {
    echo -e "\033[1;33m [Gagal]\033[0m"
    } || {
    echo -e "\033[1;32m [Pass]\033[0m"
    return 1
    }
   }
msg -bar
echo -e "\033[1;33m $(fun_trans ${id} "Kita membutuhkan port squid atau port lainnya")(Socks)"
echo -e "\033[1;33m $(fun_trans ${id} "Jika tidak ada Proxy di Port, Proxy Python akan dibuka!")"
msg -bar
while [[ $? != "1" ]]; do
read -p " Masukkan (Proxy): " -e PPROXY
teste_porta $PPROXY
done
cat > /etc/openvpn/client-common.txt <<EOF
# OVPN_ACCESS_SERVER_PROFILE=cr4r.me
client
nobind
dev tun
redirect-gateway def1 bypass-dhcp
remote-random
remote ${SERVER_IP} ${PORT} ${PROTOCOL}
#http-proxy ${SERVER_IP} ${PPROXY}
$CIPHER
comp-lzo yes
keepalive 10 20
float
auth-user-pass
EOF
# Iptables
if [[ ! -f /proc/user_beancounters ]]; then
    INTIP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
    N_INT=$(ip a |awk -v sip="$INTIP" '$0 ~ sip { print $7}')
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $N_INT -j MASQUERADE
else
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source $SERVER_IP
fi
iptables-save > /etc/iptables.conf
cat > /etc/network/if-up.d/iptables <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.conf
EOF
chmod +x /etc/network/if-up.d/iptables
# Enable net.ipv4.ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
# Regras de Firewall 
if pgrep firewalld; then
 if [[ "$PROTOCOL" = 'udp' ]]; then
 firewall-cmd --zone=public --add-port=$PORT/udp
 firewall-cmd --permanent --zone=public --add-port=$PORT/udp
 elif [[ "$PROTOCOL" = 'tcp' ]]; then
 firewall-cmd --zone=public --add-port=$PORT/tcp
 firewall-cmd --permanent --zone=public --add-port=$PORT/tcp
 fi
firewall-cmd --zone=trusted --add-source=10.8.0.0/24
firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
fi
if iptables -L -n | grep -qE 'REJECT|DROP'; then
 if [[ "$PROTOCOL" = 'udp' ]]; then
 iptables -I INPUT -p udp --dport $PORT -j ACCEPT
 elif [[ "$PROTOCOL" = 'tcp' ]]; then
 iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
 fi
iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables-save > $IPTABLES
fi
if hash sestatus 2>/dev/null; then
 if sestatus | grep "Current mode" | grep -qs "enforcing"; then
  if [[ "$PORT" != '1194' ]]; then
   if ! hash semanage 2>/dev/null; then
   yum install policycoreutils-python -y
   fi
   if [[ "$PROTOCOL" = 'udp' ]]; then
   semanage port -a -t openvpn_port_t -p udp $PORT
   elif [[ "$PROTOCOL" = 'tcp' ]]; then
   semanage port -a -t openvpn_port_t -p tcp $PORT
   fi
  fi
 fi
fi
#Liberando DNS
msg -bar
msg -ama " $(fun_trans "Tahap Terakhir, Pengaturan DNS")"
msg -bar
while [[ $DDNS != @(n|N) ]]; do
echo -ne "\033[1;33m"
read -p " Tambahkan HOST DNS [S/N]: " -e -i n DDNS
[[ $DDNS = @(s|S|y|Y) ]] && agrega_dns
done
[[ ! -z $NEWDNS ]] && {
sed -i "/127.0.0.1[[:blank:]]\+localhost/a 127.0.0.1 $NEWDNS" /etc/hosts
for DENESI in $(echo $NEWDNS); do
sed -i "/remote ${SERVER_IP} ${PORT} ${PROTOCOL}/a remote ${DENESI} ${PORT} ${PROTOCOL}" /etc/openvpn/client-common.txt
done
}
msg -bar
# REINICIANDO OPENVPN
if [[ "$OS" = 'debian' ]]; then
 if pgrep systemd-journal; then
 sed -i 's|LimitNPROC|#LimitNPROC|' /lib/systemd/system/openvpn\@.service
 sed -i 's|/etc/openvpn/server|/etc/openvpn|' /lib/systemd/system/openvpn\@.service
 sed -i 's|%i.conf|server.conf|' /lib/systemd/system/openvpn\@.service
 #systemctl daemon-reload
 (
 systemctl restart openvpn
 systemctl enable openvpn
 ) > /dev/null 2>&1
 else
 /etc/init.d/openvpn restart > /dev/null 2>&1
 fi
else
 if pgrep systemd-journal; then
 (
 systemctl restart openvpn@server.service
 systemctl enable openvpn@server.service
 ) > /dev/null 2>&1
 else
 (
 service openvpn restart
 chkconfig openvpn on
 ) > /dev/null 2>&1
 fi
fi
service squid restart &>/dev/null
service squid3 restart &>/dev/null
apt-get install ufw -y > /dev/null 2>&1
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
#Restart OPENVPN
(
killall openvpn 2>/dev/null
systemctl stop openvpn@server.service > /dev/null 2>&1
service openvpn stop > /dev/null 2>&1
sleep 0.1s
cd /etc/openvpn > /dev/null 2>&1
screen -dmS ovpnscr openvpn --config "server.conf" > /dev/null 2>&1
) > /dev/null 2>&1
msg -ama " $(fun_trans "Konfigurasi Openvpn Sukses!")"
msg -ama " $(fun_trans "Sekarang buatlah user di menu awal!")"
msg -bar
return 0
}
edit_ovpn_host () {
msg -ama " $(fun_trans "Konfigurasi HOST DNS OPENVPN")"
msg -bar
while [[ $DDNS != @(n|N) ]]; do
echo -ne "\033[1;33m"
read -p " Add host [S/N]: " -e -i n DDNS
[[ $DDNS = @(s|S|y|Y) ]] && agrega_dns
done
[[ ! -z $NEWDNS ]] && sed -i "/127.0.0.1[[:blank:]]\+localhost/a 127.0.0.1 $NEWDNS" /etc/hosts
msg -bar
msg -ama " $(fun_trans "Untuk Pengaturan Yang Efektif,Server Diperlukan Reboot")"
msg -bar
}
fun_openvpn () {
[[ -e /etc/openvpn/server.conf ]] && {
unset OPENBAR
[[ $(mportas|grep -w "openvpn") ]] && OPENBAR="\033[1;32mOnline" || OPENBAR="\033[1;31mOffline"
msg -ama " $(fun_trans "OPENVPN SUDAH TERINSTAL*")"
msg -bar
echo -e "\033[1;32m [0] >\033[1;37m $(fun_trans "Kembali")"
echo -e "\033[1;32m [1] >\033[1;36m $(fun_trans "Hapus OPEN_VPN")"
echo -e "\033[1;32m [2] >\033[1;36m $(fun_trans "Edit Client OPEN_VPN") \033[1;31m(comand nano)"
echo -e "\033[1;32m [3] >\033[1;36m $(fun_trans "Tambahkan Hosts OPEN_VPN")"
echo -e "\033[1;32m [4] >\033[1;36m $(fun_trans "Mulai atau Berhenti OPEN_VPN") $OPENBAR"
msg -bar
while [[ $xption != @([0|1|2|3|4]) ]]; do
echo -ne "\033[1;33m $(fun_trans "Opcao"): " && read xption
tput cuu1 && tput dl1
done
case $xption in 
1)
msg -ama " $(fun_trans "Penghapusan OPENVPN*")"
msg -bar   
   (
   killall openvpn 2>/dev/null
   systemctl stop openvpn@server.service >/dev/null 2>&1 & 
   service openvpn stop > /dev/null 2>&1
   systemctl disable openvpn
   ) > /dev/null 2>&1
   if [[ "$OS" = 'debian' ]]; then
   fun_bar "apt-get remove --purge -y openvpn*"
   else
   fun_bar "yum remove openvpn -y"
   fi
   tuns=$(cat /etc/modules | grep -v tun) && echo -e "$tuns" > /etc/modules
   rm -rf /etc/openvpn && rm -rf /usr/share/doc/openvpn*
   rm -rf $(whereis openvpn)
   msg -bar
   msg -ama " $(fun_trans "Penghapusan Selesai!")"
   msg -bar
   return 0;;
 2)
   nano /etc/openvpn/client-common.txt
   return 0;;
 3)edit_ovpn_host;;
 4)
   [[ $(mportas|grep -w openvpn) ]] && {
   /etc/init.d/openvpn stop > /dev/null 2>&1
   killall openvpn &>/dev/null
   systemctl stop openvpn@server.service &>/dev/null
   service openvpn stop &>/dev/null
   #ps x |grep openvpn |grep -v grep|awk '{print $1}' | while read pid; do kill -9 $pid; done
   } || {
   cd /etc/openvpn
   screen -dmS ovpnscr openvpn --config "server.conf" > /dev/null 2>&1
   cd $HOME
   }
   msg -ama " $(fun_trans "Sukses")"
   msg -bar
   return 0;; 
 0)
   return 0;;
 esac
 exit
 }
[[ -e /etc/squid/squid.conf ]] && instala_ovpn && return 0
[[ -e /etc/squid3/squid.conf ]] && instala_ovpn && return 0
msg -bar
msg -ama " $(fun_trans "Squid Tidak Ditemukan")"
msg -ama " $(fun_trans "Lanjutkan Dengan Instalasi?")"
msg -bar
read -p " [S/N]: " -e -i n instnosquid && [[ $instnosquid = @(s|S|y|Y) ]] && instala_ovpn || return 1
}
no_port () {
if [[ ! -e /etc/openvpn/server.conf ]]; then
msg -ama " $(fun_trans "Sebelum menginstal openvpn Instal Squid")"
msg -ama " $(fun_trans "atau buka proxy So_ck")"
msg -bar
exit 1
fi
instala_ovpn
}
[[ -z $(mportas|grep squid) ]] && [[ -z $(mportas|grep python) ]] && no_port
fun_openvpn