#!/bin/sh
myDNS="223.6.6.6"
gfw=0

while getopts "d:g" arg
do
    case $arg in
         d)
            myDNS=$OPTARG
            ;;
         g)
            gfw=1
            ;;
         ?)
        echo "unkonw argument"
    exit 1
    ;;
    esac
done

if [ ! -d "/etc/dnsmasq.d/" ]; then
        mkdir /etc/dnsmasq.d/
fi

cd /etc/dnsmasq.d/

if [ ! -f "/etc/dnsmasq.d/custom.conf" ]; then
    touch /etc/dnsmasq.d/custom.conf
fi

if [ $gfw = 1 ]; then
    wget --no-check-certificate -O accelerated-domains.china.conf.tmp http://107.170.214.200:1602/accelerated-domains.china.conf
    if [[ "$?" -eq 0 ]] ; then
        mv accelerated-domains.china.conf.tmp accelerated-domains.china.conf
        sed -i "s/114.114.114.114/$myDNS/" accelerated-domains.china.conf
    else
        rm accelerated-domains.china.conf.tmp
    fi

    wget --no-check-certificate -O bogus-nxdomain.china.conf.tmp http://107.170.214.200:1602/bogus-nxdomain.china.conf
    if [[ "$?" -eq 0 ]] ; then
        mv bogus-nxdomain.china.conf.tmp bogus-nxdomain.china.conf
    else
        rm bogus-nxdomain.china.conf.tmp
    fi
else
    wget --no-check-certificate -O accelerated-domains.china.conf.tmp https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
    if [[ "$?" -eq 0 ]] ; then
        mv accelerated-domains.china.conf.tmp accelerated-domains.china.conf
        sed -i "s/114.114.114.114/$myDNS/" accelerated-domains.china.conf
    else
        rm accelerated-domains.china.conf.tmp
    fi  

    wget --no-check-certificate -O bogus-nxdomain.china.conf.tmp https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/bogus-nxdomain.china.conf
    if [[ "$?" -eq 0 ]] ; then
        mv bogus-nxdomain.china.conf.tmp bogus-nxdomain.china.conf
    else
        rm bogus-nxdomain.china.conf.tmp
    fi
fi

wget -O foreign_list.conf.tmp http://107.170.214.200:1602/foreign_list.conf
if [[ "$?" -eq 0 ]] ; then
    mv foreign_list.conf.tmp foreign_list.conf
else
    rm foreign_list.conf.tmp
fi

wget -O dnsmasq_custom.conf.tmp http://107.170.214.200:1602/ssconf/dnsmasq_custom.conf
if [[ "$?" -eq 0 ]] ; then
    mv dnsmasq_custom.conf.tmp custom.conf
else
    rm dnsmasq_custom.conf.tmp
fi

/etc/init.d/dnsmasq restart
echo "" > /var/log/dnsmasq.log