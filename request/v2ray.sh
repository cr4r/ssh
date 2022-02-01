#!/bin/bash
clear
clear
declare -A cor=([0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m")
SCPdir="/etc/VPS-MX" && [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
SCPfrm="${SCPdir}/tools" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPinst="${SCPdir}/protokol" && [[ ! -d ${SCPinst} ]] && mkdir ${SCPinst}
SCPbahasa="${SCPdir}/bahasa" && [[ ! -e ${SCPbahasa} ]] && touch ${SCPbahasa}
[[ ! -d $SCPdir/v2ray ]] && mkdir -p $SCPdir/v2ray
[[ ! -e /bin/inst_v2ray ]] && echo "/etc/inst/v2ray.sh" >/bin/inst_v2ray && chmod +x /bin/inst_v2ray #ACCESO RAPIDO
link_bin="https://raw.githubusercontent.com/cr4r/ssh/main/Install/trans"
[[ ! -e /usr/bin/trans ]] && wget -O /usr/bin/trans ${link_bin} >/dev/null 2>&1 && chmod +x /usr/bin/trans
#dirapache="/usr/local/lib/ubuntn/apache/ver" && [[ ! -d ${dirapache} ]] && exit
#msg -tit
#msg -bar3
#SPR &
msg() {
  local colors="/etc/new-cr4r-color"
  if [[ ! -e $colors ]]; then
    COLOR[0]='\033[1;37m' #BRAN='\033[1;37m'
    COLOR[1]='\e[31m'     #VERMELHO='\e[31m'
    COLOR[2]='\e[32m'     #VERDE='\e[32m'
    COLOR[3]='\e[33m'     #AMARELO='\e[33m'
    COLOR[4]='\e[34m'     #AZUL='\e[34m'
    COLOR[5]='\e[35m'     #MAGENTA='\e[35m'
    COLOR[6]='\033[1;36m' #MAG='\033[1;36m'
  else
    local COL=0
    for number in $(cat $colors); do
      case $number in
      1) COLOR[$COL]='\033[1;37m' ;;
      2) COLOR[$COL]='\e[31m' ;;
      3) COLOR[$COL]='\e[32m' ;;
      4) COLOR[$COL]='\e[33m' ;;
      5) COLOR[$COL]='\e[34m' ;;
      6) COLOR[$COL]='\e[35m' ;;
      7) COLOR[$COL]='\033[1;36m' ;;
      esac
      let COL++
    done
  fi
  NEGRITO='\e[1m'
  SEMCOR='\e[0m'
  case $1 in
  -ne) cor="${COLOR[1]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -ama) cor="${COLOR[3]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verm) cor="${COLOR[3]}${NEGRITO}[!] ${COLOR[1]}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verm2) cor="${COLOR[1]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -azu) cor="${COLOR[6]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verd) cor="${COLOR[2]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -bra) cor="${COLOR[0]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  "-bar2" | "-bar") cor="${COLOR[4]}——————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
  esac
}
fun_trans() {
  local texto
  local retorno
  declare -A texto
  SCPbahasa="${SCPdir}/bahasa"
  [[ ! -e ${SCPbahasa} ]] && touch ${SCPbahasa}
  local LINGUAGE=$(cat ${SCPbahasa})
  [[ -z $LINGUAGE ]] && LINGUAGE=id
  [[ $LINGUAGE == "id" ]] && echo "$@" && return
  [[ ! -e /etc/texto-cr4r ]] && touch /etc/texto-cr4r
  source /etc/texto-cr4r
  if [[ -z "$(echo ${texto[$@]})" ]]; then
    if [[ $(echo "$@" | grep -o '*') = "*" ]]; then
      # retorno="$(source trans -e google -b pt:${LINGUAGE} "$@" | sed -e 's/[^a-z0-9 -]//ig' | awk '{print toupper($0)}' 2>/dev/null)"
      retorno="$(source trans -e google -b pt:${LINGUAGE} "$@" | sed -e 's/[^a-z0-9-]//ig' | awk '{print toupper($0)}' 2>/dev/null)"
    else
      retorno="$(source trans -e google -b pt:${LINGUAGE} "$@" | sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
    fi
    if [[ $retorno != "" ]]; then
      echo "texto[$@]='$retorno'" >>/etc/texto-cr4r
      echo "$retorno"
    else
      echo "$@"
    fi
  else
    echo "${texto[$@]}"
  fi
}
err_fun() {
  case $1 in
  1)
    msg -verm "$(fun_trans "Pengguna tidak ada")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  2)
    msg -verm "$(fun_trans "Nama terlalu pendek (MIN: 2 huruf)")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  3)
    msg -verm "$(fun_trans "Nama terlalu panjang (MAX: 5 huruf)")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  4)
    msg -verm "$(fun_trans "Kata Sandi kosong")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  5)
    msg -verm "$(fun_trans "kata sandi terlalu pendek")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  6)
    msg -verm "$(fun_trans "kata sandi terlalu panjang")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  7)
    msg -verm "$(fun_trans "Durasi tidak ada")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  8)
    msg -verm "$(fun_trans "Durasi tidak valid")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  9)
    msg -verm "$(fun_trans "Durasi melebihi maksimal")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  11)
    msg -verm "$(fun_trans "Limit kosong")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  12)
    msg -verm "$(fun_trans "Limit tidak valid")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  13)
    msg -verm "$(fun_trans "Limit maksimal 999")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  14)
    msg -verm "$(fun_trans "User sudah ada")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  15)
    msg -verm "$(fun_trans "(Hanya angka) GB = Min: 1gb Max: 1000gb")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  16)
    msg -verm "$(fun_trans "(Hanya angka)")"
    sleep 2s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  17)
    msg -verm "$(fun_trans "(Informasi - Untuk Membatalkan Ketik CTRL + C)")"
    sleep 4s
    tput cuu1
    tput dl1
    tput cuu1
    tput dl1
    ;;
  esac
}
intallv2ray() {
  apt install python3-pip -y
  source <(curl -sL https://raw.githubusercontent.com/cr4r/ssh/main/Install/install-v2ray.sh)
  msg -ama "$(fun_trans "Berhasil Di instal")!"
  USRdatabase="${SCPdir}/RegV2ray"
  [[ ! -e ${USRdatabase} ]] && touch ${USRdatabase}
  sort ${USRdatabase} | uniq >${USRdatabase}tmp
  mv -f ${USRdatabase}tmp ${USRdatabase}
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray

}
protocolv2ray() {
  msg -ama "$(fun_trans "Pilih opsi 3 dan masukkan domain IP")!"
  msg -bar
  v2ray stream
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}
tls() {
  msg -ama "$(fun_trans "Aktifkan atau Nonaktifkan TLS")!"
  msg -bar
  v2ray tls
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}
portv() {
  msg -ama "$(fun_trans "Ubah Port v2ray")!"
  msg -bar
  v2ray port
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}
stats() {
  msg -ama "$(fun_trans "Statistik Konsumsi")!"
  msg -bar
  v2ray stats
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}
unistallv2() {
  source <(curl -sL https://raw.githubusercontent.com/cr4r/ssh/main/Install/install-v2ray.sh) --remove >/dev/null 2>&1
  rm -rf $SCPdir/RegV2ray >/dev/null 2>&1
  echo -e "\033[1;92m                  Hapus V2RAY OK "
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}
infocuenta() {
  v2ray info
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}
addusr() {
  clear
  clear
  msg -bar
  #msg -tit
  msg -ama "             TAMBAHKAN PENGGUNA | UUID V2RAY"
  msg -bar
  ##DAIS
  valid=$(date '+%C%y-%m-%d' -d " +31 days")
  ##CORREO
  MAILITO=$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 10)
  ##ADDUSERV2RAY
  UUID=$(uuidgen)
  sed -i '13i\           \{' /etc/v2ray/config.json
  sed -i '14i\           \"alterId": 0,' /etc/v2ray/config.json
  sed -i '15i\           \"id": "'$UUID'",' /etc/v2ray/config.json
  sed -i '16i\           \"email": "'$MAILITO'@gmail.com"' /etc/v2ray/config.json
  sed -i '17i\           \},' /etc/v2ray/config.json
  echo ""
  while true; do
    echo -ne "\e[91m >> Ketik User: \033[1;92m"
    read -p ": " nick
    nick="$(echo $nick | sed -e 's/[^a-z0-9 -]//ig')"
    if [[ -z $nick ]]; then
      err_fun 17 && continue
    elif [[ "${#nick}" -lt "2" ]]; then
      err_fun 2 && continue
    elif [[ "${#nick}" -gt "5" ]]; then
      err_fun 3 && continue
    fi
    break
  done
  echo -e "\e[91m >> Tambahkan UUID: \e[92m$UUID "
  while true; do
    echo -ne "\e[91m >> Durasi UUID (hari):\033[1;92m " && read diasuser
    if [[ -z "$diasuser" ]]; then
      err_fun 17 && continue
    elif [[ "$diasuser" != +([0-9]) ]]; then
      err_fun 8 && continue
    elif [[ "$diasuser" -gt "360" ]]; then
      err_fun 9 && continue
    fi
    break
  done
  #Lim
  [[ $(cat /etc/passwd | grep $1: | grep -vi [a-z]$1 | grep -v [0-9]$1 >/dev/null) ]] && return 1
  valid=$(date '+%C%y-%m-%d' -d " +$diasuser days") && datexp=$(date "+%F" -d " + $diasuser days")
  echo -e "\e[91m >> Expira el : \e[92m$datexp "
  ##Registro
  echo "  $UUID | $nick | $valid " >>$SCPdir/RegV2ray
  Fecha=$(date +%d-%m-%y-%R)
  cp $SCPdir/RegV2ray $SCPdir/v2ray/RegV2ray-"$Fecha"
  v2ray restart >/dev/null 2>&1
  echo ""
  v2ray info >$SCPdir/v2ray/confuuid.log
  lineP=$(sed -n '/'${UUID}'/=' $SCPdir/v2ray/confuuid.log)
  numl1=4
  let suma=$lineP+$numl1
  sed -n ${suma}p $SCPdir/v2ray/confuuid.log
  echo ""
  msg -bar
  echo -e "\e[92m           UUID BERHASIL TAMBAH "
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}

delusr() {
  clear
  clear
  invaliduuid() {
    msg -bar
    echo -e "\e[91m                    UUID salah \n$(msg -bar)"
    msg -ne "Enter untuk melanjutkan" && read enter
    inst_v2ray
  }
  msg -bar
  #msg -tit
  msg -ama "             HAPUS PENGGUNA | UUID V2RAY"
  msg -bar
  echo -e "\e[97m               PENGGUNA TERDAFTAR"
  echo -e "\e[33m$(cat ${SCPdir}/RegV2ray | cut -d '|' -f2,1)"
  msg -bar
  echo -ne "\e[91m >> Masukkan UUID yang ingin dihapus:\n \033[1;92m " && read uuidel
  [[ $(sed -n '/'${uuidel}'/=' /etc/v2ray/config.json | head -1) ]] || invaliduuid
  lineP=$(sed -n '/'${uuidel}'/=' /etc/v2ray/config.json)
  linePre=$(sed -n '/'${uuidel}'/=' ${SCPdir}/RegV2ray)
  sed -i "${linePre}d" $SCPdir/RegV2ray
  numl1=2
  let resta=$lineP-$numl1
  sed -i "${resta}d" /etc/v2ray/config.json
  sed -i "${resta}d" /etc/v2ray/config.json
  sed -i "${resta}d" /etc/v2ray/config.json
  sed -i "${resta}d" /etc/v2ray/config.json
  sed -i "${resta}d" /etc/v2ray/config.json
  v2ray restart >/dev/null 2>&1
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}

mosusr_kk() {
  clear
  clear
  msg -bar
  #msg -tit
  msg -ama "         PENGGUNA TERDAFTAR | UUID V2RAY"
  msg -bar
  # usersss=$(cat $SCPdir/RegV2ray|cut -d '|' -f1)
  # cat $SCPdir/RegV2ray|cut -d'|' -f3
  VPSsec=$(date +%s)
  local HOST="${SCPdir}/RegV2ray"
  local HOST2="${SCPdir}/RegV2ray"
  local RETURN="$(cat $HOST | cut -d'|' -f2)"
  local IDEUUID="$(cat $HOST | cut -d'|' -f1)"
  if [[ -z $RETURN ]]; then
    echo -e "----- TIDAK ADA PENGGUNA TERDAFTAR -----"
    msg -ne "Enter untuk melanjutkan" && read enter
    inst_v2ray

  else
    i=1
    echo -e "\e[97m                 UUID                | USER | EXPIRACION \e[93m"
    msg -bar
    while read hostreturn; do
      DateExp="$(cat ${SCPdir}/RegV2ray | grep -w "$hostreturn" | cut -d'|' -f3)"
      if [[ ! -z $DateExp ]]; then
        DataSec=$(date +%s --date="$DateExp")
        [[ "$VPSsec" -gt "$DataSec" ]] && EXPTIME="\e[91m[Expired]\e[97m" || EXPTIME="\e[92m[$(($(($DataSec - $VPSsec)) / 86400))]\e[97m Hari"
      else
        EXPTIME="\e[91m[ S/R ]"
      fi
      usris="$(cat ${SCPdir}/RegV2ray | grep -w "$hostreturn" | cut -d'|' -f2)"
      local contador_secuencial+="\e[93m$hostreturn \e[97m|\e[93m$usris\e[97m|\e[93m $EXPTIME \n"
      if [[ $i -gt 30 ]]; then
        echo -e "$contador_secuencial"
        unset contador_secuencial
        unset i
      fi
      let i++
    done <<<"$IDEUUID"

    [[ ! -z $contador_secuencial ]] && {
      linesss=$(cat ${SCPdir}/RegV2ray | wc -l)
      echo -e "$contador_secuencial \n Jumlah Terdaftar: $linesss"
    }
  fi
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray
}
lim_port() {
  clear
  clear
  msg -bar
  #msg -tit
  msg -ama "          BATAS MB X PORT | UUID V2RAY"
  msg -bar
  ###VER
  estarts() {
    VPSsec=$(date +%s)
    local HOST="${SCPdir}/v2ray/lisportt.log"
    local HOST2="${SCPdir}/v2ray/lisportt.log"
    local RETURN="$(cat $HOST | cut -d'|' -f2)"
    local IDEUUID="$(cat $HOST | cut -d'|' -f1)"
    if [[ -z $RETURN ]]; then
      echo -e "----- TIDAK TERDAFTAR PORT -----"
      msg -ne "Enter untuk melanjutkan" && read enter
      inst_v2ray
    else
      i=1
      while read hostreturn; do
        iptables -n -v -L >$SCPdir/v2ray/data1.log
        statsss=$(cat $SCPdir/v2ray/data1.log | grep -w "tcp spt:$hostreturn quota:" | cut -d' ' -f3,4,5)
        gblim=$(cat $SCPdir/v2ray/lisportt.log | grep -w "$hostreturn" | cut -d'|' -f2)
        local contador_secuencial+="         \e[97mPORT: \e[93m$hostreturn \e[97m|\e[93m$statsss \e[97m|\e[93m $gblim GB  \n"
        if [[ $i -gt 30 ]]; then
          echo -e "$contador_secuencial"
          unset contador_secuencial
          unset i
        fi
        let i++
      done <<<"$IDEUUID"

      [[ ! -z $contador_secuencial ]] && {
        linesss=$(cat $SCPdir/v2ray/lisportt.log | wc -l)
        echo -e "$contador_secuencial \n Port terbatas: $linesss"
      }
    fi
    msg -bar
    msg -ne "Enter untuk melanjutkan" && read enter
    inst_v2ray
  }
  ###LIM
  liport() {
    while true; do
      echo -ne "\e[91m >> Ketik Port yang dilimit:\033[1;92m " && read portbg
      if [[ -z "$portbg" ]]; then
        err_fun 17 && continue
      elif [[ "$portbg" != +([0-9]) ]]; then
        err_fun 16 && continue
      elif [[ "$portbg" -gt "1000" ]]; then
        err_fun 16 && continue
      fi
      break
    done
    while true; do
      echo -ne "\e[91m >> Masukkan Jumlah GB:\033[1;92m " && read capgb
      if [[ -z "$capgb" ]]; then
        err_fun 17 && continue
      elif [[ "$capgb" != +([0-9]) ]]; then
        err_fun 15 && continue
      elif [[ "$capgb" -gt "1000" ]]; then
        err_fun 15 && continue
      fi
      break
    done
    uml1=1073741824
    gbuser="$capgb"
    let multiplicacion=$uml1*$gbuser
    sudo iptables -I OUTPUT -p tcp --sport $portbg -j DROP
    sudo iptables -I OUTPUT -p tcp --sport $portbg -m quota --quota $multiplicacion -j ACCEPT
    iptables-save >/etc/iptables/rules.v4
    echo ""
    echo -e " Port yang Dipilih: $portbg | Jumlah GB: $gbuser"
    echo ""
    echo " $portbg | $gbuser | $multiplicacion " >>$SCPdir/v2ray/lisportt.log
    msg -bar
    msg -ne "Enter untuk melanjutkan" && read enter
    inst_v2ray
  }
  ###RES
  resdata() {
    VPSsec=$(date +%s)
    local HOST="${SCPdir}/v2ray/lisportt.log"
    local HOST2="${SCPdir}/v2ray/lisportt.log"
    local RETURN="$(cat $HOST | cut -d'|' -f2)"
    local IDEUUID="$(cat $HOST | cut -d'|' -f1)"
    if [[ -z $RETURN ]]; then
      echo -e "----- PORT TIDAK TERDAFTAR -----"
      return 0
    else
      i=1
      while read hostreturn; do
        iptables -n -v -L >$SCPdir/v2ray/data1.log
        statsss=$(cat $SCPdir/v2ray/data1.log | grep -w "tcp spt:$hostreturn quota:" | cut -d' ' -f3,4,5)
        gblim=$(cat $SCPdir/v2ray/lisportt.log | grep -w "$hostreturn" | cut -d'|' -f2)
        local contador_secuencial+="         \e[97mPORT: \e[93m$hostreturn \e[97m|\e[93m$statsss \e[97m|\e[93m $gblim GB  \n"

        if [[ $i -gt 30 ]]; then
          echo -e "$contador_secuencial"
          unset contador_secuencial
          unset i
        fi
        let i++
      done <<<"$IDEUUID"

      [[ ! -z $contador_secuencial ]] && {
        linesss=$(cat $SCPdir/v2ray/lisportt.log | wc -l)
        echo -e "$contador_secuencial \n Limit PORT: $linesss"
      }
    fi
    msg -bar

    while true; do
      echo -ne "\e[91m >> Port untuk dihapus:\033[1;92m " && read portbg
      if [[ -z "$portbg" ]]; then
        err_fun 17 && continue
      elif [[ "$portbg" != +([0-9]) ]]; then
        err_fun 16 && continue
      elif [[ "$portbg" -gt "1000" ]]; then
        err_fun 16 && continue
      fi
      break
    done
    invaliduuid() {
      msg -bar
      echo -e "\e[91m                PORT salah \n$(msg -bar)"
      msg -ne "Enter untuk melanjutkan" && read enter
      inst_v2ray
    }
    [[ $(sed -n '/'${portbg}'/=' $SCPdir/v2ray/lisportt.log | head -1) ]] || invaliduuid
    gblim=$(cat $SCPdir/v2ray/lisportt.log | grep -w "$portbg" | cut -d'|' -f3)
    sudo iptables -D OUTPUT -p tcp --sport $portbg -j DROP
    sudo iptables -D OUTPUT -p tcp --sport $portbg -m quota --quota $gblim -j ACCEPT
    iptables-save >/etc/iptables/rules.v4
    lineP=$(sed -n '/'${portbg}'/=' $SCPdir/v2ray/lisportt.log)
    sed -i "${linePre}d" $SCPdir/v2ray/lisportt.log
    msg -bar
    msg -ne "Enter untuk melanjutkan" && read enter
    inst_v2ray
  }
  ## MENU
  echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "BATAS TANGGAL x PORT") "
  echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "SETEL ULANG DATA PORT") "
  echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "LIHAT DATA YANG DIKONSUMSI") "
  echo -ne "$(msg -bar)\n\033[1;32m [0] > " && msg -bra "\e[97m\033[1;41m KEMBALI \033[1;37m"
  msg -bar
  selection=$(selection_fun 3)
  case ${selection} in
  1) liport ;;
  2) resdata ;;
  3) estarts ;;
  0)
    inst_v2ray
    ;;
  esac
}

