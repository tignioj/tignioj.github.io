#!/bin/bash
echo "UEFI OR BIOS=========DEVICE============="
echo "1.UEFI"
echo "2.BIOS"
read -p "you type is?" -t 10 MYTYPE
if [[ $? -eq 142 ]]
then
  if [[ `ls /sys/firmware/efi/efivars` ]]
  then
    echo "Your device support UEFI"
    MYTYPE=1
  else
    echo "your device does not support UEFI, so choose BIOS"
    MYTYPE=2
  fi
else
  echo "you choose $MYTYPE"
fi

read -p "your device is?" -t 10 MY_BLOCK
if [[ $? -eq 142 ]]
then
  MY_BLOCK='/dev/sda'
else
  echo "your block is $MY_BLOCK"
fi


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
