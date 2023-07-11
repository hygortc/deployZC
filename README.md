# deployZC
Deploy let's encrypt cert in  Zimbra

Usage: ./deployZC.sh<br>
    -d zimbra domain<br>
    -x ISRG X1 path default: /tmp/ISRG-X1.pem<br>
    -k Privkey path default: /etc/letsencrypt/live/webmail.emgtelecom.com.br/privkey.pem<br>
    -c Cert path default: /etc/letsencrypt/live/webmail.emgtelecom.com.br/cert.pem<br>
    -z Zimbra comercial key path default: /opt/zimbra/ssl/zimbra/commercial/commercial.key<br>
    -p Cert chain path default: /etc/letsencrypt/live/webmail.emgtelecom.com.br/chain.pem<br>
