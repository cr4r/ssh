#!/bin/bash
# Bin _ Gen #OFC
link_bin="https://github.com/cr4r1/ssh/raw/master/instal/generadorcc.py"
[[ ! -e /usr/bin/generadorcc.py ]] && wget -O /usr/bin/generadorcc.py ${link_bin} > /dev/null 2>&1 && chmod +x /usr/bin/generadorcc.py
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
msg -ama "$(fun_trans "GENERATOR BIN OFFICIAL")"
msg -bar
msg -ne "$(fun_trans "Masukkan digit Bin"): " && read UsrBin
while [[ ${#UsrBin} -lt 16 ]]; do
UsrBin+="x"
done
msg -ne "$(fun_trans "Berapa banyak hasil Bin"): " && read GerBin
[[ $GerBin != +([0-9]) ]] && GerBin=10
[[ -z $GerBin ]] && GerBin=10
msg -bar
python /usr/bin/generadorcc.py -b ${UsrBin} -u ${GerBin} -d -c
msg -bar