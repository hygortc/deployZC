#!/bin/bash
#
#   usage: deployZC -d DOMAIN -x ISRGROOT_PATH -p PRIVKEY_PATH -c CERT_PATH -k CHAIN_PATH -z COMERCIALKEY_PATH
#    
#   `privkey.pem`  : the private key for your certificate.
#   `fullchain.pem`: the certificate file used in most server software.
#   `chain.pem`    : used for OCSP stapling in Nginx >=1.3.7.
#   `cert.pem`     : will break many server configurations, and should not be used
#                    without reading further documentation (see link below).
#

DOMAIN=""
CERTPATH="/etc/letsencrypt/live/$DOMAIN"

PRIVKEY="$CERTPATH/privkey.pem"
CERTIFICATE="$CERTPATH/cert.pem"
CHAIN="$CERTPATH/chain.pem"

COMMERCIALKEY="/opt/zimbra/ssl/zimbra/commercial/commercial.key"
ISRGROOTX1_URL="https://letsencrypt.org/certs/isrgrootx1.pem.txt"
ISRGROOTX1="/tmp/ISRG-X1.pem"

CHAIN_ISRG="/tmp/chain_ISRG-X1.pem"
ZIMBRA_USER="zimbra"
ZMCERTMGR="/opt/zimbra/bin/zmcertmgr"
ZMCONTROL="/opt/zimbra/bin/zmcontrol"

BG_RED="\033[0;41m"
CLS_COLOR="\033[0m"


help() {
          echo "                                                                    "
          echo "                                                                    "
          echo "            Deploy let's encrypt cert in  Zimbra                    "
          echo "                                                                    "
          echo "Usage: $0                                                           "
          echo "            -d zimbra domain                                        "
          echo "            -x ISRG X1 path default: $ISRGROOTX1                    "
          echo "            -k Privkey path default: $PRIVKEY                       "
          echo "            -c Cert path default: $CERTIFICATE                      "
          echo "            -z Zimbra comercial key path default: $COMMERCIALKEY    "
          echo "            -p Cert chain path default: $CHAIN                      "
          echo "            -u zimbra user                                          "
          echo "                                                                    "
          exit 1
}
validate="^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$"

while getopts d:x:k:c:k:p:u:h flag

do
    case "${flag}" in
        d)
        if [[ "${OPTARG}" =~ $validate ]]; then
            DOMAIN=${OPTARG}
            echo $DOMAIN
        else
            echo -e "$BG_RED O host ${OPTARG} não parece ser valido. $CLS_COLOR"
            exit 1
        fi
        ;;
        x) 
            [ -r "${OPTARG}" ] &&  ISRGROOTX1=${OPTARG}; echo $ISRGROOTX1  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        k)
            [ -r "${OPTARG}" ] &&  PRIVKEY=${OPTARG}; echo $PRIVKEY  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
                ;;
        c)
           [ -r "${OPTARG}" ] &&  CERTIFICATE=${OPTARG}; echo $CERTIFICATE  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        p) 
           [ -r "${OPTARG}" ] &&  CHAIN=${OPTARG}; echo $CHAIN  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        z) 
          [ -r "${OPTARG}" ] &&  COMMERCIALKEY=${OPTARG}; echo $COMMERCIALKEY  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        u)
          ZIMBRA_USER=${OPTARG}
            ;;
        h) 
            help
          ;;
        \?) 
            echo -e "$BG_RED Invalid option: -$OPTARG $CLS_COLOR" >&2 
            help
            ;;
        :)
            echo -e "$BG_RED Option -$OPTARG requires an argument. $CLS_COLOR" >&2 
            help
            ;;
        *)
            help
            ;;
    esac
done

sudo -u zimbra $ZMCONTROL stop

[! -r $ISRGROOTX1  ] && wget -O $ISRGROOTX1 $ISRGROOTX1_URL

echo -e "\e[1;44mA Injetando chave ISRG-X2 na privkey \e[0m"
[ -r $CHAIN  && -r $ISRGROOTX1 ] && cat $ISRGROOTX1 $CHAIN >$CHAIN_ISRG || echo -e "O arquivo não existe ou não tem permissão de leitura \n $CHAIN \n $ISRGROOTX1"; exit 1

echo -e "\e[1;44mA Deploy da commercialkey \e[0m"

[[-r $PRIVKEY ]] && cat $PRIVKEY >$COMMERCIALKEY;chown $ZIMBRA_USER:$ZIMBRA_USER $COMMERCIALKEY || echo -e "O arquivo não existe ou não tem permissão de leitura \n $PRIVKEY"; exit 1

echo -e "\e[1;44mA Verificando se o certificado gerado é válido \e[0m"
sudo -u $ZIMBRA_USER $ZMCERTMGR verifycrt comm $COMMERCIALKEY $CERTIFICATE $CHAIN

echo -e "\e[1;44mA Deploy do certificado \e[0m"
sudo -u $ZIMBRA_USER $ZMCERTMGR deploycrt comm $CERTIFICATE $CHAIN

sudo -u $ZIMBRA_USER $ZMCONTROL start