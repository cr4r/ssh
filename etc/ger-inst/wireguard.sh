#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

#LISTA PORTAS
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

function isRoot() {
	if [ "${EUID}" -ne 0 ]; then
		echo "$(fun_trans "Kau harus jalankan script ini mode root")"
		exit 1
	fi
}

function checkVirt() {
	if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "$(fun_trans "OpenVZ tidak support")"
		exit 1
	fi

	if [ "$(systemd-detect-virt)" == "lxc" ]; then
		echo "$(fun_trans" LXC belum didukung (belum). ")"
		echo "$(fun_trans" WireGuard secara teknis dapat dijalankan dalam wadah LXC, ")"
		echo "$(fun_trans" tetapi modul kernel harus diinstal pada host, ")"
		echo "$(fun_trans" penampung harus dijalankan dengan beberapa parameter tertentu ")"
		echo "$(fun_trans" dan hanya alat yang perlu diinstal di wadah. ")"
		exit 1
	fi
}

function checkOS() {
	# Check OS version
	if [[ -e /etc/debian_version ]]; then
		source /etc/os-release
		OS="${ID}" # debian or ubuntu
		if [[ ${ID} == "debian" || ${ID} == "raspbian" ]]; then
			if [[ ${VERSION_ID} -ne 10 ]]; then
				msg -ama "$(fun_trans "Versi debian") (${VERSION_ID}) $(fun_trans "tidak mendukung. Gunakan debian 10 Buster")"
				exit 1
			fi
		fi
	elif [[ -e /etc/fedora-release ]]; then
		source /etc/os-release
		OS="${ID}"
	elif [[ -e /etc/centos-release ]]; then
		OS=centos
	elif [[ -e /etc/arch-release ]]; then
		OS=arch
	else
		echo "$(fun_trans "Sepertinya Anda tidak menjalankan penginstal ini di sistem Debian, Ubuntu, Fedora, CentOS, atau Arch Linux ")"
		exit 1
	fi
}

function initialCheck() {
	isRoot
	checkVirt
	checkOS
}

