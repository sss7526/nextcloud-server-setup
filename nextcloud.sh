#!/bin/bash

read -p "Set your username: " username
read -p "Set your password: " password

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

apt -y update && apt -y upgrade

# Checking if user already exists
if id "$username" &>/dev/null; then
    echo "User $username already exists!"
else
    # Adding user with adduser or useradd based on your preference
    adduser --disabled-password --gecos "" "$username"
    echo "$username added successfully!"

    # Setting up the user password
    echo "$username:$password" | chpasswd
    echo "Password for $username set successfully!"

    # Copy ssh ckeys and set perms on it
    mkdir /home/$username/.ssh
    cp .ssh/authorized_keys /home/$username/.ssh/authorized_keys
    chown -R $username:$username /home/$username/.ssh
    echo "ssh keys copied to /home/$USERNAME/.ssh/authorized_keys"
    usermod -aG sudo $username
	
fi

read -p "Set your nextcloud admin username: " ncuser
read -p "Set your nextcloud admin password: " ncpass
read -p "Enter your nextcloud server's IP address: " ip

ufw allow http
ufw allow https

echo $password | su $username -c "sudo -S snap install nextcloud"
echo $password | su $username -c "sudo -S nextcloud.manual-install $ncuser $ncpass"

echo $password | su $username -c "sudo -S nextcloud.enable-https self-signed"
echo $password | su $username -c "sudo -S nextcloud.occ config:system:set trusted_domains 2 --value=$ip"

while true; do
	read -p "Do you have a registered domain? (Y/N): " answer
	case ${answer^^} in
	    Y)
			nextcloud.enable-https lets-encrypt
			nextcloud.enable-https lets-encrypt
			nextcloud.occ config:system:set trusted_domains 3 --value=$domain			
			echo "You should be good to-go".
			break
			;;
		
	    N)
	    	echo "You should be good to-go now"
	    	break
	    	;;
	    
	    *)
	    	echo "Invalid input. Please enter Y or N."
	    	;;
    	esac
done
    
