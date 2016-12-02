#!/bin/sh
myDNS="114.114.114.114"
gfw=0

#-d 自定义国内dns，推荐去网关看，替换掉114。114可能慢，且无法解析一些小众域名 
#-g 1表示当前在墙内状态，所以raw.githubusercontent.com更新不到，107.170.214.200:1602有一份静态的配置可用

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

# accelerated-domains.china_custom.conf 用于自定义新增新发现的国内域名
if [ ! -f "/etc/accelerated-domains.china_custom.conf" ]; then
    touch /etc/accelerated-domains.china_custom.conf
fi

cd /etc/dnsmasq.d/

if [ $gfw = 1 ]; then 
	wget --no-check-certificate -O accelerated-domains.china.conf http://107.170.214.200:1602/accelerated-domains.china.conf
	wget --no-check-certificate -O bogus-nxdomain.china.conf http://107.170.214.200:1602/bogus-nxdomain.china.conf
	echo 'gfw=1'
else
	wget --no-check-certificate -O accelerated-domains.china.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
	wget --no-check-certificate -O bogus-nxdomain.china.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/bogus-nxdomain.china.conf
fi

echo echo "accelerated dimains dns is $myDNS"
sed -i 's/114.114.114.114/219.141.140.10/' accelerated-domains.china.conf
wget -O foreign_list.conf http://107.170.214.200:1602/foreign_list.conf

/etc/init.d/dnsmasq restart
echo "" > /var/log/dnsmasq.log