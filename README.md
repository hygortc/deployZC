# deployZC
Deploy let's encrypt cert in  Zimbra

Usage: ./deployZC.sh
            -d zimbra domain
            -x ISRG X1 path default: /tmp/ISRG-X1.pem
            -k Privkey path default: /etc/letsencrypt/live/webmail.emgtelecom.com.br/privkey.pem
            -c Cert path default: /etc/letsencrypt/live/webmail.emgtelecom.com.br/cert.pem
            -z Zimbra comercial key path default: /opt/zimbra/ssl/zimbra/commercial/commercial.key
            -p Cert chain path default: /etc/letsencrypt/live/webmail.emgtelecom.com.br/chain.pem
