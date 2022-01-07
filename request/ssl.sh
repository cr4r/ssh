#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/cr4r" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/bahasa" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
API_TRANS="aHR0cDovL2dpdC5pby90cmFucw=="
SUB_DOM='base64 -d'
wget -O /usr/bin/trans $(echo $API_TRANS|$SUB_DOM) &> /dev/null

mport () {
unset port
port_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $port|grep "$var1 $var2")" ]] || port+="$var1 $var2\n"
done <<< "$port_var"
i=1
echo -e "$port"
}

ssl_stunel () {
[[ $(mport|grep stunnel4|head -1) ]] && {
msg -ama " $(fun_trans "Menghapus Stunnel")"
msg -bar
fun_bar "apt-get purge stunnel4 -y"
msg -bar
msg -ama " $(fun_trans "Berhasil dihapus!")"
rm -rf /etc/stunnel/stunnel.conf > /dev/null 2>&1
rm -rf /etc/stunnel > /dev/null 2>&1
msg -bar
return 0
}
msg -azu " $(fun_trans "SSL Stunnel")"
msg -bar
msg -ama " $(fun_trans "Pilih Port Internal")"
msg -ama " $(fun_trans "Port untuk SSH (ex:22)")"
msg -bar
         while true; do
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
            [[ $(mport|grep -w "$portx") ]] && break || echo -e "\033[1;31m $(fun_trans "Port Salah")\033[0m"
         fi
         done
msg -bar
DPORT="$(mport|grep $portx|awk '{print $2}'|head -1)"
msg -ama " $(fun_trans "Port untuk SSL (ex:443)")"
msg -bar
    while true; do
    read -p " Listen-SSL: " SSLPORT
    [[ $(mport|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m $(fun_trans "Port ini sudah digunakan")\033[0m"
    unset SSLPORT
    done
msg -bar
msg -ama " $(fun_trans "Menginstall SSL dimulai")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n\n[stunnel]\nconnect = 127.0.0.1:${DPORT}\naccept = ${SSLPORT}" > /etc/stunnel/stunnel.conf
openssl genrsa -out key.pem 2048 > /dev/null 2>&1
(echo br; echo br; echo uss; echo speed; echo cr4r; echo cr4r; echo @codersfamily)|openssl req -new -x509 -key key.pem -out cert.pem -days 1095 > /dev/null 2>&1
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
/etc/init.d/stunnel4 restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "Instalasi Sukses")"
msg -bar
return 0
}

ssl_greport () {
if [[ ! -e /etc/stunnel/stunnel.conf ]]; then
msg -ama " $(fun_trans "Stunnel Tidak Ditemukan")"
msg -bar
exit 1
fi
msg -azu " $(fun_trans "SSL Stunnel")"
msg -bar
msg -ama " $(fun_trans "Pilih Port Internal")"
msg -ama " $(fun_trans "Yaitu, Port di Server Anda untuk SSL")"
msg -bar
         while true; do
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
            [[ $(mport|grep -w "$portx") ]] && break || echo -e "\033[1;31m $(fun_trans "Port Salah")\033[0m"
         fi
         done
msg -bar
msg -ama " $(fun_trans "Agora Presizamos Saber Qual Port o SSL, Vai Escutar")"
msg -bar
    while true; do
    read -p " Puerto SSL: " SSLPORTr
    [[ $(mport|grep -w "$SSLPORTr") ]] || break
    msg -bar
    echo -e "$(fun_trans "port ini sudah digunakan")"
    msg -bar
    unset SSLPORT1
    done
msg -bar
fun_bar "sleep 3s"
echo "" >> /etc/stunnel/stunnel.conf
echo "[stunnel]" >> /etc/stunnel/stunnel.conf
echo "connect = 127.0.0.1:${portx}" >> /etc/stunnel/stunnel.conf
echo "accept = ${SSLPORTr}" >> /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
/etc/init.d/stunnel4 restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "Stunnel sudah di seting")"
msg -bar
}

fun_ssl () {
msg -ama " $(fun_trans "KONFIGURASI STUNNEL SSL*")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Kembali")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "tambahkan port ")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "Edit Stunnel Klien SSL") \033[1;31m(perintah nano)"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Hapus SSL Stunnel ")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-3]) ]]; do
read -p "[0-3]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)ssl_greport;;
2)
   nano /etc/stunnel/stunnel.conf
   return 0;;
3)ssl_stunel;;
esac
}
if [[ -e /etc/stunnel/stunnel.conf ]]; then
fun_ssl
else
ssl_stunel
fi