#!/bin/bash
declare -A cor=([0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m")
SCPdir="/etc/cr4r" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/inst" && [[ ! -d ${SCPinst} ]] && exit
SCPbahasa="${SCPdir}/bahasa" && [[ ! -e ${SCPbahasa} ]] && touch ${SCPbahasa}

port() {
  local portas
  local portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
  i=0
  while read port; do
    var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
    [[ "$(echo -e ${portas} | grep -w "$var1 $var2")" ]] || {
      portas+="$var1 $var2 $portas"
      echo "$var1 $var2"
      let i++
    }
  done <<<"$portas_var"
}

verify_port() {
  local SERVICE="$1"
  local PORTENTRY="$2"
  [[ ! $(echo -e $(port | grep -v ${SERVICE}) | grep -w "$PORTENTRY") ]] && return 0 || return 1
}

opssh_fun() {
  msg -verd " $(fun_trans "Auto Konfigurasi Openssh")"
  msg -bar
  fun_ip
  msg -ne " $(fun_trans "Konfirmasi ip server")"
  read -p ": " -e -i $IP ip
  fun_aplicaroot() {
    apt-get update -y
    apt-get upgrade -y
    service ssh restart
    cp /etc/ssh/sshd_config /etc/ssh/sshd_back
    [[ $(grep -c "prohibit-password" /etc/ssh/sshd_config) != '0' ]] && {
      sed -i "s/prohibit-password/yes/g" /etc/ssh/sshd_config
    }
    [[ $(grep -c "without-password" /etc/ssh/sshd_config) != '0' ]] && {
      sed -i "s/without-password/yes/g" /etc/ssh/sshd_config
    }
    [[ $(grep -c "#PermitRootLogin" /etc/ssh/sshd_config) != '0' ]] && {
      sed -i "s/#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
    }
    [[ $(grep -c "PasswordAuthentication" /etc/ssh/sshd_config) = '0' ]] && {
      echo 'PasswordAuthentication yes' >/etc/ssh/sshd_config
    }
    [[ $(grep -c "PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
      sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    }
    [[ $(grep -c "#PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
      sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    }
    service ssh restart
    iptables -F
    iptables -A INPUT -p tcp --dport 81 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 8799 -j ACCEPT
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    iptables -A INPUT -p tcp --dport 1194 -j ACCEPT
  }
  fun_bar "fun_aplicaroot"
  msg -bar
  echo -e "\033[1;37m $(fun_trans "Masukkan sandi login (baru/lama):")"
  read -p " Sandi: " pass
  (
    echo $pass
    echo $pass
  ) | passwd 2>/dev/null
  msg -bar
  msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "Mulai ulang sshd*")"
  service ssh restart >/dev/null 2>&1
  service sshd restart >/dev/null 2>&1
  echo -e " \033[1;32m[OK]"
  sleep 3s
  msg -bar
  echo -e "\033[1;31m $(fun_trans "Kata Sandi Root Saat Ini") : \033[1;32m$pass"
  echo -e "\033[1;31m $(fun_trans "Izin pengguna root") \033[1;32m[OK]"
  echo -e "\033[1;31m $(fun_trans "Lokasi sshd") > \033[1;31m[ \033[1;32m/etc/ssh/sshd_config \033[1;31m]"
  msg -bar
  msg -ama " $(fun_trans "Openssh Anda telah berhasil dikonfigurasi")"
  msg -bar
  return 0
}

download_ssh() {
  msg -verd " $(fun_trans "Mendownload konfigurasi otomatis")"
  msg -bar
  fun_ip
  msg -ne " $(fun_trans "Konfirmasi IP server")"
  read -p ": " -e -i $IP ip
  msg -bar
  msg -ama " $(fun_trans "DOWNLOAD Dimulai")"
  msg -bar
  #Inicia Procedimentos
  fun_aplicaroot() {
    apt-get update -y
    apt-get upgrade -y
    service ssh restart
    cp /etc/ssh/sshd_config /etc/ssh/sshd_back
    wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/cr4r/ssh/main/Install/sshd_config >/dev/null 2>&1
    chmod +x /etc/ssh/sshd_config
    service ssh restart
    iptables -F
    iptables -A INPUT -p tcp --dport 81 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 8799 -j ACCEPT
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    iptables -A INPUT -p tcp --dport 1194 -j ACCEPT
  }
  fun_bar "fun_aplicaroot"
  msg -bar
  echo -e "\033[1;37m $(fun_trans "Masukkan Kata Sandi Anda Saat Ini atau Kata Sandi Baru")"
  read -p " Pass: " pass
  (
    echo $pass
    echo $pass
  ) | passwd 2>/dev/null
  msg -bar
  msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "Mulai ulang sshd*")"
  service ssh restart >/dev/null 2>&1
  service sshd restart >/dev/null 2>&1
  echo -e " \033[1;32m[OK]"
  sleep 3s
  msg -bar
  echo -e "\033[1;31m $(fun_trans "Kata sandi saat ini") Root: \033[1;32m$pass"
  echo -e "\033[1;31m $(fun_trans "Pengguna root") \033[1;32m[OK]"
  echo -e "\033[1;31m $(fun_trans "Lokasi sshd") > \033[1;31m[ \033[1;32m/etc/ssh/sshd_config \033[1;31m]"
  msg -bar
  msg -ama " $(fun_trans "Openssh Anda telah berhasil dikonfigurasi")"
  msg -bar
  return 0
}

edit_openssh() {
  echo -e "\033[1;31m $(fun_trans "Pilih Port yang Valid dalam Urutan Urutan")"
  echo -e "\033[1;31m $(fun_trans "Contoh"):\033[1;32m 22 80 81 82 85 90\033[1;37m"
  msg -bar
  msg -azu "$(fun_trans "SETEL ULANG PORT TERBUKA")"
  msg -bar
  local CONF="/etc/ssh/sshd_config"
  local NEWCONF="$(cat ${CONF} | grep -v [Pp]ort)"
  read -p "$(echo -e "\033[1;31m$(fun_trans "Masukkan Port"): \033[1;37m")" -e -i 22 newports
  [[ -z "$newports" ]] && {
    echo -e "\n\033[1;31m$(fun_trans "Tidak Ada Port yang Valid Dipilih")"
    sleep 2
    ##instalar
    exit
  }
  for PTS in $(echo ${newports}); do
    verify_port sshd "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
      echo -e "\033[1;33m$(fun_trans "Port") $PTS \033[1;31m$(fun_trans "FAIL")"
      sleep 2
      msg -bar
      return 0
    }
  done
  rm ${CONF}
  for NPT in $(echo ${newports}); do
    echo -e "Port ${NPT}" >>${CONF}
  done
  while read varline; do
    echo -e "${varline}" >>${CONF}
  done <<<"${NEWCONF}"
  msg -azu "$(fun_trans "Merestart sshd")"
  service ssh restart &>/dev/null
  service sshd restart &>/dev/null
  sleep 1s
  msg -bar
  msg -azu "$(fun_trans "Openssh telah di edit")"
  msg -bar
}

openssh() {
  msg -ama "$(fun_trans "CONFIGURAÇÃO DO OPENSSH")"
  mine_port
  msg -bar
  echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Kembali")"
  echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Auto Konfigurasi")"
  echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "DOWNLOAD Konfigurasi")"
  echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Edit PORT SSH")"
  echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "Edit Client OPENSSH") \033[1;31m(comand nano)"
  msg -bar
  while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
    read -p "[0-4]: " arquivoonlineadm
    tput cuu1 && tput dl1
  done
  case $arquivoonlineadm in
  0) exit ;;
  1) opssh_fun ;;
  2) download_ssh ;;
  3) edit_openssh ;;
  4)
    nano /etc/ssh/sshd_config
    return 0
    ;;
  esac
}
openssh
