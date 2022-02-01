#!/bin/bash
declare -A cor=([0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m")
SCPdir="/etc/cr4r" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/inst" && [[ ! -d ${SCPinst} ]] && exit
SCPbahasa="${SCPdir}/bahasa" && [[ ! -e ${SCPbahasa} ]] && touch ${SCPbahasa}

fun_shadowsocks() {
  [[ -e /etc/shadowsocks.json ]] && {
    hapusTools shadowsocks
    return 0
  }
  echo -e "\033[1;32m $(fun_trans "Instalasi Shadowsocks*")CR4R"
  msg -bar
  while true; do
    msg -ama " $(fun_trans "Pilih Type Enkripsi")"
    msg -bar
    encript=(aes-256-gcm aes-192-gcm aes-128-gcm aes-256-ctr aes-192-ctr aes-128-ctr aes-256-cfb aes-192-cfb aes-128-cfb camellia-128-cfb camellia-192-cfb camellia-256-cfb chacha20-ietf-poly1305 chacha20-ietf chacha20 rc4-md5)
    for ((s = 0; s < ${#encript[@]}; s++)); do
      echo -e " [${s}] - ${encript[${s}]}"
    done
    msg -bar
    while true; do
      unset cript
      echo -ne " $(fun_trans "Pilih"): "
      read -e -i 0 cript
      [[ ${encript[$cript]} ]] && break
      echo -e "$(fun_trans "Tidak valid!")"
    done
    encriptacao="${encript[$cript]}"
    [[ ${encriptacao} != "" ]] && break
    echo -e "$(fun_trans "Tidak Valid")"
  done

  msg -bar
  msg -ama " $(fun_trans "Pilih Port Untuk Didengarkan Shadowsocks")"
  msg -bar
  while true; do
    unset Lport
    read -p " Listen Port: " Lport
    [[ $(mportas | grep "$Lport") = "" ]] && break
    echo -e " ${Lport}: $(fun_trans "Port salah!")"
  done
  #INICIANDO
  msg -bar
  msg -ama " $(fun_trans "Masukkan Sandi Shadowsocks")"
  read -p" Pass: " Pass
  msg -bar
  msg -ama " $(fun_trans "Memulai instalasi")"
  msg -bar
  fun_bar 'apt-get install python3-pip python3-m2crypto -y'
  fun_bar 'pip3 install shadowsocks'
  echo """{
  \"server\":\"0.0.0.0\",
  \"server_port\":\"$Lport\",
  \"local_port\":1080,
  \"password\":\"$Pass\",
  \"timeout\":600,
  \"method\":\"\"
}""" >/etc/shadowsocks.json
  echo -ne '",\n"timeout":600,\n"method":"aes-256-cfb"\n}' >>/etc/shadowsocks.json
  echo -ne '",\n"timeout":600,\n"method":"$encriptacao"\n}' >>/etc/shadowsocks.json
  msg -bar
  msg -ama " STARTING\033[0m"
  ssserver -c /etc/shadowsocks.json -d start >/dev/null 2>&1
  value=$(ps x | grep ssserver | grep -v grep)
  [[ $value != "" ]] && value="\033[1;32mSTARTED" || value="\033[1;31mERROR"
  msg -bar
  msg -ama " ${value} "
  msg -bar
  return 0
}

fun_shadowsocks
