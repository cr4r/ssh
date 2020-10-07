#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" [5]="\033[1;33m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
while :
do
#menu banner
clear
echo -e "$barra"
echo -e "${cor[3]} HOST EXTRACTOR ${cor[2]}[NEW-ADM]"
echo -e "${cor[5]} Actualiza tu Extrator menu 7 y 8 antes de usar"
echo -e "$barra"
echo -e "${cor[2]}[1] ${cor[4]}> ${cor[3]}Extract HOST & SSL"
echo -e "${cor[2]}[2] ${cor[4]}> ${cor[3]}Simpan HOSTS Extra"
echo -e "${cor[2]}[3] ${cor[4]}> ${cor[3]}Perlihatkan STATUS Web"
echo -e "${cor[2]}[4] ${cor[4]}> ${cor[3]}Hasilkan Fungsi PAYLOAD"
echo -e "${cor[2]}[5] ${cor[4]}> ${cor[3]}Lihat WEB & HOST"
echo -e "${cor[2]}[6] ${cor[4]}> ${cor[3]}Lihat PROXY HOST & WEB"
echo -e "${cor[2]}[7] ${cor[4]}> ${cor[3]}Update paket HOST EXTRACTOR"
echo -e "${cor[2]}[8] ${cor[4]}> ${cor[3]}Perbarui HOST EXTRACTOR"
echo -e "${cor[2]}[9] ${cor[4]}> ${cor[3]}Panduan Pengguna HOST EXTRACTOR"
echo -e "${cor[2]}[0] ${cor[4]}> ${cor[0]}Kembali Menu"
echo -e "$barra"
echo -n "Pilih => "
read opcion
#lista de menu
echo -e "\e[0m"
case $opcion in

1)
echo -e "\e[1;33m"
echo -n "HOST: ";
read HOST;
bash /etc/hostextractor/.scan.sh $HOST
echo ""
echo -e "\e[0m";
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan";
read foo
;;

2)
echo -e "\e[1;33mMasukkan status host\e[0m";
echo -e "\e[1;33mIngatlah untuk menekan CTRL + C\e[0m";
echo -e "\e[1;33mUntuk menyimpan dan keluar lalu ucapkan adm\e[0m";
echo -e "\e[1;33mUntuk kembali ke menu dan masuk kembali ke Extractor\e[0m";
echo -e "$barra"
echo -e "\e[1;36mHOST: \e[0m";
cat>lista-host.txt
;;

3)
echo "Menampilkan status Host";
echo ""
bash /etc/hostextractor/.status.sh
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan"
read foo
;;

4)
bash /etc/hostextractor/.payloads
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan"
read foo;
;;

5)
echo -ne "\e[1;31m Domain(IP/WEB): ";
read NIO
echo -ne "\e[1;31m Port(contoh: 53,80):  ";
read TOS
sleep 2
echo -e "\e[1;32m";
nmap -p $TOS $NIO
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan" 
read foo
;;

6)
echo -ne "\e[1;31mSitus WEB/IP: ";
read WEB
echo ""
echo -e "\e[1;32m"
curl https://api.hackertarget.com/geoip/?q=$WEB
echo ""
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan" 
read foo
;;

7)
echo -ne "\033[1;36mMemperbarui Paket Pengekstrak Host"
echo ""
echo ""
apt-get update -y > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1
apt-get install nmap -y > /dev/null 2>&1
apt-get install wget -y > /dev/null 2>&1
apt-get install curl > /dev/null 2>&1
apt-get install git -y > /dev/null 2>&1
echo -e "\033[1;31m apt-get package \033[1;32m[ ! ] OK"
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan" 
read foo
;;

8)
echo -ne "\033[1;36mMemperbarui Host Extractor"
echo ""
echo ""
rm -rf $HOME/hostextractor/ > /dev/null 2>&1
rm -rf /etc/hostextractor
wget -O $HOME/hostextractor.tgz https://raw.githubusercontent.com/cr4r1/ssh/master/instal/hostextractor.tgz > /dev/null 2>&1
tar -xvf hostextractor.tgz > /dev/null 2>&1
rm -rf $HOME/hostextractor.tgz > /dev/null 2>&1
mv $HOME/hostextractor/ /etc/ > /dev/null 2>&1
rm -rf $HOME/hostextractor/ > /dev/null 2>&1
echo -e "\033[1;31m Host Extractor \033[1;32m[ ! ] OK"
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan" 
read foo
;;

9)
echo -e "\e[1;36m OPCIONES:"
echo -e "\e[1;32m"
echo "[1] Extrae url de sitios web como http y https"
echo "[2] Un bloc para agregar sitios web "
echo "[3] Muestra estatus de sitios web"
echo "[4] Genera payload funcionales de sitios web / host"
echo "[5] Muestra los puertos que esta abiertos en servicios web / IP/ proxy"
echo " - Poner una coma despu�s de cada puerto, ejemplo: 22,53,442,443,80,8080,3128"
echo "[6] Ver proxy o informacion de un sitio web o IP"
echo "[7] Actualizar paqueteria de host-extractor"
echo "[8] Actualizar script host-extractor"
echo "[9] Manual de como usar el script host-extractor"
echo "[0] Salir del menu 0 y 0 salir del menu en espa�ol"
echo ""
echo -e "$barra"
echo -e "\e[1;31mEnter untuk melanjutkan" 
read foo
;;

25)clear
echo -e "\e[1;32mIngresando al menu secreto...";
sleep 2
bash ._
read foo
;;

0)
exit 0;;
#error

*)clear
echo "Invalid command...";
sleep 1
;;

esac
done