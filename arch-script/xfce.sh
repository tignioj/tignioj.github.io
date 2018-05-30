#!/bin/bash
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
