FROM ubuntu:18.04


MAINTAINER Ali Modaresi <modaresi.mr@gmail.com> version: 1.0




USER root

### BASICS ###
# Technical Environment Variables
ENV \
	SHELL="/bin/bash" \
	HOME="/root"  \
	USER_GID=0 \
	DEBIAN_FRONTEND=noninteractive	
	

WORKDIR $HOME



RUN \	
	# --- 0 Update Your Ubuntu Installation
	echo "deb http://de.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse">>/etc/apt/sources.list && \
	echo "deb http://security.ubuntu.com/ubuntu bionic-security multiverse">>/etc/apt/sources.list && \
	apt-get update && \
	apt-get -y upgrade && \
	
	# Generate and Set locals
	# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#38553499
	apt-get install -y locales && \
	# install locales-all?
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	locale-gen && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=en_US.UTF-8 && \
	
	# --- 1 Preliminary
	apt-get -y install rsyslog rsyslog-relp logrotate supervisor screenfetch &&\
	# Create the log file to be able to run tail
	touch /var/log/cron.log /var/log/auth.log&&\

	# --- 2 Install the SSH server
	apt-get -y install ssh openssh-server rsync &&\

	# --- 3 Install a shell text editor
	apt-get -y install nano vim-nox &&\
	echo "dash	dash/sh boolean no" | debconf-set-selections && dpkg-reconfigure dash &&\
	
	# --- 7 Synchronize the System Clock
	apt-get -y install ntp ntpdate &&\
	
	# https://www.howtoforge.com/tutorial/perfect-server-ubuntu-18-04-nginx-bind-dovecot-and-ispconfig-3/
	
	# --- STEP 4
	#service apparmor stop &&\
	#update-rc.d -f apparmor remove &&\
	#apt-get remove apparmor apparmor-utils &&\
	
	# --- MYSQL CLIENT
	apt-get -y install mysql-client &&\
	# --- NGINX
	apt-get -y install nginx &&\
	service nginx start &&\
	apt-get -y install php7.2-fpm php7.2-mysql php7.2-xml php7.2-mbstring &&\
	apt-get -y install fcgiwrap &&\
	apt-get -y install hhvm &&\
	apt-get -y install certbot &&\
	apt-get -y install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl &&\
	apt-get -y install build-essential autoconf automake libtool flex bison debhelper binutils &&\
	# Install PureFTPd And Quota
	apt-get -y install pure-ftpd-common pure-ftpd-mysql quota quotatool&&\
	#echo 1 > /etc/pure-ftpd/conf/TLS &&\
	#FIREWALL
	apt-get -y install ufw
	
ADD ./awstats /etc/cron.d/awstats

ADD ./pure-ftpd-common /etc/default/pure-ftpd-common
ADD ./supervisord.conf /etc/supervisor/conf.d/ispconfig.conf

RUN \
	# --- 17 Install Jailkit
	cd /tmp &&\
	wget http://olivier.sessink.nl/jailkit/jailkit-2.19.tar.gz &&\
	tar xvfz jailkit-2.19.tar.gz &&\
	cd jailkit-2.19 &&\
	echo 5 > debian/compat &&\
	./debian/rules binary &&\
	cd /tmp &&\
	dpkg -i jailkit_2.19-1_*.deb &&\
	ls
	#supervisorctl reload
	

RUN \
	cd /root  && \
	wget -O ispconfig.tar.gz https://git.ispconfig.org/ispconfig/ispconfig3/repository/archive.tar.gz?ref=stable-3.1 &&\
	tar xfz ispconfig.tar.gz &&\
	mv ispconfig3* ispconfig3_install

ADD ./start.sh /start.sh
ADD ./autoinstall.ini /root/ispconfig3_install/install/autoinstall.ini
RUN mv /bin/systemctl /bin/systemctloriginal
ADD ./systemctl /bin/systemctl

RUN \
	mkdir -p /var/run/sshd /var/log/supervisor /var/run/supervisor /run/php/ &&\
	chmod 755 /start.sh /bin/systemctl 
	
	

	


# CLEANING
RUN \
	apt-get autoremove -y &&\
	apt-get clean &&\
	rm -rf /tmp/* /var/tmp/* $HOME/.cache/* /var/cache/apt/* &&\
	# Remove apt lists
	rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/*



EXPOSE 20/tcp 21/tcp 22/tcp 80/tcp 443/tcp 8080/tcp

VOLUME ["/var/www/","/var/log/"]

CMD ["/bin/bash", "/start.sh"]
