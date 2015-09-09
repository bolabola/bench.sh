#!/bin/bash

cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
tram=$( free -m | awk 'NR==2 {print $2}' )
swap=$( free -m | awk 'NR==4 {print $2}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime )

next() {
    printf "%-60s\n" "-" | sed 's/\s/-/g'
}

speed_test() {
    speedtest=$(wget -4O /dev/null $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
    ipcheck=$(curl -4v -r 0-128 -o /dev/null $1 2>&1| awk -F'[()]' '/Connected/{print$2}')
    echo -e "Download speed from \e[33m$2\e[0m(IP:\e[32m$ipcheck\e[0m): \e[31m$speedtest\e[0m"
}

speed() {
    speed_test 'http://cachefly.cachefly.net/100mb.test' 'CacheFly'
    speed_test 'http://speedtest.tokyo.linode.com/100MB-tokyo.bin' 'Linode, Tokyo, JP'
    speed_test 'http://speedtest.singapore.linode.com/100MB-singapore.bin' 'Linode, Singapore, SG'
    speed_test 'http://speedtest.london.linode.com/100MB-london.bin' 'Linode, London, UK'
    speed_test 'http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin' 'Linode, Frankfurt, DE'
    speed_test 'http://speedtest.fremont.linode.com/100MB-fremont.bin' 'Linode, Fremont, CA'
    speed_test 'http://tx-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Dallas, TX'
    speed_test 'http://wa-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Seattle, WA'
    speed_test 'http://lax-ca-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Los Angeles, CA'
    speed_test 'http://fra-de-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Frankfurt, DE'
    speed_test 'http://hnd-jp-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Tokyo, JP'
    speed_test 'http://speedtest.dal05.softlayer.com/downloads/test100.zip' 'Softlayer, Dallas, TX'
    speed_test 'http://speedtest.sea01.softlayer.com/downloads/test100.zip' 'Softlayer, Seattle, WA'
    speed_test 'http://speedtest.fra02.softlayer.com/downloads/test100.zip' 'Softlayer, Frankfurt, DE'
    speed_test 'http://speedtest.sng01.softlayer.com/downloads/test100.zip' 'Softlayer, Singapore, SG'
    speed_test 'http://speedtest.hkg02.softlayer.com/downloads/test100.zip' 'Softlayer, HongKong, CN'
}

clear
echo "CPU model            :$cname"
echo "Number of cores      : $cores"
echo "CPU frequency        :$freq MHz"
echo "Total amount of ram  : $tram MB"
echo "Total amount of swap : $swap MB"
echo "System uptime        : $up"
next

speed && next

io=$((dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && /bin/rm -f test_$$) 2>&1 | awk 'END{print}')
echo "I/O speed : $io"
echo ""