crontab -l > /tmp/crontab.bak
if ! grep -q "/etc/shadowsocks_watchdog.sh" /tmp/crontab.bak
then
    echo '*/15 * * * * /etc/shadowsocks_watchdog.sh >> /var/log/shadowsocks_watchdog.log' >> /tmp/crontab.bak;
    echo '0 5 * * 1 /etc/update_dnsmasq_config.sh' >> /tmp/crontab.bak;
    echo '2 5 * * 1 /etc/update_chnroute_list.sh' >> /tmp/crontab.bak;
    echo '*/15 * * * * echo "clear" > /var/log/dnsmasq.log' >> /tmp/crontab.bak;
    echo '20 5 * * 1 reboot' >> /tmp/crontab.bak;
    crontab /tmp/crontab.bak;
    echo 'update crontab'
else
    echo 'found exist';
fi