#!/bin/bash
cores=$(cat /proc/cpuinfo | grep 'model name'| wc -l)
cname=$( cat /proc/cpuinfo | grep 'model name' | uniq | awk -F : '{print $2}')
tram=$( free -m | awk '/Mem/ {print $2}' )
swap=$( free -m | awk '/Swap/ {print $2}' )

#如果没有/etc/redhat-release，则退出
if [ ! -e '/etc/redhat-release' ]; then
echo "Only Support CentOS6 CentOS7 RHEL6 RHEL7"
exit
fi

#检测版本6还是7
if  [ -n "$(grep ' 7\.' /etc/redhat-release)" ] ;then
CentOS_RHEL_version=7
elif
[ -n "$(grep ' 6\.' /etc/redhat-release)" ]; then
CentOS_RHEL_version=6
fi

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

#清屏
clear

next
echo "Total amount of Mem  : $tram MB"
echo "Total amount of Swap : $swap MB"
echo "CPU model            : $cname"
echo "Number of cores      : $cores"
next

if [ "$CentOS_RHEL_version" -eq 6 ];then
rpm -ivh https://file.kskxs.com/linux/kernel/CentOS6/kernel-firmware-2.6.32-504.3.3.el6.noarch.rpm
rpm -ivh https://file.kskxs.com/linux/kernel/CentOS6/kernel-2.6.32-504.3.3.el6.x86_64.rpm --force
number=$(cat /boot/grub/grub.conf | awk '$1=="title" {print i++ " : " $NF}'|grep '2.6.32-504'|awk '{print $1}')
sed -i "s/^default=.*/default=$number/g" /boot/grub/grub.conf
echo -e "\033[41;36m  5s later will reboot your server  \033[0m";
sleep 5
reboot
else
rpm -ivh https://file.kskxs.com/linux/kernel/CentOS7/kernel-3.10.0-327.el7.x86_64.rpm --force
grub2-set-default `awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg | grep '(3.10.0-229.1.2.el7.x86_64) 7 (Core)'|awk '{print $1}'`
echo -e "\033[41;36m  5s later will reboot your server  \033[0m";
sleep 5
reboot
fi
