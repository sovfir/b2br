#!/bin/bash
arch=$(uname -a)
phys_proc=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
virt_proc=$(grep "^processor" /proc/cpuinfo | wc -l)
mem_used=$(free -m | awk '$1 == "Mem:" {print $3}')
mem_max=$(free -m | awk '$1 == "Mem:" {print $2}')
mem_use_perc=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
disk_used=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
disk_max=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $2/10000} END {print ut}')
disk_use_perc=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d"), ut/ft*100}')
cpu_load=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
last_boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
lvm_check=$(lsblk | grep "lvm" | wc -l)
lvm_use_res=$(if [ $lvm_check -eq 0 ]; then echo no; else echo yes; fi)
con_tcp=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
user_log=$(users | wc -w)
ip=$(hostname -I)
mac_adress=$(ip link show | awk '$1 == "link/ether" {print $2}')
sudo_use=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall $'#Architecture: ' $arch\
$'\n#CPU physical: ' $phys_proc\
$'\n#vCPU: ' $virt_proc\
$'\n#Memory Usage: ' "$mem_used/${mem_max}MB ($mem_use_perc%)"\
$'\n#Disk Usage: ' "$disk_used/${disk_max}Gb ($disk_use_perc%)"\
$'\n#CPU load: ' $cpu_load\
$'\n#Last boot: ' $last_boot\
$'\n#LVM use: ' $lvm_use_res\
$'\n#Connexions TCP: ' $con_tcp ESTABLISHED\
$'\n#User log: ' $user_log\
$'\n#Network: ' "IP $ip ($mac_adress)"\
$'\n#Sudo: ' $sudo_use cmd\