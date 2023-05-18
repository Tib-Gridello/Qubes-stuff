VPNDIR="/rw/config/vpn/ovpn_tcp"

#kill openvpn
pidof openvpn > /dev/null
if [ $? -eq 0 ]; then
    echo "Killing existing openvpn process..."
    killall -9 openvpn
fi

# Check if openvpn-client.ovpn exists
if [ -f "$VPNDIR/openvpn-client.ovpn" ]; then
	# If previous.txt exists, read it into variable
	if [ -f "/rw/config/vpn/previous.txt" ]; then
		read -r oldname < previous.txt
		# Rename openvpn-client.ovpn to the content of previous.txt
		echo "$VPNDIR/openvpn-client.ovpn -->" "$VPNDIR/$oldname"
		mv "$VPNDIR/openvpn-client.ovpn" "$VPNDIR/$oldname"
	else
		echo "previous.txt does not exist. Unable to rename openvpn-client.ovpn."
		exit 1
	fi
fi

# Pick a random file
VPNFILE=$(ls $VPNDIR/*.ovpn | shuf -n 1)
#notify-send "$VPNFILE lol - "
# Save the previous filename
basename "$VPNFILE" > previous.txt

# Lines to add if they don't already exist
declare -a lines=("redirect-gateway def1" 
"script-security 2" 
"up 'qubes-vpn-handler.sh up'" 
"down 'qubes-vpn-handler.sh down'"
"auth-user-pass pass.txt"
"setenv vpn_dns '8.8.8.8'")

# Remove any lines beginning with "script-security", "up", or "down".
grep -vE "^script-security|^up|^down" $VPNFILE > temp.ovpn
# Add the lines if they don't already exist
for line in "${lines[@]}"
do
	grep -qxF "$line" temp.ovpn || echo "$line" >> temp.ovpn
done

	# Rename the temporary file to openvpn-client.ovpn
	mv temp.ovpn "$VPNDIR/openvpn-client.ovpn"
