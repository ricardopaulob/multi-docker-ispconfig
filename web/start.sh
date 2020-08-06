#!/bin/bash
# DOCKERPASS=$(openssl rand -base64 32)
# sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

if [ ! -f /usr/local/ispconfig/interface/lib/config.inc.php ]; then

	# Fix issue for connecting from remote my sql server
	sed -i 's/from_host = $'"conf\['hostname'\]/from_host = '%'/g" /root/ispconfig3_install/install/lib/installer_base.lib.php
	while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
		echo waiting for mysql at $MYSQL_HOST
    		sleep 1
	done

	if [ ! -z "$MYSQL_HOST" ]; then
		sed -i "s/^mysql_hostname=localhost$/mysql_hostname=$MYSQL_HOST/g" /root/ispconfig3_install/install/autoinstall.ini
		sed -i "s/^mysql_master_hostname=localhost$/mysql_master_hostname=$MYSQL_HOST/g" /root/ispconfig3_install/install/autoinstall.ini
	fi

	if [ ! -z "$MYSQL_PASSWORD" ]; then
		sed -i "s/^mysql_root_password=pass$/mysql_root_password=$MYSQL_PASSWORD/g" /root/ispconfig3_install/install/autoinstall.ini
		sed -i "s/^mysql_master_root_password=pass$/mysql_master_root_password=$MYSQL_PASSWORD/g" /root/ispconfig3_install/install/autoinstall.ini
	fi
	rndpass=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ; echo ''`
	sed -i "s/^mysql_ispconfig_password=pass$/mysql_ispconfig_password=$rndpass/g" /root/ispconfig3_install/install/autoinstall.ini
	if [ ! -z "$MYSQL_PORT" ]; then
		sed -i "s/^mysql_port=3306$/mysql_port=$MYSQL_PORT/g" /root/ispconfig3_install/install/autoinstall.ini
	fi

	if [ ! -z "$LANGUAGE" ]; then
		sed -i "s/^language=en$/language=$LANGUAGE/g" /root/ispconfig3_install/install/autoinstall.ini
	fi

	if [ ! -z "$COUNTRY" ]; then
		sed -i "s/^ssl_cert_country=US$/ssl_cert_country=$COUNTRY/g" /root/ispconfig3_install/install/autoinstall.ini
	fi

        if [ ! -z "$HOSTNAME" ]; then
                sed -i "s/^hostname=server1.example.com$/hostname=$HOSTNAME.$DOMAINNAME/g" /root/ispconfig3_install/install/autoinstall.ini
        fi

	php -q /root/ispconfig3_install/install/install.php --autoinstall=/root/ispconfig3_install/install/autoinstall.ini

        if [ ! -z "$HOSTNAME" ]; then
                sed -i "s/server_name _;$/server_name $HOSTNAME.$DOMAINNAME;/g" /etc/nginx/sites-enabled/000-ispconfig.vhost
		service nginx reload
	fi
	mkdir /var/www/html
	echo "" > /var/www/html/index.html
	#rm -r /root/ispconfig3_install
fi
mkdir /run/php/


screenfetch

service supervisor stop
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n

#tail -f /var/log/nginx/* /var/log/php7.2-fpm.log /var/log/auth.log /var/log/cron.log
