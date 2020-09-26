#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
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
[[ -e /etc/shadowsocks.json ]] && {
[[ $(ps x|grep ss-server|awk '{print $1}') != "" ]] && kill -9 $(ps x|grep ss-server|awk '{print $1}') > /dev/null 2>&1 && service shadowsocks-libev stop > /dev/null 2>&1
msg -ama " $(fun_trans "SHADOWSOCKS DIHENTIKAN")"
msg -bar
rm /etc/shadowsocks.json
return 0
}
       echo -e "\033[1;32m $(fun_trans "Instalasi SHADOWSOCKS*") by-cr4r"
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
       echo -ne " $(fun_trans "Enkripsi yang mana")? $(fun_trans "Pilih apa"): "; read -e cript
       [[ ${encript[$cript]} ]] && break
       echo -e "$(fun_trans "Opsi salah")"
       done
       encriptacao="${encript[$cript]}"
       [[ ${encriptacao} != "" ]] && break
       echo -e "$(fun_trans "Opsi salah")"
      done
#ESCOLHENDO LISTEN
      msg -bar
      msg -ama " $(fun_trans "Ketik port untuk dibuka di shadowsocks")"
      msg -bar
      while true; do
      unset Lport
      read -p " Listen Port: " Lport
      [[ $(mportas|grep "$Lport") = "" ]] && break
      echo -e " ${Lport}: $(fun_trans "Port salah")"      
      done
#INICIANDO
msg -bar
msg -ama " $(fun_trans "Masukkan Password Shadowsocks")"
read -p" Pass: " Pass
msg -bar
msg -ama " $(fun_trans "Sedang menginstall..")"
msg -bar
fun_bar 'apt-get install python3 python3-pip -y'
fun_bar 'apt install shadowsocks-libev -y'
fun_bar 'mkdir -p /etc/shadowsocks-libev/'
fun_bar 'rm /etc/shadowsocks-libev/config.json'
echo -ne '{\n"server":"' > /etc/shadowsocks-libev/shadowsocks.json
echo -ne "0.0.0.0" >> /etc/shadowsocks-libev/shadowsocks.json
echo -ne '",\n"server_port":' >> /etc/shadowsocks-libev/shadowsocks.json
echo -ne "${Lport},\n" >> /etc/shadowsocks-libev/shadowsocks.json
echo -ne '"local_port":1080,\n"password":"' >> /etc/shadowsocks-libev/shadowsocks.json
echo -ne "${Pass}" >> /etc/shadowsocks-libev/shadowsocks.json
echo -ne '",\n"timeout":60,\n"method":"' >> /etc/shadowsocks-libev/shadowsocks.json
echo -ne "${encriptacao}\"" >> /etc/shadowsocks-libev/shadowsocks.json
echo -ne "\n}" >> /etc/shadowsocks-libev/shadowsocks.json
msg -bar
msg -ama " STARTING\033[0m"
systemctl start shadowsocks-libev > /dev/null 2>&1
value=$(service shadowsocks-libev status | grep active)
[[ $value != "" ]] && value="\033[1;32mactive" || value="\033[1;31minactive"
msg -bar
msg -ama "Shadowsocks ${value} "
msg -bar
return 0
}
fun_shadowsocks