pembersih_aktivasi() {
  unset PIDGEN
  PIDGEN=$(ps aux | grep -v grep | grep "limv2ray")
  if [[ ! $PIDGEN ]]; then
    screen -dmS limv2ray watch -n 21600 limv2ray
  else
    #killall screen
    screen -S limv2ray -p 0 -X quit
  fi
  unset PID_GEN
  PID_GEN=$(ps x | grep -v grep | grep "limv2ray")
  [[ ! $PID_GEN ]] && PID_GEN="\e[91m [ Tidak Aktif ] " || PID_GEN="\e[92m [ Aktif ] "
  statgen="$(echo $PID_GEN)"
  clear
  clear
  msg -bar
  #msg -tit
  msg -ama "          HAPUS KEDALUARSA | UUID V2RAY"
  msg -bar
  echo ""
  echo -e "                    $statgen "
  echo ""
  msg -bar
  msg -ne "Enter untuk melanjutkan" && read enter
  inst_v2ray

}

PID_GEN=$(ps x | grep -v grep | grep "limv2ray")
[[ ! $PID_GEN ]] && PID_GEN="\e[91m [ Tidak Aktif ] " || PID_GEN="\e[92m [ Aktif ] "
statgen="$(echo $PID_GEN)"
#SPR &
#msg -bar3
msg -bar
#msg -tit
msg -ama "$(fun_trans "        Menu V2RAY ") \e[97mStatus: $(pid_inst v2ray)"
msg -bar
## INSTALADOR
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Instalasi V2RAY") "
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "GANTI PROTOKOL") "
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Aktifkan TLS") "
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "GANTI PORT V2RAY")\n$(msg -bar) "
## CONTROLER
echo -ne "\033[1;32m [5] > " && msg -azu "TAMBAHKAN UUID PENGGUNA "
echo -ne "\033[1;32m [6] > " && msg -azu "HAPUS UUID PENGGUNA"
echo -ne "\033[1;32m [7] > " && msg -azu "MOSTAR PENGGUNA TERDAFTAR"
echo -ne "\033[1;32m [8] > " && msg -azu "INFORMASI AKUN"
echo -ne "\033[1;32m [9] > " && msg -azu "STATISTIK PELANGGAN "
echo -ne "\033[1;32m [10] > " && msg -azu "LIMIT BERDASARKAN KONSUMSI\e[91m ( BETA x PORT )"
echo -ne "\033[1;32m [11] > " && msg -azu "PEMBERSIH KEDALUWARSA ------- $statgen\n$(msg -bar)"
## DESISNTALAR
echo -ne "\033[1;32m [12] > " && msg -azu "\033[1;31mHapus V2RAY"
echo -ne "$(msg -bar)\n\033[1;32m [0] > " && msg -bra "\e[97m\033[1;41m Kembali \033[1;37m"
msg -bar

# while [[ ${arquivoonlineadm} != @(0|[1-99]) ]]; do
# read -p "Seleccione una Opcion [0-12]: " arquivoonlineadm
# tput cuu1 && tput dl1
# done
selection=$(selection_fun 18)
case ${selection} in
1) intallv2ray ;;
2) protocolv2ray ;;
3) tls ;;
4) portv ;;
5) addusr ;;
6) delusr ;;
7) mosusr_kk ;;
8) infocuenta ;;
9) stats ;;
10) lim_port ;;
11) pembersih_aktivasi ;;
12) unistallv2 ;;
0) exit ;;
esac
