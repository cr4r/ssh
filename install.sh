#!/bin/bash
cd $HOME
#SCPdir="/etc/newadm"
SCPdir="/etc/cr4r"
SCPinstal="$HOME/install"
SCPbahasa="${SCPdir}/bahasa"
# SCPusr="${SCPdir}/ger-user"
SCPusr="${SCPdir}/user"
SCPfrm="/etc/ger-frm"
# SCPinst="/etc/ger-inst"
SCPinst="/etc/inst"

SCPresq="aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2NyNHIvc3NoL21haW4vcmVxdWVzdA=="
SUB_DOM='base64 -d'
[[ $(dpkg --get-selections|grep -w "gawk"|head -1) ]] || apt-get install gawk -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "mlocate"|head -1) ]] || apt-get install mlocate -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "iproute2"|head -1) ]] || apt-get install iproute2 -y &>/dev/null
rm $(pwd)/$0 &> /dev/null

msg () {
    BRAN='\033[1;37m' && VERMELHO='\e[31m' && VERDE='\e[32m' && AMARELO='\e[33m'
    AZUL='\e[34m' && MAGENTA='\e[35m' && MAG='\033[1;36m' &&NEGRITO='\e[1m' && SEMCOR='\e[0m'
    case $1 in
        -ne)cor="${VERMELHO}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}";;
        -ama)cor="${AMARELO}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
        -verm)cor="${AMARELO}${NEGRITO}[!] ${VERMELHO}" && echo -e "${cor}${2}${SEMCOR}";;
        -azu)cor="${MAG}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
        -verd)cor="${VERDE}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
        -bra)cor="${BRAN}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}";;
        "-bar2"|"-bar")cor="${AZUL}${NEGRITO}——————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}";;
    esac
}

fun_ip () {
    MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    MIP2=$(wget -qO- ipv4.icanhazip.com)
    [[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
}

inst_components () {
    msg -ama "Menginstall plugin yang diperlukan"
    [[ $(dpkg --get-selections|grep -w "iproute2"|head -1) ]] || apt-get install iproute2 -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "nano"|head -1) ]] || apt-get install nano -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] || apt-get install bc -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "screen"|head -1) ]] || apt-get install screen -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || apt-get install python -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] || apt-get install python3 -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || apt-get install curl -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "ufw"|head -1) ]] || apt-get install ufw -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "unzip"|head -1) ]] || apt-get install unzip -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "zip"|head -1) ]] || apt-get install zip -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "lsof"|head -1) ]] || apt-get install lsof -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "apache2"|head -1) ]] || {
        apt-get install apache2 -y &>/dev/null
        sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
        service apache2 restart > /dev/null 2>&1 &
    }
}

funcao_idioma () {
    msg -bar2
    declare -A idioma=( [1]="id Indonesia" [2]="en English" [3]="fr Franch" [4]="de German" [5]="it Italian" [6]="pl Polish" [7]="pt Portuguese" [8]="es Spanish" [9]="tr Turkish" )
    for ((i=1; i<=12; i++)); do
        valor1="$(echo ${idioma[$i]}|cut -d' ' -f2)"
        [[ -z $valor1 ]] && break
        valor1="\033[1;32m[$i] > \033[1;33m$valor1"
        while [[ ${#valor1} -lt 37 ]]; do
            valor1=$valor1" "
        done
        echo -ne "$valor1"
        let i++
        valor2="$(echo ${idioma[$i]}|cut -d' ' -f2)"
        [[ -z $valor2 ]] && {
            echo -e " "
            break
        }
        valor2="\033[1;32m[$i] > \033[1;33m$valor2"
        while [[ ${#valor2} -lt 37 ]]; do
            valor2=$valor2" "
        done
        echo -ne "$valor2"
        let i++
        valor3="$(echo ${idioma[$i]}|cut -d' ' -f2)"
        [[ -z $valor3 ]] && {
            echo -e " "
            break
        }
        valor3="\033[1;32m[$i] > \033[1;33m$valor3"
        while [[ ${#valor3} -lt 37 ]]; do
            valor3=$valor3" "
        done
        echo -e "$valor3"
    done
    msg -bar2
    unset selection
    while [[ ${selection} != @([1-8]) ]]; do
        echo -ne "\033[1;37mPilih: " && read selection
        tput cuu1 && tput dl1
    done
    pv="$(echo ${idioma[$selection]}|cut -d' ' -f1)"
    [[ ${#id} -gt 2 ]] && id="id" || id="$pv"
    byinst="true"
}

install_fim () {
    msg -ama "$(source trans -b pt:${id} "Instalasi Selesai, Gunakan Perintah"|sed -e 's/[^a-z -]//ig')" && msg bar2
    echo -e " menu / adm"
    msg -bar2
}

ofus () {
    unset txtofus
    number=$(expr length $1)
    for((i=1; i<$number+1; i++)); do
        txt[$i]=$(echo "$1" | cut -b $i)
        case ${txt[$i]} in
            ".")txt[$i]="+";;
            "+")txt[$i]=".";;
            "1")txt[$i]="@";;
            "@")txt[$i]="1";;
            "2")txt[$i]="?";;
            "?")txt[$i]="2";;
            "3")txt[$i]="%";;
            "%")txt[$i]="3";;
            "/")txt[$i]="K";;
            "K")txt[$i]="/";;
        esac
        txtofus+="${txt[$i]}"
    done
    echo "$txtofus" | rev
}

verificar_arq () {
    [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
    [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
    [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
    [[ ! -d ${SCPinst} ]] && mkdir ${SCPinst}
    case $1 in
        "menu"|"pesan.txt")ARQ="${SCPdir}/";; #Menu
        "usercodes")ARQ="${SCPusr}/";; #User
        "openssh.sh")ARQ="${SCPinst}/";; #Instalacao
        "apache2.sh")ARQ="${SCPinst}/";; #Instalacao
        "squid.sh")ARQ="${SCPinst}/";; #Instalacao
        "dropbear.sh")ARQ="${SCPinst}/";; #Instalacao
        "openvpn.sh")ARQ="${SCPinst}/";; #Instalacao
        "ssl.sh")ARQ="${SCPinst}/";; #Instalacao
        "shadowsocks.sh")ARQ="${SCPinst}/";; #Instalacao
        "budp.sh")ARQ="${SCPinst}/";; #Instalacao
        "sslh.sh")ARQ="${SCPinst}/";; #Instalacao
        "vnc.sh")ARQ="${SCPinst}/";; #Instalacao
        "webmin.sh")ARQ="${SCPinst}/";; #Instalacao
        "v2ray.sh")ARQ="${SCPinst}/";; #Instalacao
        "sockspy.sh"|"PDirect.py"|"PPub.py"|"PPriv.py"|"POpen.py"|"PGet.py")ARQ="${SCPinst}/";; #Instalacao
        *)ARQ="${SCPfrm}/";; #Ferramentas
    esac
    mv -f ${SCPinstal}/$1 ${ARQ}/$1
    chmod +x ${ARQ}/$1
}

