#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

GENERADOR_BIN () {
wget -O /etc/ger-frm/GENERADOR_BIN.sh https://github.com/cr4r1/ssh/raw/master/instal/GENERADOR_BIN.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/GENERADOR_BIN.sh
fun_bar "chmod -R 777 /etc/ger-frm/GENERADOR_BIN.sh"
chmod -R 777 /etc/ger-frm/GENERADOR_BIN.sh > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]} Menu alat"
return
}

MasterBin () {
wget -O /etc/ger-frm/MasterBin.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/MasterBin.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/MasterBin.sh
fun_bar "chmod -R 777 /etc/ger-frm/MasterBin.sh"
chmod -R 777 /etc/ger-frm/MasterBin.sh > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

real-host () {
wget -O /etc/ger-frm/real-host.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/real-host.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/real-host.sh
fun_bar "chmod -R 777 /etc/ger-frm/real-host.sh"
chmod -R 777 /etc/ger-frm/real-host.sh > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

dados () {
wget -O /etc/ger-frm/dados.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/dados.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/dados.sh
fun_bar "chmod -R 777 /etc/ger-frm/dados.sh"
chmod -R 777 /etc/ger-frm/dados.sh > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

squidpass () {
wget -O /etc/ger-frm/squidpass.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/squidpass.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/squidpass.sh
fun_bar "chmod -R 777 /etc/ger-frm/squidpass.sh"
chmod -R 777 /etc/ger-frm/squidpass.sh > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

vnc () {
wget -O /etc/ger-frm/vnc.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/vnc.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/vnc.sh
fun_bar "chmod -R 777 /etc/ger-frm/vnc.sh"
chmod -R 777 /etc/ger-frm/vnc.sh > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

#MENU 2 HERRAMIENTAS
mas_tools () {
fai2ban () {
wget -O /etc/ger-frm/MasterBin.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/fai2ban.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/fai2ban.sh
fun_bar "chmod -R 777 /etc/ger-frm/fai2ban.sh"
chmod -R 777 /etc/ger-frm/fai2ban.sh > /dev/null 2>&1
msg -bar
echo -e "${cor[3]} Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

paysnd () {
wget -O /etc/ger-frm/dados.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/paysnd.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/paysnd.sh
fun_bar "chmod -R 777 /etc/ger-frm/paysnd.sh"
chmod -R 777 /etc/ger-frm/paysnd.sh > /dev/null 2>&1
msg -bar
echo -e "${cor[3]} Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

ddos () {
wget -O /etc/ger-frm/ddos.sh https://raw.githubusercontent.com/cr4r1/ssh/master/instal/ddos.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/ddos.sh
fun_bar "chmod -R 777 /etc/ger-frm/ddos.sh"
chmod -R 777 /etc/ger-frm/ddos.sh > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

torrent () {
wget -O /etc/ger-frm/torrent https://raw.githubusercontent.com/cr4r1/ssh/master/instal/torrent > /dev/null 2>&1; chmod +x /etc/ger-frm/torrent
fun_bar "chmod -R 777 /etc/ger-frm/torrent"
chmod -R 777 /etc/ger-frm/torrent > /dev/null 2>&1
msg -bar
msg -ama "Sukses Mendownload di: ${cor[2]}Menu alat"
return
}

msg -ama "$(fun_trans "TOOLS DOWNLOAD MANAGER 2") ${cor[4]}"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "KEMBALI")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "PROTEKSI FAIL2BAN")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "BRUTO FORCE PAYLOAD DENGAN BASH ")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "BRUTO FORCE PAYLOAD DENGAN PYTHON")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "ANTI DDOS")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "BLOKIR TORRENT")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-7]) ]]; do
read -p "[0-7]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)fai2ban;;
2)paysnd;;
3)payySND;;
4)ddos;;
5)torrent;;
6)exit;;
7)exit;;
esac
}

msg -ama "$(fun_trans "TOOLS DOWNLOAD MANAGER") ${cor[4]}[NEW-ADM]"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "KEMBALI")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "GENERATE BIN")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "KONSULTASI BIN")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "EXTRACT HOST")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "MONITOR KONSUMSI")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "PROTEKSI SQUID")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "VNC SERVER")"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "LEBIH BANYAK ALAT")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-7]) ]]; do
read -p "[0-7]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)GENERADOR_BIN;;
2)MasterBin;;
3)real-host;;
4)dados;;
5)squidpass;;
6)vnc;;
7)mas_tools;;
esac
msg -bar