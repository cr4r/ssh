#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/cr4r" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPbahasa="${SCPdir}/bahasa" && [[ ! -e ${SCPbahasa} ]] && touch ${SCPbahasa}
fun_ip () {
    MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
    [[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
}
IP="$(fun_ip)"
clear
clear
msg -bar
msg -azu "$(fun_trans "GERENCIAR ARQUIVO ONLINE")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "COLOCAR ARQUIVO ONLINE")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "REMOVER ARQUIVO ONLINE")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "VER LINKS DOS ARQUIVOS ONLINE")"
msg -bar
while [[ ${arquivoonlineadm} != @([0-3]) ]]; do
    read -p "[0-3]: " arquivoonlineadm
    tput cuu1 && tput dl1
done
case ${arquivoonlineadm} in
    0)
        exit
    ;;
    3)
        [[ -z $(ls /var/www/html) ]] && msg -bar  || {
            for my_arqs in `ls /var/www/html`; do
                [[ "$my_arqs" = "index.html" ]] && continue
                [[ "$my_arqs" = "index.php" ]] && continue
                [[ -d "$my_arqs" ]] && continue
                echo -e "\033[1;31m[$my_arqs] \033[1;36mhttp://$IP:81/$my_arqs\033[0m"
            done
            msg -bar
        }
    ;;
    2)
        i=1
        [[ -z $(ls /var/www/html) ]] && msg -bar  || {
            for my_arqs in `ls /var/www/html`; do
                [[ "$my_arqs" = "index.html" ]] && continue
                [[ "$my_arqs" = "index.php" ]] && continue
                [[ -d "$my_arqs" ]] && continue
                select_arc[$i]="$my_arqs"
                echo -e "${cor[2]}[$i] > ${cor[3]}$my_arqs - \033[1;36mhttp://$IP:81/$my_arqs\033[0m"
                let i++
            done
            msg -bar
            echo -e "${cor[5]}$(fun_trans "Selecione o Arquivo a Ser Apagado")"
            msg -bar
            while [[ -z ${select_arc[$slct]} ]]; do
                read -p " [1-$i]: " slct
                tput cuu1 && tput dl1
            done
            arquivo_move="${select_arc[$slct]}"
            [[ -d /var/www/html ]] && [[ -e /var/www/html/$arquivo_move ]] && rm -rf /var/www/html/$arquivo_move > /dev/null 2>&1
            [[ -e /var/www/$arquivo_move ]] && rm -rf /var/www/$arquivo_move > /dev/null 2>&1
            echo -e "${cor[5]}$(fun_trans "Sucesso!")"
            msg -bar
        }
    ;;
    1)
        i="1"
        [[ -z $(ls $HOME) ]] && msg -bar  || {
            for my_arqs in `ls $HOME`; do
                [[ -d "$my_arqs" ]] && continue
                select_arc[$i]="$my_arqs"
                echo -e "${cor[2]} [$i] > ${cor[3]}$my_arqs"
                let i++
            done
            i=$(($i - 1))
            echo -e "${cor[5]}$(fun_trans "selecione o arquivo")"
            msg -bar
            while [[ -z ${select_arc[$slct]} ]]; do
                read -p " [1-$i]: " slct
                tput cuu1 && tput dl1
            done
            arquivo_move="${select_arc[$slct]}"
            [ ! -d /var ] && mkdir /var
            [ ! -d /var/www ] && mkdir /var/www
            [ ! -d /var/www/html ] && mkdir /var/www/html
            [ ! -e /var/www/html/index.html ] && touch /var/www/html/index.html
            [ ! -e /var/www/index.html ] && touch /var/www/index.html
            chmod -R 755 /var/www
            cp $HOME/$arquivo_move /var/www/$arquivo_move
            cp $HOME/$arquivo_move /var/www/html/$arquivo_move
            echo -e "\033[1;36m http://$IP:81/$arquivo_move\033[0m"
            msg -bar
            echo -e "${cor[5]}$(fun_trans "Sucesso!")"
            msg -bar
        }
    ;;
esac
