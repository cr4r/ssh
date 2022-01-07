#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/cr4r" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/bahasa" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_bar () {
    comando[0]="$1"
    comando[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${comando[0]} -y > /dev/null 2>&1
        ${comando[1]} -y > /dev/null 2>&1
        touch $HOME/fim
    ) > /dev/null 2>&1 &
    echo -ne "\033[1;33m ["
    while true; do
        for((i=0; i<10; i++)); do
            echo -ne "\033[1;31m##"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[1;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "\033[1;33m ["
    done
    echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
}

verif_ptrs() {
    porta=$1
    PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
    for pton in $(echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq); do
        svcs=$(echo -e "$PT" | grep -w "$pton" | awk '{print $1}' | uniq)
        [[ "$porta" = "$pton" ]] && {
            msg -bar
            echo -e "\033[1;31mPORT \033[1;32m$porta \033[1;31mDIGUNAKAN OLEH \033[1;37m$svcs\033[0m"
            msg -bar
            msg -ne "$(fun_trans "Enter Untuk Melanjutkan")" && read enter
            ${SCPdir}/menu
        }
    done
}
x="ok"

fun_sslh() {
    [[ "$(netstat -nltp | grep 'sslh' | wc -l)" = '0' ]] && {
        msg -azu " $(fun_trans "PEMASANGAN MULTIPLEX SSLH")"
        msg -bar
        msg -ama " $(fun_trans "Port 443 akan digunakan secara default")"
        ## msg -ama " $(fun_trans "A Porta 3128 Sera Usada Por Padrao")"
        msg -bar
        echo -ne " Sudah Siap untuk Instal SSLH [s/n]: "
        read resp
        [[ "$resp" = 's' ]] && {
            verif_ptrs 443
            ## verif_ptrs 3128
            fun_instsslh() {
                [[ -e "/etc/stunnel/stunnel.conf" ]] && ptssl="$(netstat -nplt | grep 'stunnel' | awk {'print $4'} | cut -d: -f2 | xargs)" || ptssl='3128'
                [[ -e "/etc/openvpn/server.conf" ]] && ptvpn="$(netstat -nplt | grep 'openvpn' | awk {'print $4'} | cut -d: -f2 | xargs)" || ptvpn='1194'
                DEBIAN_FRONTEND=noninteractive apt-get -y install sslh
                echo -e "#Modo autónomo\n\nRUN=yes\n\nDAEMON=/usr/sbin/sslh\n\nDAEMON_OPTS='--user sslh --listen 0.0.0.0:443 --ssh 127.0.0.1:22 --ssl 127.0.0.1:$ptssl --http 127.0.0.1:80 --openvpn 127.0.0.1:$ptvpn --pidfile /var/run/sslh/sslh.pid'" >/etc/default/sslh
                ## echo -e "#Modo autónomo\n\nRUN=yes\n\nDAEMON=/usr/sbin/sslh\n\nDAEMON_OPTS='--user sslh --listen 0.0.0.0:3128 --ssh  0.0.0.0:22 --ssl  0.0.0.0:$ptssl --http  0.0.0.0:80 --openvpn 127.0.0.1:$ptvpn --pidfile /var/run/sslh/sslh.pid'" >/etc/default/sslh
                /etc/init.d/sslh start && service sslh start
            }
            msg -bar
            msg -ama " $(fun_trans "Instalasi SSLH")"
            msg -bar
            fun_bar 'fun_instsslh'
            msg -bar
            msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "MULAI SSLH*")"
            /etc/init.d/sslh restart  > /dev/null 2>&1
            service sslh restart > /dev/null 2>&1
            echo -e " \033[1;32m[OK]"
            msg -bar
            sleep 0.5s
            [[ $(netstat -nplt | grep -w 'sslh' | wc -l) != '0' ]] && msg -ama " $(fun_trans "INSTALASI SUKSES") \033[0m" || echo -e " \033[1;31m$(fun_trans "KESALAHAN YANG TIDAK TERDUGA") \033[0m"
            sleep 3
            msg -bar
            return 0
            } || {
            # Retornando
            msg -bar
            return 0
        }
        } || {
        msg -azu " $(fun_trans "MENGHAPUS SSLH MULTIPLEX")"
        msg -bar
        echo -ne " Hapus SSLH [s/n]: "
        read respo
        [[ "$respo" = "s" ]] && {
            fun_delsslh() {
                /etc/init.d/sslh stop && service sslh stop
                apt-get remove sslh -y
                apt-get purge sslh -y
            }
            msg -bar
            msg -ama " $(fun_trans "Penghapusan SSLH dimulai")"
            msg -bar
            fun_bar 'fun_delsslh'
            msg -bar
            msg -ama " $(fun_trans "SSLH Berhasil dihapus!")"
            msg -bar
            return 0
            } || {
            # Retornando
            msg -bar
            return 0
        }
    }
}
fun_sslh