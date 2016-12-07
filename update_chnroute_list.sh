#!/bin/sh
#/etc/chinadns_chnroute.txt 用于自定义新发现的国内ip，运行此脚本后，自动合并到/etc/chinadns_chnroute.txt
#
if [ ! -f "/etc/chnroute_list_custom.conf" ]; then
        touch /etc/chnroute_list_custom.conf
fi

wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | \
   awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > \
   /tmp/chnroute_list.tmp

if [[ "$?" -eq 0 ]] ; then
    cat /tmp/chnroute_list.tmp  /etc/chnroute_list_custom.conf | sort | uniq | sed -e '/^$/d' > /etc/chinadns_chnroute.txt
fi
rm /tmp/chnroute_list.tmp
/etc/init.d/chinadns restart
/etc/init.d/shadowsocks restart