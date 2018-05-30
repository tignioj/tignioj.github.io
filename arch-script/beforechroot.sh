#!/bin/bash
#setting---time=========================================

if [[ `ls /sys/firmware/efi/efivars` ]]
then
	echo "Your device support UEFI"
	MYTYPE=1
else
	echo -e "Your device UEFI is unable to start, If you want to Install Archlinux by UEFI, Please shutdown this Virtual-machine and checkout you Virtual setting,following by these step"
	echo -e "Vm--->Settings--->Options---->Advanced---->UEFI"
	echo "But.. you can also Install Archlinux by BIOS"
	echo -e  "1.yes\n2.no"
	read -p "continue by BIOS?(Please choose a number in 5s,default is 1)" -t 5 IF_CONTINUE
	if [[ $? -eq 142 ]]
	then
		MYTYPE=2
	elif [[ $IF_CONTINUE -eq 1 ]]
	then
			echo "you choose $IF_CONTINUE"
	elif [[ $IF_CONTINUE -eq 2 ]]
	then
		echo "you choose $IF_CONTINUE"
		exit
	fi
fi


echo "step1.==========setting time..."
timedatectl set-ntp true
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
hwclock --systohc --utc

echo "ready to FORMATTING===========================>>"
	#block=======================================no home block=
	echo "step2.==========block-formatting"
	lsblk
	echo -e "choose your block (default is /dev/sda) \n\n NOTICE:This operation will erase all the date in your U disk!!!\n\n"
	read -p "Enter you block(in 20s ):" -t 20 MY_BLOCK
	BLOCK_STATE=$?
	if [[ $BLOCK_STATE -eq 142 ]]
	then
		MY_BLOCK='/dev/sda'
	fi
	echo "your block is $MY_BLOCK"
	if [[ $MYTYPE -eq 1 ]]
	then
		#choose your type==============================
		echo "your machine support BIOS AND UEFI"
		echo -e "1.UEFI\n2.BIOS"
		read -p "Input your number(in 10s)(default is 1):" -t 10 MYTYPE
		MY_INPUT_STATE=$?
		if [[ $MY_INPUT_STATE -eq 142 ]]
		then
			MYTYPE=1
		fi
	fi
#=================UEFI============================
	if [[ $MYTYPE -eq 1 ]]
	then
		echo "====gdisk===="
		umount /mnt/boot
		umount /mnt
		sudo gdisk $MY_BLOCK << EOF
o
y

n
1

+512M
ef00
n
2

+12G
8300
w
y

EOF

		echo "mkfs...===================="
		mkfs.vfat -F32 ${MY_BLOCK}1 << EOF
y
EOF
mkfs.ext4 ${MY_BLOCK}2 << EOF
y
EOF
		echo "mkdir--mount==============="
		mount ${MY_BLOCK}2 /mnt
		mkdir -p /mnt /mnt/boot
		mount ${MY_BLOCK}1 /mnt/boot
	fi
#=================UEFI-END========================

#================BIOS============================
	if [[ $MYTYPE -eq 2 ]]
	then
		umount /mnt/boot
		umount /mnt
		fdisk $MY_BLOCK << EOFBIOS
d
1
d
2
d
4
d
4
o
n
p


+13G
y
p
w
y
EOFBIOS
		echo "mkfs....."
		mkfs.ext4 ${MY_BLOCK}1 << EOFMKFS
y
EOFMKFS
		echo "mountting...."
		mount ${MY_BLOCK}1 /mnt
		echo "done"
	fi
	lsblk
	fdisk -l
echo "change rope================(default:tuna)"
if test -e /etc/pacman.d/mirrorlist_bak
then
	echo 'mirrorlist_bak is exist'
else
  cp /etc/pacman.d/mirrorlist /mnt
	cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_bak
fi

echo 'Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

echo "installing base base-devel==============="
MY_INDEX=0
while ((  $MY_INDEX <= 6  )) 
do
	pacstrap /mnt base base-devel
	if [[ $? -eq 0 ]]
	then
		break
	fi
	let "MY_INDEX+=1"
	
done

echo "genfstab -L > /mnt /mnt/etc/fstab"
genfstab -L /mnt > /mnt/etc/fstab
cat /mnt/etc/fstab

echo "Copying chroot.sh to new root=================>>"
cp chroot.sh /mnt/
cp xfce.sh /mnt/
cp grub.sh /mnt/
cp yaourt.sh /mnt/
arch-chroot /mnt  /chroot.sh $MYTYPE $MY_BLOCK

umount /mnt/boot
umount /mnt
read -p "Finish,the system will automatically restart after 15 seconds, you can press CTRL + C to cancel" -t 15 IF_CANCEL
if [[ $? -eq 142 ]]
then
	reboot
fi

