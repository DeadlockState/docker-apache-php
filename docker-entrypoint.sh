#!/bin/sh
if [ -n "$SFTP_USER" ] ; then
	groupadd -g 200 sftp
	groupadd -g ${SFTP_GID:-1000} $SFTP_USER
	useradd -u ${SFTP_UID:-1000} -g ${SFTP_GID:-1000} -d /home/$SFTP_USER -s /bin/bash $SFTP_USER
	echo " * Disabling "$SFTP_USER" password..."
	passwd -l $SFTP_USER
	usermod -a -G sftp $SFTP_USER
	usermod -a -G www-data $SFTP_USER

	mkdir -p /home/$SFTP_USER/.ssh
	chown -R $SFTP_USER:$SFTP_USER /home/$SFTP_USER
	chmod 755 /home/$SFTP_USER

	if [ ! -f "/home/"$SFTP_USER"/.ssh/authorized_keys" ] ; then
		su $SFTP_USER -c "cd /home/"$SFTP_USER"/.ssh/ && openssl genrsa -out "$SFTP_USER".pem 2048 && chmod 400 "$SFTP_USER".pem && ssh-keygen -y -f "$SFTP_USER".pem > authorized_keys"
	fi

	sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
	sed -i 's/Subsystem       sftp    \/usr\/lib\/openssh\/sftp-server/Subsystem sftp internal-sftp/g' /etc/ssh/sshd_config
	echo "
Match Group sftp
  ChrootDirectory /var/www/
  ForceCommand internal-sftp
  AllowTcpForwarding no" >> /etc/ssh/sshd_config

	service ssh restart
else
	service ssh stop
fi

/usr/sbin/apache2ctl -D FOREGROUND
