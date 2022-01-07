#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/cr4r" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPbahasa="${SCPdir}/bahasa" && [[ ! -e ${SCPbahasa} ]] && touch ${SCPbahasa}
BadVPN () {
pid_badvpn=$(ps x | grep badvpn | grep -v grep | awk '{print $1}')
if [ "$pid_badvpn" = "" ]; then
    msg -ama "$(fun_trans "Menghentikan Badvpn")"
    msg -bar
    fun_bar "sleep 1s"
    msg -bar
    if [[ ! -e /bin/badvpn-udpgw ]]; then
    wget -O /bin/badvpn-udpgw https://raw.githubusercontent.com/cr4r/ssh/main/Install/badvpn-udpgw &>/dev/null
    chmod 777 /bin/badvpn-udpgw
    fi
    screen -dmS screen /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
    [[ "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ama "$(fun_trans "Prosedur Sukses Selesai")" || msg -ama "$(fun_trans "Gagal")"
    msg -bar
else
    msg -ama "$(fun_trans "Menghentikan badvpn")"
    msg -bar
    fun_bar "sleep 1s"
    msg -bar
    kill -9 $(ps x | grep badvpn | grep -v grep | awk '{print $1'}) > /dev/null 2>&1
    killall badvpn-udpgw > /dev/null 2>&1
    [[ ! "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ama "$(fun_trans "Sukses")" || msg -ama "$(fun_trans "Gagal")"
    unset pid_badvpn
    msg -bar
    fi
unset pid_badvpn
}
BadVPN