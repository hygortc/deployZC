#!/bin/bash
#
#   usage: deployZC -d DOMAIN -x1 ISRGROOT_PATH -privkey PRIVKEY_PATH -cert CERT_PATH -chain CHAIN_PATH -zimbracomercial COMERCIALKEY_PATH
#    
#   `privkey.pem`  : the private key for your certificate.
#   `fullchain.pem`: the certificate file used in most server software.
#   `chain.pem`    : used for OCSP stapling in Nginx >=1.3.7.
#   `cert.pem`     : will break many server configurations, and should not be used
#                    without reading further documentation (see link below).
#

DOMAIN="webmail.emgtelecom.com.br"
CERTPATH="/etc/letsencrypt/live/$DOMAIN"

PRIVKEY="$CERTPATH/privkey.pem"
CERTIFICATE="$CERTPATH/cert.pem"
CHAIN="$CERTPATH/chain.pem"

COMMERCIALKEY="/opt/zimbra/ssl/zimbra/commercial/commercial.key"
ISRGROOTX1_URL="https://letsencrypt.org/certs/isrgrootx1.pem.txt"
ISRGROOTX1="/tmp/ISRG-X1.pem"
ZMCERTMGR="/opt/zimbra/bin/zmcertmgr"
ZMCONTROL="/opt/zimbra/bin/zmcontrol"

BG_RED="\033[0;41m"

validate="^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$"

while getopts d:x:k:c:k:p:h flag

do
    case "${flag}" in
        d)
        if [[ "${OPTARG}" =~ $validate ]]; then
            DOMAIN=${OPTARG}
            echo $DOMAIN
        else
            echo "O host ${OPTARG} não parece ser valido."
            exit 1
        fi
        ;;
        x) 
            [ -r "${OPTARG}" ] &&  ISRGROOTX1=${OPTARG}; echo $ISRGROOTX1  || echo -e "$BG_RED Verifique se o arquivo existe e a permissão dele "
            ;;
        k)
            [ -r "${OPTARG}" ] &&  PRIVKEY=${OPTARG}; echo $PRIVKEY  || echo -e "$BG_RED Verifique se o arquivo existe e a permissão dele "
                ;;
        c)
           [ -r "${OPTARG}" ] &&  CERTIFICATE=${OPTARG}; echo $CERTIFICATE  || echo -e "$BG_RED Verifique se o arquivo existe e a permissão dele "
            ;;
        p) 
           [ -r "${OPTARG}" ] &&  CHAIN=${OPTARG}; echo $CHAIN  || echo -e "$BG_RED Verifique se o arquivo existe e a permissão dele "
            ;;
        z) 
          [ -r "${OPTARG}" ] &&  COMMERCIALKEY=${OPTARG}; echo $COMMERCIALKEY  || echo -e "$BG_RED Verifique se o arquivo existe e a permissão dele "
            ;;
        h) 
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
          echo "                                                                    "
          echo "  one cup coff in eth wallet                                        "
          echo "                                                                    "
          exit 1
          ;;
        \?) 
            echo "Invalid option: -$OPTARG" >&2 
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2 
            exit 1
            ;;
    esac
done

# sudo -u zimbra $ZMCONTROL stop

# echo -e "\e[1;44mA tualizando chave ISRG-X1 \e[0m"
# [-f /tmp/ISRG-X1.pem  ]
# wget -O  $ISRGROOTX1 $ISRGROOTX1_URL

# echo -e "\e[1;44mA Injetando chave ISRG-X2 na privkey \e[0m"
# cat /tmp/ISRG-X1.pem >> $CHAIN

# echo -e "\e[1;44mA Deploy da commercialkey \e[0m"
# cp $PRIVKEY $COMMERCIALKEY
# chown zimbra:zimbra $COMMERCIALKEY

# echo -e "\e[1;44mA Verificando se o certificado gerado é válido \e[0m"
# sudo -u zimbra $ZMCERTMGR verifycrt comm $COMMERCIALKEY $CERTIFICATE $CHAIN

# echo -e "\e[1;44mA Deploy do certificado \e[0m"
# sudo -u zimbra $ZMCERTMGR deploycrt comm $CERTIFICATE $CHAIN

# sudo -u zimbra $ZMCONTROL start