# Instalasi Dimulai
fun_ip
wget -O /usr/bin/trans https://raw.githubusercontent.com/cr4r/ssh/main/Install/trans &> /dev/null
clear
msg -bar2
msg -ama "[ VPN - SSH - CR4R ]    \033[1;37m@cr4r"
[[ $1 = "" ]] && funcao_idioma || {
    [[ ${#1} -gt 2 ]] && funcao_idioma || id="$1"
}
error_fun () {
    msg -bar2 && msg -verm "$(source trans -b pt:${id} "Kunci yang anda gunakan dari server lain!"|sed -e 's/[^a-z -]//ig') " && msg -bar2
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    exit 1
}
invalid_key () {
    msg -bar2 && msg -verm "Key Failed! " && msg -bar2
    [[ -e $HOME/lista-req ]] && rm $HOME/lista-req
    exit 1
}
Key="qra-atsilK?29@%6087%?88d5K8888:%05+08+@@?+91"
REQUEST=$(echo $SCPresq|$SUB_DOM)
echo "$IP" > /usr/bin/vendor_code
cd $HOME
msg -ne "Files: "
wget -O $HOME/lista-req ${REQUEST}/lista-req > /dev/null 2>&1 && echo -e "\033[1;32m Terverifikasi" || {
    echo -e "\033[1;32m Tidak diverifikasi!"
    invalid_key
    exit
}
sleep 1s
updatedb
if [[ -e $HOME/lista-req ]] && [[ ! $(cat $HOME/lista-req|grep "Key Salah!") ]]; then
    msg -bar2
    msg -ama "$(source trans -b pt:${id} "SELAMAT DATANG, TERIMA KASIH TELAH MENGGUNAKAN"|sed -e 's/[^a-z -]//ig'): \033[1;31m[VPN-SSH]"
    [[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}
    pontos="."
    stopping="$(source trans -b pt:${id} "Memeriksa Pembaruan"|sed -e 's/[^a-z -]//ig')"
    for arqx in $(cat $HOME/lista-req); do
        msg -verm "${stopping}${pontos}"
        wget -O ${SCPinstal}/${arqx} ${REQUEST}/${arqx} > /dev/null 2>&1 && verificar_arq "${arqx}" || error_fun
        tput cuu1 && tput dl1
        pontos+="."
    done
    sleep 1s
    msg -bar2
    listaarqs="$(locate "lista-req"|head -1)" && [[ -e ${listaarqs} ]] && rm $listaarqs
    # cat /etc/bash.bashrc|grep -v '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' > /etc/bash.bashrc.2
    # echo -e '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' >> /etc/bash.bashrc.2
    # mv -f /etc/bash.bashrc.2 /etc/bash.bashrc
    echo "${SCPdir}/menu" > /usr/bin/menu && chmod +x /usr/bin/menu
    echo "${SCPdir}/menu" > /usr/bin/cr4r && chmod +x /usr/bin/cr4r
    echo "${SCPdir}/menu" > /bin/h && chmod +x /bin/h
    wget -O $HOME/versi https://raw.githubusercontent.com/cr4r/ssh/main/versi &> /dev/null
    wget -O /bin/versi_script https://raw.githubusercontent.com/cr4r/ssh/main/Install/versi &> /dev/null
    inst_components
    echo "$Key" > ${SCPdir}/key.txt
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    [[ ${#id} -gt 2 ]] && echo "id" > ${SCPidioma} || echo "${id}" > ${SCPidioma}
    [[ ${byinst} = "true" ]] && install_fim
else
    invalid_key
fi