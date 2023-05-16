#!/bin/sh

# Specify the file path and the destination directory
file_path="/home/user/qubes-boot/prefs.xml"
destination_dir="/home/kali/.java/.userPrefs/burp/"
mkdir -p "$dest_dir_path"
cp "$file_path" "$destination_dir"



# Change permission so kali and user are binded
sudo chown -R user:sharedgroup /home/user
sudo chown -R kali:sharedgroup /home/kali
sudo chmod -R 770 /home/user
sudo chmod -R 770 /home/kali
