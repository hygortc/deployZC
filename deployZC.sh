#!/bin/bash
#
#   usage: 
#            deployZC -d DOMAIN
#                               -d zimbra domain                                     
#                               -x ISRG X1 path default: $ISRGROOTX1                 
#                               -k Privkey path default: $PRIVKEY                    
#                               -C Cert path default: $CERTIFICATE                   
#                               -z Zimbra comercial key path default: $COMMERCIALKEY 
#                               -c Cert chain path default: $CHAIN                   
#                               -u zimbra user                                       
#                               -e check expiration date    
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

ACCEPT=false

BG_GREEN=""
BG_YELLOW=""
BG_BLUE=""
BG_RED="\033[0;41m"
CLS_COLOR="\033[0m"


h() {
          echo "                                                                          "
          echo "                                                                          "
          echo "            Deploy let's encrypt cert in  Zimbra                          "
          echo "                                                                          "
          echo "Usage: $0                                                                 "
          echo "                                                                          "
          echo "                                                                          "    
          echo "            -v Display information about what version                     "        
          echo "            -y Display a brief listing of available commands and options. "
          echo "            -d zimbra domain                                              "
          echo "            -x ISRG X1 path default: $ISRGROOTX1                          "
          echo "            -k Privkey path default: $PRIVKEY                             "
          echo "            -C Cert path default: $CERTIFICATE                            "
          echo "            -z Zimbra comercial key path default: $COMMERCIALKEY          "
          echo "            -c Cert chain path default: $CHAIN                            "
          echo "            -u Zimbra user  default: $ZIMBRA_USER                         "
          echo "            -e Check expiration date: use -e domain                       "
          echo "            -y Assume the answer "yes" to any prompts                     "
          echo "                                                                          "
          echo "                                                                          "          
          exit 1
}

execCertbot(){
    echo "certbot..."
}


validate="^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$"

while getopts d:e:x:k:C:k:c:u:y:v:h flag

do
    case "${flag}" in
        d)
        if [[ "${OPTARG}" =~ $validate ]]; then
            DOMAIN=${OPTARG}
        else
            echo -e "$BG_RED O host ${OPTARG} não parece ser valido. $CLS_COLOR"
            exit 1
        fi
        ;;
        v)
            echo -e " deployZC v1.0 https://github.com/hygortc/deployZC "
        ;;
        x)
            [ -r "${OPTARG}" ] &&  ISRGROOTX1=${OPTARG}; echo $ISRGROOTX1  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        k)
            [ -r "${OPTARG}" ] &&  PRIVKEY=${OPTARG}; echo $PRIVKEY  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        C)
            [ -r "${OPTARG}" ] &&  CERTIFICATE=${OPTARG}; echo $CERTIFICATE  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        c) 
            [ -r "${OPTARG}" ] &&  CHAIN=${OPTARG}; echo $CHAIN  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        z) 
            [ -r "${OPTARG}" ] &&  COMMERCIALKEY=${OPTARG}; echo $COMMERCIALKEY  || echo -e "$BG_RED Verifique se o arquivo existe e as permissão dele $CLS_COLOR"
            ;;
        u)
            ZIMBRA_USER=${OPTARG}
            ;;
        y)
            ACCEPT=true
        ;;
        e)   
            if [ -x /usr/bin/curl ]; then
                expiration_date=$(command curl https://${DOMAIN} -vI --stderr - | grep "expire date" | cut -d":" -f 2-)
                dayOffexpiration=$(( ($(date -d "$expiration_date" +%s) - $(date +%s))/(60*60*24) ))
                
                if [ $dayOffexpiration -le 1 ]; then 
                   if ![ $ACCEPT ]; then
                     echo -e "$BG_RED O certificado vai expirar em $dayOffexpiration dias deseja renovar o certificado? S/n $CLS_COLOR"; 
                     read optionYn;
                     [$optionYn == "y"]: execCertbot
                     exit 1
                fi
                 execCertbot
                else
                    echo -e "Ainda falta $dayOffexpiration dias"
                fi

            else 
                echo -e "$BG_RED Curl obrigatorio! $CLS_COLOR"
            fi
            ;;  
        h) 
            h
            ;;
        \?) 
            echo -e "$BG_RED Invalid option: -$OPTARG $CLS_COLOR" >&2 
            h
            ;;
        :)
            echo -e "$BG_RED Option -$OPTARG requires an argument. $CLS_COLOR" >&2 
            h
            ;;
        *)
            h
            ;;
    esac
done

# sudo -u $ZIMBRA_USER $ZMCONTROL stop

# [! -r $ISRGROOTX1  ] && wget -O $ISRGROOTX1 $ISRGROOTX1_URL

# echo -e "\e[1;44mA Injetando chave ISRG-X2 na privkey \e[0m"
# [ -r $CHAIN  && -r $ISRGROOTX1 ] && cat $ISRGROOTX1 $CHAIN >$CHAIN_ISRG || echo -e "O arquivo não existe ou não tem permissão de leitura \n $CHAIN \n $ISRGROOTX1"; exit 1

# echo -e "\e[1;44mA Deploy da commercialkey \e[0m"

# [[-r $PRIVKEY ]] && cat $PRIVKEY >$COMMERCIALKEY;chown $ZIMBRA_USER:$ZIMBRA_USER $COMMERCIALKEY || echo -e "O arquivo não existe ou não tem permissão de leitura \n $PRIVKEY"; exit 1

# echo -e "\e[1;44mA Verificando se o certificado gerado é válido \e[0m"
# sudo -u $ZIMBRA_USER $ZMCERTMGR verifycrt comm $COMMERCIALKEY $CERTIFICATE $CHAIN_ISRG

# echo -e "\e[1;44mA Deploy do certificado \e[0m"
# sudo -u $ZIMBRA_USER $ZMCERTMGR deploycrt comm $CERTIFICATE $CHAIN_ISRG

# sudo -u $ZIMBRA_USER $ZMCONTROL start
