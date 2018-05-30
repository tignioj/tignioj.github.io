#!/bin/bash
MYTYPE=$1
MY_BLOCK=$2

if [[ $MYTYPE && $MY_BLOCK ]]
then
	echo "Your device is $MY_BLOCK, type is $MYTYPE"
else
	echo -e "\n\nIf you want to run this script, Be sure your system has installed base package\n\n"
	echo "Usage:\n./chroot.sh [arg1] [arg2]"
	echo "arg1 : your device name,you can run 'lsblk' to check which is your device"
	echo "arg2 : you should Input only one number between '1' and '2', 1 is stand for UEFI, 2 is stand for BIOS"
	echo  -e "e.g:\n\n./chroot.sh /dev/sda 1"
	exit
fi
echo "chroot setting time----"
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc  --utc

MY_INDEX=0
while [[ $MY_INDEX -lt 6 ]]
do
pacman -Sy --noconfirm --needed tmux vim dialog wpa_supplicant ntfs-3g networkmanager git zsh 
if [[ $? -eq 0 ]]
then
	break
fi
done
echo "done"


echo "setting locale=========="
if test -e /etc/local.gen_bak
then
	echo "local.gen_bak is exited"
else
	cp /etc/locale.gen /etc/locale.gen_bak
fi
echo 'zh_CN.UTF-8 UTF-8' > /etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo "done"


echo "===========setting hostname (defalut:mikehost)====="
read -p "Enter your hostname:" -t 5 YOUR_HOSTNAME
MY_INPUTE_STATE=$?
echo $MY_INPUTE_STATE
if [ $MY_INPUTE_STATE -eq 0 ]
then
    echo "your hostname is $YOUR_HOSTNAME"
elif [ $MY_INPUTE_STATE -eq 142 ]
then
    YOUR_HOSTNAME="mikehost"
    echo "default hostname is :$YOUR_HOSTNAME"
fi
echo $YOUR_HOSTNAME > /etc/hostname

echo "127.0.0.1	localhost.localdomain	localhost
::1		localhost.localdomain	localhost
127.0.1.1	${YOUR_HOSTNAME}.localdomain	${YOUR_HOSTNAME}" > /etc/hosts
unset MY_INPUTE_STATE
echo "done"
echo "==========setting passwd===========(default is 000000)"

read -p "Enter you root passwd (in 5 second) :" -t 5 MY_ROOT_PASSWD
MY_INPUT_STATE=$?
if [ $MY_INPUT_STATE -eq 142 ]
then
	passwd << EOF1
000000
000000
EOF1
elif [ $MY_INPUT_STATE -eq 0 ]
then
	passwd << EOF2
$MY_ROOT_PASSWD
$MY_ROOT_PASSWD
EOF2
fi

echo "adduser -m mike, passwd is 000000"
useradd -m mike
passwd mike << EOFMIKE
000000
000000
EOFMIKE

#backup sudoers
if test -e /etc/sudoers_bak
then
	echo "sudoers is already backup "
else
	cp /etc/sudoers /etc/sudoers_bak
fi

if ( grep '\<mike\>' /etc/sudoers )
then
	echo 'mike is exist'
else
	echo 'mike ALL=(ALL) ALL' >> /etc/sudoers
fi
echo "done"


echo -e "\n\n============installing grub=================\n\n"

echo "============Testing CPU====================="
if  (( `cat /proc/cpuinfo | grep -i amd` ))
then
	echo -e "\n\n\nyour CPU is AMD\n\n\n"
else
	echo -e "\n\n\nyour CPU is Intel\n\n\nInstalling intel-ucode..."
	echo 000000 | pacman -S --noconfirm --needed intel-ucode
fi


#=================================UEFI--OR---BIOS===================
if [[ $MYTYPE -eq 1 ]]
then
	echo "Using UEFI==============>>"
	pacman -S --noconfirm --needed grub-efi-x86_64 os-prober efibootmgr 
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
elif [[ $MYTYPE -eq 2 ]]
then
	echo "Using BIOS=============>>"
	pacman -S --noconfirm --needed grub
	grub-install --target=i386-pc  $MY_BLOCK
fi


grub-mkconfig -o /boot/grub/grub.cfg
unset MY_INPUT_STATE
echo "1.nothing"
echo "2.yes,I want to adjust"
read -p "anything wrong ?" -t 10 ANY_WRONG
MY_INPUT_STATE=$?
if [ $MY_INPUT_STATE -eq 142 ]
then
	ANY_WRONG=1
elif [ $MY_INPUT_STATE -eq  0 ]
then
	if [ $ANY_WRONG -eq 1 ]
	then
		echo "now install gnu"
	else
		echo "adjust it!"
		exit
	fi
else
	echo "unknow the state: $MY_INPUT_STATE "
fi

echo "Installing xfce4 xorg sddm, drive====================="
MY_INDEX=0
while (( $MY_INDEX <= 6 ))
do
  pacman -Sy --noconfirm --needed xorg xfce4 sddm xf86-video-vesa network-manager-applet  sudo << EOF3






EOF3
if [[ $? -eq 0 ]]
then
  break
fi

done





echo "systemctl================================>>"
systemctl enable sddm
systemctl disable netctl
systemctl enable NetworkManager
echo "done"

echo "setting yaourt=============================>>"
if ( grep 'archlinuxcn' /etc/pacman.conf)
then
	archlinuxcn is exist
else
	echo -e '
[archlinuxcn]
SigLevel=Never
Server = http://repo.archlinuxcn.org/$arch
' >> /etc/pacman.conf
fi
MY_INDEX=0
while (( $MY_INDEX <= 6 ))
do
pacman -Sy --noconfirm --needed yaourt fakeroot archlinuxcn-keyring screenfetch ttf-dejavu ttf-droid wqy-microhei wqy-zenhei google-chrome fcitx fcitx-im fcitx-libpinyin fcitx-googlepinyin fcitx-configtool
if [[ $? -eq 0 ]]
then
	break
fi
done
#============for fcitx================
echo -e "\n\n========fcitx setting==========\n\n"
if [[ `cat /etc/profile | grep fcitx` ]]
then
	echo found fcitx in /etc/porfile
else

	echo 000000 | sudo -S chmod 777 /etc/profile
	echo 'export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"' >> /etc/profile
	echo 000000 | sudo -S chmod 644 /etc/profile
	echo done
fi

su mike -c 'git clone https://github.com/tignioj/linux.git ~/clone/linux
~/clone/linux/config/total.sh
screenfetch'

echo "done"
