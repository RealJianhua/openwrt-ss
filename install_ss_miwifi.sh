cd /tmp
#更新软件源 /etc/opkg.conf
wget http://107.170.214.200:1602/ssconf/opkg-miwifi.conf
mv opkg-miwifi.conf /etc/opkg.conf
opkg update

#download timed script
wget http://107.170.214.200:1602/ssconf/update_dnsmasq_config.sh
wget http://107.170.214.200:1602/ssconf/update_chnroute_list.sh
wget http://107.170.214.200:1602/ssconf/shadowsocks_watchdog.sh
wget http://107.170.214.200:1602/ssconf/shadowsocks.conf.tmp
mv update_dnsmasq_config.sh /etc/update_dnsmasq_config.sh
mv update_chnroute_list.sh /etc/update_chnroute_list.sh
mv shadowsocks_watchdog.sh /etc/shadowsocks_watchdog.sh
chmod +x /etc/update_dnsmasq_config.sh
chmod +x /etc/update_chnroute_list.sh
chmod +x /etc/shadowsocks_watchdog.sh

#download ipk
wget http://107.170.214.200:1602/ChinaDNS_1.3.2-4_ramips_24kec.ipk
wget http://107.170.214.200:1602/ip_3.16.0-1_ramips_24kec.ipk
wget http://107.170.214.200:1602/libc_0.9.33.2-1_ramips_24kec.ipk
wget http://107.170.214.200:1602/luci-app-chinadns_1.5.0-1_all.ipk
wget http://107.170.214.200:1602/luci-app-shadowsocks-spec_1.3.2-1_all.ipk
wget http://107.170.214.200:1602/shadowsocks-libev-spec_2.1.4-1_ramips_24kec.ipk

#install
opkg install libc_0.9.33.2-1_ramips_24kec.ipk
#更新wget，固件里的版本太旧
opkg install wget
opkg install ip_3.16.0-1_ramips_24kec.ipk
opkg install libopenssl
opkg install libgcc
opkg install libgmp
opkg install libnettle
rm /etc/config/chinadns #移除openwrt里旧版chinadns
rm /etc/config/chinadns-opkg
rm /etc/config/shadowsocks  #可能有自带的ss
opkg install ChinaDNS_1.3.2-4_ramips_24kec.ipk
opkg install luci-app-chinadns_1.5.0-1_all.ipk
opkg install shadowsocks-libev-spec_2.1.4-1_ramips_24kec.ipk
opkg install luci-app-shadowsocks-spec_1.3.2-1_all.ipk

#配置 dnsmasq

if ! grep -q "conf-dir=/etc/dnsmasq.d" /etc/dnsmasq.conf
then
    echo "conf-dir=/etc/dnsmasq.d" >> /etc/dnsmasq.conf
	echo "log-queries" >> /etc/dnsmasq.conf
	echo "log-facility=/var/log/dnsmasq.log" >> /etc/dnsmasq.conf
	echo "cache-size=1500" >> /etc/dnsmasq.conf
fi

/etc/update_chnroute_list.sh
/etc/init.d/shadowsocks stop
/etc/update_dnsmasq_config.sh -g
#cp /tmp/shadowsocks.conf.tmp /etc/config/shadowsocks

crontab -l > /tmp/crontab.bak
if ! grep -q "/etc/shadowsocks_watchdog.sh" /tmp/crontab.bak
then
    echo '*/15 * * * * /etc/shadowsocks_watchdog.sh >> /var/log/shadowsocks_watchdog.log' >> /tmp/crontab.bak;
    echo '0 5 * * 1 /etc/update_dnsmasq_config.sh' >> /tmp/crontab.bak;
    echo '2 5 * * 1 /etc/update_chnroute_list.sh' >> /tmp/crontab.bak;
    echo '*/15 * * * * echo "clear" > /var/log/dnsmasq.log' >> /tmp/crontab.bak;
    echo '20 5 * * 1 reboot' >> /tmp/crontab.bak;
    crontab /tmp/crontab.bak;
    echo 'crontab config finish.';
    rm /tmp/crontab.bak;
fi

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
