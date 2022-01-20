#!/bin/bash
declare -A cor=([0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m")
SCPdir="/etc/cr4r" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/inst" && [[ ! -d ${SCPinst} ]] && exit
SCPbahasa="${SCPdir}/bahasa" && [[ ! -e ${SCPbahasa} ]] && touch ${SCPbahasa}
fun_bar() {
  comando[0]="$1"
  comando[1]="$2"
  (
    [[ -e $HOME/fim ]] && rm $HOME/fim
    ${comando[0]} -y >/dev/null 2>&1
    ${comando[1]} -y >/dev/null 2>&1
    touch $HOME/fim
  ) >/dev/null 2>&1 &
  echo -ne "\033[1;33m ["
  while true; do
    for ((i = 0; i < 10; i++)); do
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
BadVPN() {
  pid_badvpn=$(ps x | grep badvpn | grep -v grep | awk '{print $1}')
  if [ "$pid_badvpn" = "" ]; then
    msg -ama "$(fun_trans "Liberando Badvpn")"
    msg -bar
    if [[ ! -e /bin/badvpn-udpgw ]]; then
      wget -O /bin/badvpn-udpgw https://raw.githubusercontent.com/cr4r/ssh/main/Install/badvpn-udpgw &>/dev/null
      chmod 777 /bin/badvpn-udpgw
    fi
    screen -dmS screen /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 999999 --max-connections-for-client 99
    [[ "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ama "$(fun_trans "Badvpn sukses diaktifkan")" || msg -ama "$(fun_trans "Gagal")"
  else
    msg -ama "$(fun_trans "Menghentikan badvpn")"
    msg -bar
    kill -9 $(ps x | grep badvpn | grep -v grep | awk '{print $1'}) >/dev/null 2>&1
    killall -9 badvpn-udpgw >/dev/null 2>&1
    [[ ! "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ama "$(fun_trans "Badvpn berhasil diberhentikan")" || msg -ama "$(fun_trans "Gagal")"
    unset pid_badvpn
  fi
  unset pid_badvpn
}
TCPspeed() {
  if [[ $(grep -c "^#CR4R" /etc/sysctl.conf) -eq 0 ]]; then
    #INSTALA
    msg -ama "$(fun_trans "Kecepatan TCP Tidak Diaktifkan, Ingin Diaktifkan Sekarang")?"
    msg -bar
    while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
      read -p " [S/N]: " -e -i s resposta
      tput cuu1 && tput dl1
    done
    [[ "$resposta" = @(s|S|y|Y) ]] && {
      echo "#CR4R" >>/etc/sysctl.conf
      echo "net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" >>/etc/sysctl.conf
      sysctl -p /etc/sysctl.conf >/dev/null 2>&1
      msg -ama "$(fun_trans "TCP Berhasil Aktif")!"
    } || msg -ama "$(fun_trans "Cancel")!"
  else
    #REMOVE
    msg -ama "$(fun_trans "Kecepatan TCP Sudah Diaktifkan, Ingin Berhenti Sekarang")?"
    msg -bar
    while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
      read -p " [S/N]: " -e -i s resposta
      tput cuu1 && tput dl1
    done
    [[ "$resposta" = @(s|S|y|Y) ]] && {
      grep -v "^#CR4R
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" /etc/sysctl.conf >/tmp/syscl && mv -f /tmp/syscl /etc/sysctl.conf
      sysctl -p /etc/sysctl.conf >/dev/null 2>&1
      msg -ama "$(fun_trans "TCP Berhasil Dihentikan")!"
    } || msg -ama "$(fun_trans "Di Batalkan")!"
  fi
}
SquidCACHE() {
  msg -ama "$(fun_trans "Cache Squid, Cache Aplikasi tidak ada Squid")"
  msg -ama "$(fun_trans "Meningkatkan kecepatan squid")"
  msg -bar
  if [ -e /etc/squid/squid.conf ]; then
    squid_var="/etc/squid/squid.conf"
  elif [ -e /etc/squid3/squid.conf ]; then
    squid_var="/etc/squid3/squid.conf"
  else
    msg -ama "$(fun_trans "Sistem Anda tidak memiliki squid")!" && return 1
  fi
  teste_cache="#CACHE SQUID"
  if [[ $(grep -c "^$teste_cache" $squid_var) -gt 0 ]]; then
    [[ -e ${squid_var}.bakk ]] && {
      msg -ama "$(fun_trans "Mengidentifikasi Cache SQUID")!"
      mv -f ${squid_var}.bakk $squid_var
      msg -ama "$(fun_trans "cache squid dihapus")!"
      service squid restart >/dev/null 2>&1 &
      service squid3 restart >/dev/null 2>&1 &
      return 0
    }
  fi
  msg -ama "$(fun_trans "Menerapkan Cache Squid")!"
  msg -bar
  _tmp="#CACHE SQUID\ncache_mem 200 MB\nmaximum_object_size_in_memory 32 KB\nmaximum_object_size 1024 MB\nminimum_object_size 0 KB\ncache_swap_low 90\ncache_swap_high 95"
  [[ "$squid_var" = "/etc/squid/squid.conf" ]] && _tmp+="\ncache_dir ufs /var/spool/squid 100 16 256\naccess_log /var/log/squid/access.log squid" || _tmp+="\ncache_dir ufs /var/spool/squid3 100 16 256\naccess_log /var/log/squid3/access.log squid"
  while read s_squid; do
    [[ "$s_squid" != "cache deny all" ]] && _tmp+="\n${s_squid}"
  done <$squid_var
  cp ${squid_var} ${squid_var}.bakk
  echo -e "${_tmp}" >$squid_var
  msg -ama "$(fun_trans "Cache SQUID Berhasil Diterapkan")!"
  service squid restart >/dev/null 2>&1 &
  service squid3 restart >/dev/null 2>&1 &
}
block_torrent() {
  arq="/etc/torrent-cr4r"
  fun_fireoff() {
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t filter -F
    iptables -t filter -X
    iptables -F
    iptables -X
    rm $arq
    sleep 3
  }
  [[ -e /etc/torrent-cr4r ]] && {
    echo -e "\033[1;33m $(fun_trans "MENGHAPUS TORRENT*")"
    msg -bar
    service ssh restart >/dev/null 2>&1
    service sshd restart >/dev/null 2>&1
    fun_bar "fun_fireoff"
    msg -bar
    echo -e "\033[1;32m $(fun_trans "Mulai ulang Sistem hingga Selesai") (reboot)"
    msg -bar
    echo -e "\033[1;33m $(fun_trans "Torrent Anda Telah Berhasil Dihapus")!"
    [[ -e /etc/torrent-cr4r ]] && rm /etc/torrent-cr4r
    if [[ -e /etc/openvpn/openvpn-status.log ]]; then
      msg -bar
      read -p "$(echo -e " Restart sekarang [S/N]: ")" -e -i s respost
      if [[ "$respost" = 's' ]]; then
        msg -bar
        echo -e "\033[1;36m Persiapan untuk memulai ulang VPS"
        echo -e "\033[1;36m Tunggu..."
        sleep 3s
        msg -bar
        echo -e "\033[1;31m[ ! ] Reboot... \033[1;32m[OK]"
        sleep 1s
        ## sudo reboot
        reboot
      fi
    fi
    return 0
  }
  mportas() {
    unset portas
    portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
    while read port; do
      var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
      [[ "$(echo -e $portas | grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
    done <<<"$portas_var"
    i=1
    echo -e "$portas"
  }
  fun_ip() {
    if [[ -e /etc/IPSERVER ]]; then
      IP="$(cat /etc/IPSERVER)"
    else
      MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
      MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
      [[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
      echo "$MEU_IP2" >/etc/IPSERVER
    fi
  }
  [[ $(iptables -h | wc -l) -lt 5 ]] && apt-get install iptables -y >/dev/null 2>-1
  NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
  msg -ama "$(fun_trans "Pengaturan ini hanya harus ditambahkan")"
  msg -ama "$(fun_trans "setelah vps sepenuhnya dikonfigurasi!")"
  msg -bar
  echo -e "$(fun_trans "Apakah Anda ingin melanjutkan?")"
  read -p " [S/N]: " -e -i n PROS
  [[ $PROS = @(s|S|y|Y) ]] || return 1
  fun_ip #Pega IP e armazena em uma variavel
  msg -bar
  msg -azu "$(fun_trans "Tunggu...")"
  #Inicia Procedimentos
  #Parametros iniciais
  echo 'iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' >$arq
  #libera DNS
  echo 'iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT' >>$arq
  #Liberar DHCP
  echo 'iptables -A OUTPUT -p tcp --dport 67 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT' >>$arq
  #Liberando Serviços Ativos
  list_ips=$(mportas | awk '{print $2}')
  while read PORT; do
    echo "iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
iptables -A INPUT -p udp --dport $PORT -j ACCEPT
iptables -A OUTPUT -p tcp --dport $PORT -j ACCEPT
iptables -A OUTPUT -p udp --dport $PORT -j ACCEPT
iptables -A FORWARD -p tcp --dport $PORT -j ACCEPT
iptables -A FORWARD -p udp --dport $PORT -j ACCEPT
iptables -A OUTPUT -p tcp -d $IP --dport $PORT -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp -d $IP --dport $PORT -m state --state NEW -j ACCEPT" >>$arq
  done <<<"$list_ips"
  #Bloqueando Ping
  echo 'iptables -A INPUT -p icmp --icmp-type echo-request -j DROP' >>$arq
  #Liberar WEBMIN
  echo 'iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 10000 -j ACCEPT' >>$arq
  #Bloqueando torrent
  echo "iptables -t nat -A PREROUTING -i $NIC -p tcp --dport 6881:6889 -j DNAT --to-dest $IP
iptables -A FORWARD -p tcp -i $NIC --dport 6881:6889 -d $IP -j REJECT
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6889 -j DROP" >>$arq
  echo 'iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP' >>$arq
  sleep 2
  chmod +x $arq
  /etc/torrent-cr4r >/dev/null
  #ServiceInicia
  service ssh restart >/dev/null 2>&1
  service sshd restart >/dev/null 2>&1
  msg -bar
  msg -ama " $(fun_trans "Torrent Anda Telah Berhasil Diterapkan")"
}
on="\033[1;32mon" && off="\033[1;31moff"
[[ $(ps x | grep badvpn | grep -v grep | awk '{print $1}') ]] && badvpn=$on || badvpn=$off
[[ $(grep -c "^#CR4R" /etc/sysctl.conf) -eq 0 ]] && tcp=$off || tcp=$on
[[ -e /etc/torrent-cr4r ]] && torrent=$(echo -e "\033[1;32mon ") || torrent=$(echo -e "\033[1;31moff ")
if [ -e /etc/squid/squid.conf ]; then
  [[ $(grep -c "^#CACHE SQUID" /etc/squid/squid.conf) -gt 0 ]] && squid=$on || squid=$off
elif [ -e /etc/squid3/squid.conf ]; then
  [[ $(grep -c "^#CACHE SQUID" /etc/squid3/squid.conf) -gt 0 ]] && squid=$on || squid=$off
fi
msg -ama "$(fun_trans "MENU DE UTILITARIOS")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Kembali")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "TCPSPEED") $tcp"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "TORRENT") $torrent"
# echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "BADVPN") $badvpn"
# echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "CACHE DO SQUID") $squid"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-2]) ]]; do
  read -p "[0-2]: " arquivoonlineadm
  tput cuu1 && tput dl1
done
case $arquivoonlineadm in
1) TCPspeed ;;
2) block_torrent ;;
3) BadVPN ;;
# 4)SquidCACHE;;
0) exit ;;
esac
msg -bar
