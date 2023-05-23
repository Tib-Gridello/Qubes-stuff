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

firefox_profile_dir="/home/user/.mozilla/firefox"
folder_name=$(ls $firefox_profile_dir | grep 'default-esr$')

if [[ -z $folder_name ]]; then
    echo "No folder"
    exit 1
fi

folder_path= "$firefox_profile_dir/$folder_name"

tar -xf /home/user/qubes-boot/firefox/output.tar -C $folder_path