meu_ip () {
if [[ -e /etc/MEUIPADM ]]; then
echo "$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}

function installQuestions() {
	msg -ama "$(fun_trans "Selamat datang di menu instalasi WireGuard")"
	msg -bar
	# Detect public IPv4 or IPv6 address and pre-fill for the user
	SERVER_PUB_IP=$(meu_ip)
	read -rp "$(fun_trans "Apakah benar ip publik anda"): " -e -i "${SERVER_PUB_IP}" SERVER_PUB_IP

	# Detect public interface and pre-fill for the user
	SERVER_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
	until [[ ${SERVER_PUB_NIC} =~ ^[a-zA-Z0-9_]+$ ]]; do
		read -rp "$(fun_trans "Public interface"): " -e -i "${SERVER_NIC}" SERVER_PUB_NIC
	done

	until [[ ${SERVER_WG_NIC} =~ ^[a-zA-Z0-9_]+$ ]]; do
		read -rp "$(fun_trans "WireGuard interface name"): " -e -i wg0 SERVER_WG_NIC
	done

	until [[ ${SERVER_WG_IPV4} =~ ^([0-9]{1,3}\.){3} ]]; do
		read -rp "$(fun_trans "Server's WireGuard IPv4"): " -e -i 10.66.66.1 SERVER_WG_IPV4
	done

	until [[ ${SERVER_WG_IPV6} =~ ^([a-f0-9]{1,4}:){3,4}: ]]; do
		read -rp "$(fun_trans "Server's WireGuard IPv6"): " -e -i fd42:42:42::1 SERVER_WG_IPV6
	done

	# Generate random number within private ports range
	RANDOM_PORT=$(shuf -i49152-65535 -n1)
	until [[ ${SERVER_PORT} =~ ^[0-9]+$ ]] && [ "${SERVER_PORT}" -ge 1 ] && [ "${SERVER_PORT}" -le 65535 ]; do
		read -rp "$(fun_trans "Server's WireGuard port") [1-65535]: " -e -i "${RANDOM_PORT}" SERVER_PORT
	done

	# Adguard DNS by default
	until [[ ${CLIENT_DNS_1} =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; do
		read -rp "$(fun_trans "DNS pertama untuk client") (default Adguard): " -e -i 176.103.130.130 CLIENT_DNS_1
	done
	until [[ ${CLIENT_DNS_2} =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; do
		read -rp "$(fun_trans "DNS Kedua untuk client") (default Adguard): " -e -i 176.103.130.131 CLIENT_DNS_2
		if [[ ${CLIENT_DNS_2} == "" ]]; then
			CLIENT_DNS_2="${CLIENT_DNS_1}"
		fi
	done

	msg -bar
	msg -ama "$(fun_trans "Oke, hanya itu yang saya butuhkan. Kami siap menyiapkan server WireGuard Anda sekarang.")"
	msg -ama "$(fun_trans "Anda akan dapat membuat klien di akhir penginstalan.")"
	read -n1 -r -p "Press any key to continue..."
}

function installWireGuard() {
	# Run setup questions first
	installQuestions

	# Install WireGuard tools and module
	if [[ ${OS} == 'ubuntu' ]]; then
		apt-get update &>/dev/null
		apt-get install -y wireguard iptables resolvconf qrencode &>/dev/null
	elif [[ ${OS} == 'debian' ]]; then
		if ! grep -rqs "^deb .* buster-backports" /etc/apt/; then
			echo "deb http://deb.debian.org/debian buster-backports main" >/etc/apt/sources.list.d/backports.list
			apt-get update &>/dev/null
		fi
		apt update &>/dev/null
		apt-get install -y iptables resolvconf qrencode &>/dev/null
		apt-get install -y -t buster-backports wireguard &>/dev/null
	elif [[ ${OS} == 'fedora' ]]; then
		if [[ ${VERSION_ID} -lt 32 ]]; then
			dnf install -y dnf-plugins-core &>/dev/null
			dnf copr enable -y jdoss/wireguard &>/dev/null
			dnf install -y wireguard-dkms &>/dev/null
		fi
		dnf install -y wireguard-tools iptables qrencode &>/dev/null
	elif [[ ${OS} == 'centos' ]]; then
		curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo &>/dev/null
		yum -y install epel-release kernel kernel-devel kernel-headers &>/dev/null
		yum -y install wireguard-dkms wireguard-tools iptables qrencode &>/dev/null
	elif [[ ${OS} == 'arch' ]]; then
		pacman -S --noconfirm linux-headers &>/dev/null
		pacman -S --noconfirm wireguard-tools iptables qrencode &>/dev/null
	fi

	# Make sure the directory exists (this does not seem the be the case on fedora)
	mkdir -p /etc/wireguard >/dev/null 2>&1

	chmod 600 -R /etc/wireguard/

	SERVER_PRIV_KEY=$(wg genkey)
	SERVER_PUB_KEY=$(echo "${SERVER_PRIV_KEY}" | wg pubkey)

	# Save WireGuard settings
	echo "SERVER_PUB_IP=${SERVER_PUB_IP}
SERVER_PUB_NIC=${SERVER_PUB_NIC}
SERVER_WG_NIC=${SERVER_WG_NIC}
SERVER_WG_IPV4=${SERVER_WG_IPV4}
SERVER_WG_IPV6=${SERVER_WG_IPV6}
SERVER_PORT=${SERVER_PORT}
SERVER_PRIV_KEY=${SERVER_PRIV_KEY}
SERVER_PUB_KEY=${SERVER_PUB_KEY}
CLIENT_DNS_1=${CLIENT_DNS_1}
CLIENT_DNS_2=${CLIENT_DNS_2}" >/etc/wireguard/params

	# Add server interface
	echo "[Interface]
Address = ${SERVER_WG_IPV4}/24,${SERVER_WG_IPV6}/64
ListenPort = ${SERVER_PORT}
PrivateKey = ${SERVER_PRIV_KEY}" >"/etc/wireguard/${SERVER_WG_NIC}.conf"

	if pgrep firewalld; then
		FIREWALLD_IPV4_ADDRESS=$(echo "${SERVER_WG_IPV4}" | cut -d"." -f1-3)".0"
		FIREWALLD_IPV6_ADDRESS=$(echo "${SERVER_WG_IPV6}" | sed 's/:[^:]*$/:0/')
		echo "PostUp = firewall-cmd --add-port ${SERVER_PORT}/udp && firewall-cmd --add-rich-rule='rule family=ipv4 source address=${FIREWALLD_IPV4_ADDRESS}/24 masquerade' && firewall-cmd --add-rich-rule='rule family=ipv6 source address=${FIREWALLD_IPV6_ADDRESS}/24 masquerade'
PostDown = firewall-cmd --remove-port ${SERVER_PORT}/udp && firewall-cmd --remove-rich-rule='rule family=ipv4 source address=${FIREWALLD_IPV4_ADDRESS}/24 masquerade' && firewall-cmd --remove-rich-rule='rule family=ipv6 source address=${FIREWALLD_IPV6_ADDRESS}/24 masquerade'" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
	else
		echo "PostUp = iptables -A FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; iptables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE; ip6tables -A FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
PostDown = iptables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; iptables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE; ip6tables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
	fi

	# Enable routing on the server
	echo "net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >/etc/sysctl.d/wg.conf

	sysctl --system &>/dev/null

	systemctl start "wg-quick@${SERVER_WG_NIC}" &>/dev/null
	systemctl enable "wg-quick@${SERVER_WG_NIC}" &>/dev/null

	# Check if WireGuard is running
	systemctl is-active --quiet "wg-quick@${SERVER_WG_NIC}" &>/dev/null
	WG_RUNNING=$?

	# WireGuard might not work if we updated the kernel. Tell the user to reboot
	if [[ ${WG_RUNNING} -ne 0 ]]; then
		msg -ama "$(fun_trans "PERINGATAN: WireGuard sepertinya tidak berjalan.")"
		msg -ama "$(fun_trans "Anda dapat memeriksa apakah WireGuard berjalan dengan: status systemctl wg-quick@${SERVER_WG_NIC}")"
		msg -ama "$(fun_trans "Jika Anda mendapatkan sesuatu seperti") \" $(fun_trans "Tidak dapat menemukan perangkat") ${SERVER_WG_NIC}\", silakan reboot!"
	fi
	newClient
	msg -ama "$(fun_trans "Jika Anda ingin menambahkan lebih banyak klien, Anda hanya perlu menjalankan skrip ini lain kali")!"
}

function newClient() {
	ENDPOINT="${SERVER_PUB_IP}:${SERVER_PORT}"

	msg -bar
	msg -ama "$(fun_trans "Beri tahu saya nama untuk klien")."
	msg -ama "$(fun_trans "Nama harus terdiri dari karakter alfanumerik. Ini mungkin juga termasuk garis bawah atau setrip")."

	until [[ ${CLIENT_NAME} =~ ^[a-zA-Z0-9_-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "$(fun_trans "Nama Klien:") " -e CLIENT_NAME
		CLIENT_EXISTS=$(grep -c -E "^### Client ${CLIENT_NAME}\$" "/etc/wireguard/${SERVER_WG_NIC}.conf")

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			msg -bar
			msg -ama "$(fun_trans "Klien dengan nama yang ditentukan telah dibuat, pilih nama lain.")"
			msg -bar
		fi
	done

	for DOT_IP in {2..254}; do
		DOT_EXISTS=$(grep -c "${SERVER_WG_IPV4::-1}${DOT_IP}" "/etc/wireguard/${SERVER_WG_NIC}.conf")
		if [[ ${DOT_EXISTS} == '0' ]]; then
			break
		fi
	done

	if [[ ${DOT_EXISTS} == '1' ]]; then
		msg -bar
		msg -ama "$(fun_trans "Subnet dikonfigurasi hanya mendukung 253 klien.")"
		exit 1
	fi

	until [[ ${IPV4_EXISTS} == '0' ]]; do
		read -rp "$(fun_trans "Klient Wireguard IPv4"): ${SERVER_WG_IPV4::-1}" -e -i "${DOT_IP}" DOT_IP
		CLIENT_WG_IPV4="${SERVER_WG_IPV4::-1}${DOT_IP}"
		IPV4_EXISTS=$(grep -c "$CLIENT_WG_IPV4" "/etc/wireguard/${SERVER_WG_NIC}.conf")

		if [[ ${IPV4_EXISTS} == '1' ]]; then
			msg -ama "$(fun_trans "Klien dengan IPv4 yang ditentukan telah dibuat, pilih IPv4 lain.")"
		fi
	done

	until [[ ${IPV6_EXISTS} == '0' ]]; do
		read -rp "$(fun_trans "Client Wireguard IPv6"): ${SERVER_WG_IPV6::-1}" -e -i "${DOT_IP}" DOT_IP
		CLIENT_WG_IPV6="${SERVER_WG_IPV6::-1}${DOT_IP}"
		IPV6_EXISTS=$(grep -c "${CLIENT_WG_IPV6}" "/etc/wireguard/${SERVER_WG_NIC}.conf")

		if [[ ${IPV6_EXISTS} == '1' ]]; then
			mgs -ama "$(fun_trans "Klien dengan IPv6 yang ditentukan telah dibuat, pilih IPv6 lain.")"
		fi
	done

	# Generate key pair for the client
	CLIENT_PRIV_KEY=$(wg genkey)
	CLIENT_PUB_KEY=$(echo "${CLIENT_PRIV_KEY}" | wg pubkey)
	CLIENT_PRE_SHARED_KEY=$(wg genpsk)

	# Home directory of the user, where the client configuration will be written
	if [ -e "/home/${CLIENT_NAME}" ]; then # if $1 is a user name
		HOME_DIR="/home/${CLIENT_NAME}"
	elif [ "${SUDO_USER}" ]; then # if not, use SUDO_USER
		HOME_DIR="/home/${SUDO_USER}"
	else # if not SUDO_USER, use /root
		HOME_DIR="/root"
	fi

	# Create client file and add the server as a peer
	echo "[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128
DNS = ${CLIENT_DNS_1},${CLIENT_DNS_2}

[Peer]
PublicKey = ${SERVER_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
Endpoint = ${ENDPOINT}
AllowedIPs = 0.0.0.0/0,::/0" >>"${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"

	# Add the client as a peer to the server
	echo -e "\n### Client ${CLIENT_NAME}
[Peer]
PublicKey = ${CLIENT_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
AllowedIPs = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"

	systemctl restart "wg-quick@${SERVER_WG_NIC}" &>/dev/null

	msg -ama "$(fun_trans "Ini adalah file konfigurasi klien Anda sebagai Kode QR"):"

	qrencode -t ansiutf8 -l L <"${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"

	msg -ama "$(fun_trans "Konfigurasi tersimpan di") ${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"
}

function revokeClient() {
	NUMBER_OF_CLIENTS=$(grep -c -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		msg -ama "$(fun_trans "Belum ada klien")!"
		exit 1
	fi

	msg -ama "$(fun_trans "Pilih klien yang ada yang ingin Anda hapus")"
	grep -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf" | cut -d ' ' -f 3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "$(fun_trans "Pilih satu klien") [1]: " CLIENT_NUMBER
		else
			read -rp "$(fun_trans "pilih satu klien") [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done

	# match the selected number to a client name
	CLIENT_NAME=$(grep -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

	# remove [Peer] block matching $CLIENT_NAME
	sed -i "/^### Client ${CLIENT_NAME}\$/,/^$/d" "/etc/wireguard/${SERVER_WG_NIC}.conf"

	# remove generated client file
	rm -f "${HOME}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"

	# restart wireguard to apply changes
	systemctl restart "wg-quick@${SERVER_WG_NIC}" &>/dev/null
}

function uninstallWg() {
	checkOS
	msg -bar
	msg -ama " $(fun_trans "Menghapus Wireguard")"
	systemctl stop "wg-quick@${SERVER_WG_NIC}" &>/dev/null
	systemctl disable "wg-quick@${SERVER_WG_NIC}" &>/dev/null

	if [[ ${OS} == 'ubuntu' ]]; then
		apt-get autoremove --purge -y wireguard qrencode &>/dev/null
	elif [[ ${OS} == 'debian' ]]; then
		apt-get autoremove --purge -y wireguard qrencode &>/dev/null
	elif [[ ${OS} == 'fedora' ]]; then
		dnf remove -y wireguard-tools qrencode &>/dev/null
		if [[ ${VERSION_ID} -lt 32 ]]; then
			dnf remove -y wireguard-dkms &>/dev/null
			dnf copr disable -y jdoss/wireguard &>/dev/null
		fi
		dnf autoremove -y &>/dev/null
	elif [[ ${OS} == 'centos' ]]; then
		yum -y remove wireguard-dkms wireguard-tools qrencode &>/dev/null
		rm -f "/etc/yum.repos.d/wireguard.repo" &>/dev/null
		yum -y autoremove &>/dev/null
	elif [[ ${OS} == 'arch' ]]; then
		pacman -Rs --noconfirm wireguard-tools qrencode &>/dev/null
	fi

	rm -rf /etc/wireguard &>/dev/null
	rm -f /etc/sysctl.d/wg.conf &>/dev/null

	# Reload sysctl
	sysctl --system &>/dev/null

	# Check if WireGuard is running
	systemctl is-active --quiet "wg-quick@${SERVER_WG_NIC}" &>/dev/null
	WG_RUNNING=$?

	if [[ ${WG_RUNNING} -eq 0 ]]; then
		msg -ama "$(fun_trans "WireGuard failed to uninstall properly.")"
		exit 1
	else
		msg -ama "$(fun_trans "WireGuard uninstalled successfully.")"
		exit 0
	fi
	msg -bar
	msg -ama "$(fun_trans "Wireguard selesai dihapus")"
}

function manageMenu() {
	msg -ama " $(fun_trans "Welcome to WireGuard-install")"
	msg -ama " 1 $(fun_trans "Tambahkan user baru")"
	msg -ama " 2 $(fun_trans "Hapus user")"
	msg -ama " 3 $(fun_trans "Uninstall WireGuard")"
	msg -ama " 4 $(fun_trans "Keluar")"
	until [[ ${MENU_OPTION} =~ ^[1-4]$ ]]; do
		read -rp "Option [1-4]: " MENU_OPTION
	done
	case "${MENU_OPTION}" in
	1)
		newClient
		;;
	2)
		revokeClient
		;;
	3)
		uninstallWg
		;;
	4)
		exit 0
		;;
	esac
}

# Check for root, virt, OS...
initialCheck

# Check if WireGuard is already installed and load params
if [[ -e /etc/wireguard/params ]]; then
	source /etc/wireguard/params
	manageMenu
else
	installWireGuard
fi
