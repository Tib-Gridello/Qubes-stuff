#!/bin/sh

# Take screenshot in Qubes Dom0, auto copy to AppVM
# Qubes R4.1 version
# Dependencies: zenity, deepin-screenshot at dom0 (sudo qubes-dom0-update deepin-screenshot)
# zenity at dom0 and at AppVM (already exists by default at fedora and dom0)

# (c) https://github.com/evadogstar/qvm-screenshot-tool/ 2021

version="0.9"
DOM0_SHOTS_DIR=$HOME/Pictures
APPVM_SHOTS_DIR=/home/user/Pictures
QUBES_DOM0_APPVMS=/var/lib/qubes/appvms/
LAST_ACTION_LOG_CONFIG="$HOME/.config/qvm-screenshot-lastaction.cfg"
rightdom0dir=$(xdg-user-dir PICTURES)
if [[ "$rightdom0dir" =~ ^/home/user* ]]; then
DOM0_SHOTS_DIR=$rightdom0dir
fi

write_last_action_config()
{
touch "$LAST_ACTION_LOG_CONFIG"
cat <<EOF > $LAST_ACTION_LOG_CONFIG
# last app vm used to upload image
appvm=$appvm
EOF
}

checkdeepinscreenshot()
{  
   (which deepin-screenshot &>/dev/null ) || { 
      warn="[EXIT] no \"deepin-screenshot\" tool at dom0 installed use: \n\nsudo qubes-dom0-update deepin-screenshot \n\ncommand to add it first"
      printf "$warn\n" 
      zenity --info --modal --text "$warn" &>/dev/null
      exit 1 
   }
}

mkdir -p $DOM0_SHOTS_DIR ||exit 1
while true; do
   d=`date +"%Y-%m-%d-%H%M%S"`
   shotname=$d.png

     checkdeepinscreenshot || break
     echo "[+] capturing window, click on it to select"
     deepin-screenshot --save-path $DOM0_SHOTS_DIR/$shotname || break

  if [ -f "$DOM0_SHOTS_DIR/$shotname" ]
  then
      echo "[+] Success at dom0. Screenshot saved at $DOM0_SHOTS_DIR/$shotname" || break
  else
   echo "[ERROR] Something has gone wrong and screenshot has not been saved at dom0."
   $(zenity --info --modal --text "Something has gone wrong and screenshot has NOT been saved at dom0") 
   exit 12
  fi

   shotslist="$shotname"
   break
done

choiceappvm=`ls $QUBES_DOM0_APPVMS |sed 's/\([^ ]*\)/FALSE \1 /g'`
appvm=$(zenity --list --modal  --width=200 --height=390  --text "Select destination AppVM (unix based):" --radiolist --column "Pick" --column "AppVM" $choiceappvm )

if [ X"$appvm" != X"" ]; then

   echo "[-] start AppVM: $appvm"
   destdir=$(qvm-run -a --pass-io $appvm "xdg-user-dir PICTURES")
   if [[ "$destdir" =~ ^/home/user* ]]; then
    APPVM_SHOTS_DIR=$destdir
   fi

   qvm-run $appvm "mkdir -p $APPVM_SHOTS_DIR"

   shot=$shotslist
   echo "[-] copying screenshot to $APPVM_SHOTS_DIR/$shot"
cat $DOM0_SHOTS_DIR/$shot \
      |qvm-run --pass-io $appvm "cat > $APPVM_SHOTS_DIR/$shot"
   if [ $? -eq 0 ]; then
      qvm-run --pass-io $appvm "xclip -selection clipboard -target image/png -i /home/user/Pictures/$APPVM__SHOTS_DIR/$shot"
      echo "lol: $APPVM__SHOTS_DIR/$shot"
      echo "[+] Success. Screenshot copied to $appvm: $APPVM_SHOTS_DIR/$shot"
   else
      echo "[ERROR] Something has gone wrong and screenshot has not been copied to $appvm."
      zenity --info --modal --text "Something has gone wrong and screenshot has NOT been copied to $appvm"
      exit 13
   fi

   write_last_action_config

else
   echo "[*] No AppVM selected. Screenshot remains only in dom0."
fi
