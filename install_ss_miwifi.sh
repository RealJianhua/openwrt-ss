#!/bin/sh
# 核心原理：
# 1. 解决 dns 投毒问题
# dnsmasq 规则：
# * 墙内白名单，走指定的国内dns （为什么不走chinadns，是因为chinadns存在把国内域名解析为国外ip的情况）
# * 墙外黑名单，通过shadowsocks 解析dns，实质是tcp/ip dns
# * 黑/白名单以外的未知host，走chinadns。额外再做一层chinadns，是因为chinadns在多数情况下，能够解析墙外的host

# 2. 用shadowsocks代理翻墙
# * chnroute list（国内路由表）, 提供了墙内ip段，非墙内ip，都走shadowsocks代理，理论上存在误伤的可能
# * chinadns用来判断国内外ip的列表，共用chnroute list。

# 3. 定时任务
# * update_dnsmasq_config.sh 定期更新墙内、外域名名单，供dnsmasq
# * update_chnroute_list.sh 定期更新 chnroute list
# * shadowsocks_watchdog.sh 定时执行，检测shadowsocks运行状态
# * 定时清空 /var/log/dnsmasq.log，dns查询会产生大量的日志，最好10-20分钟即清空一次 echo "" > /var/log/dnsmasq.log
# * 定时重启路由器。路由器长期运行，一般会有各种状态bug，导致无法上网，可以每周重启一次
# 
cd /tmp
#vt-hk1.vnet.link:33224
#更新软件源
#/etc/opkg.conf
#wget http://107.170.214.200:1602/opkg.conf
#mv opkg.conf /etc/opkg.conf
#
#更新wget，固件里的版本太旧

#download timed script
wget http://107.170.214.200:1602/update_dnsmasq_config.sh
wget http://107.170.214.200:1602/update_chnroute_list.sh
wget http://107.170.214.200:1602/shadowsocks_watchdog.sh
mv update_dnsmasq_config.sh /etc/update_dnsmasq_config.sh
mv update_chnroute_list.sh /etc/update_chnroute_list.sh
mv shadowsocks_watchdog.sh /etc/shadowsocks_watchdog.sh
chmod +x /etc/update_dnsmasq_config.sh
chmod +x /etc/update_chnroute_list.sh
chmod +x /etc/shadowsocks_watchdog.sh

#download ipk
wget http://107.170.214.200:1602/ChinaDNS_1.3.2-4_ramips_24kec.ipk
wget http://107.170.214.200:1602/ip_3.16.0-1_ramips_24kec.ipk
wget http://107.170.214.200:1602/luci-app-chinadns_1.5.0-1_all.ipk
wget http://107.170.214.200:1602/luci-app-shadowsocks-spec_1.3.2-1_all.ipk
wget http://107.170.214.200:1602/shadowsocks-libev-spec_2.1.4-1_ramips_24kec.ipk

#install
opkg install wget
opkg install libc
opkg install ip_3.16.0-1_ramips_24kec.ipk
opkg install libopenssl
opkg install libgcc
opkg install libgmp
opkg install libnettle
rm /etc/config/chinadns #移除openwrt里旧版chinadns
rm /etc/config/chinadns-opkg
opkg install ChinaDNS_1.3.2-4_ramips_24kec.ipk
opkg install luci-app-chinadns_1.5.0-1_all.ipk
opkg install shadowsocks-libev-spec_2.1.4-1_ramips_24kec.ipk
opkg install luci-app-shadowsocks-spec_1.3.2-1_all.ipk

#配置 dnsmasq
echo "conf-dir=/etc/dnsmasq.d" >> 1.txt
echo "log-queries" >> 1.txt
echo "log-facility=/var/log/dnsmasq.log" >> 1.txt
/etc/update_chnroute_list.sh
/etc/update_dnsmasq_config.sh

#人工配置
# 1. ChinaDNS
# * 打开双向过滤
# * 可能把114dns替换为网关的dns
# * 端口 35300
# * 路由表自定义为/etc/chinadns_chnroute.txt (如果默认已经是，跳过)
# * 把路由器dns转发到chinadns:127.0.0.1#35300、忽略解析文件

# 2. Shadowsocks
# * 取消[使用配置文件]
# * 填写账号信息
# * 超时600
# * 打开udp转发，端口35354
# * 路由表自定义为/etc/chinadns_chnroute.txt (如果默认已经是，跳过)
# * 启用后，运行 /etc/shadowsocks_watchdog.sh 观看是否运行正常

# 3. 定时任务
# 参考头部说明

# 4. 重启
# reboot










