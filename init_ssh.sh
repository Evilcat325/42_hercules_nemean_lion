#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    init_ssh.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: seli <seli@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/03/01 20:50:35 by seli              #+#    #+#              #
#    Updated: 2019/03/01 20:50:35 by seli             ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# check root if
if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root"
 exit 1
fi

# get latest package lists
apt-get update
# install ssh
apt-get install -y openssh-server

#regenerating host keys
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

# pick a random port on local port
# read range
read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
while :
do
		# random select
        PORT="$(shuf -i $LOWERPORT-$UPPERPORT -n 1)"
		# test if in use break when not
        ss -lpn | grep -q ":$PORT " || break
done

# change sshd port via /etc/ssh/sshd_config

# uncomment #Port to Port
sed -i -e "s/#Port/Port/" /etc/ssh/sshd_config
# replease default port to new port
sed -i -e "s/Port.*/Port $PORT/" /etc/ssh/sshd_config

# restart ssh
systemctl restart ssh

# notify user which port ssh is listening on
echo "ssh is now listening on port:$PORT"
