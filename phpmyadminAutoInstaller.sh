#!/bin/bash
#Update
apt-get install pwgen -y
apt update && apt upgrade -y

#HauptPakete lol
apt install ca-certificates apt-transport-https lsb-release gnupg curl nano unzip -y
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt update
apt install apache2 -y
apt install php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-xsl php7.4-zip php7.4-bz2 libapache2-mod-php7.4 -y
apt install mariadb-server mariadb-client -y
#mysql_secure_installation
cd /usr/share
#wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -O phpmyadmin.zip
unzip phpmyadmin.zip
rm phpmyadmin.zip
mv phpMyAdmin-*-all-languages phpmyadmin
chmod -R 0755 phpmyadmin

#Vhost Erstellen
echo -e '
Alias /phpmyadmin /usr/share/phpmyadmin
<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
</Directory>
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
' >> /etc/apache2/conf-available/phpmyadmin.conf

a2enconf phpmyadmin
systemctl reload apache2
mkdir /usr/share/phpmyadmin/tmp/
chown -R www-data:www-data /usr/share/phpmyadmin/tmp/

#MySQL Konfigurieren und User Erstellen
PASS=`pwgen -s 40 1`
mysql <<MYSQL_SCRIPT
CREATE USER 'pma'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON *.* TO 'pma'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

ip=$(hostname -i)

#InstallationsLog / Zugangsdaten Erstellen
touch /root/phpmyadmin-data.txt
echo -e "######### PHPMYADMIN Zugang #########" >> /root/phpmyadmin-data.txt
echo -e "Link: http://"$ip"/phpmyadmin" >> /root/phpmyadmin-data.txt
echo -e "User: pma" >> /root/phpmyadmin-data.txt
echo -e "Passwort: $PASS" >> /root/phpmyadmin-data.txt
