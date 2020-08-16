#!/bin/bash

echo -e "\e[1;33mAtualizando Sistema Operacional \e[0m"
apt -y upgrade &&
echo -e "\e[1;32mAtualizado \e[0m"

echo -e "\e[1;33mInstalando Dependências do Sistema \e[0m"
apt -y install curl git nano wget unzip sngrep sox libnewt-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev build-essential unixodbc unixodbc-dev apache2 php php-cgi php-mysqli php-pear php-mbstring php-gettext libapache2-mod-php php-common php-phpseclib php-mysql &&
echo -e "\e[1;32mInstalado \e[0m"

echo -e "\e[1;33mBaixando: MySQL 8 \e[0m"
cd /usr/src/ &&
curl -sLO https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb && dpkg -i mysql-apt-config_0.8.15-1_all.deb &&
echo -e "\e[1;32mBaixado \e[0m"

echo -e "\e[1;33mInstalando: MySQL 8 \e[0m"
apt update && apt -y install mysql-server &&
echo -e "\e[1;32mInstalado \e[0m"

echo -e "\e[1;33mAlterando: mysqld.cnf \e[0m"
cp -p /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.sample &&
echo "skip-log-bin" >> /etc/mysql/mysql.conf.d/mysqld.cnf &&
echo -e "\e[1;32mAlterado \e[0m"

echo -e "\e[1;33mReiniciando: MySQL \e[0m"
systemctl restart mysql &&
systemctl status mysql | grep 'Active:' &&
echo -e "\e[1;32mReiniciado \e[0m"

echo -e "\e[1;33mCriando: Banco de Dados asterisk e Usuário asterisk \e[0m"
echo "CREATE DATABASE asterisk;" | mysql -u root -p'P4$$w0rd'
echo "CREATE USER 'asterisk'@'localhost' IDENTIFIED WITH mysql_native_password BY 'asterisk';" | mysql -u root -p'P4$$w0rd'
echo "GRANT ALL PRIVILEGES ON asterisk.* TO 'asterisk'@'localhost';" | mysql -u root -p'P4$$w0rd'
echo "FLUSH PRIVILEGES;" | mysql -u root -p'P4$$w0rd'
echo -e "\e[1;32mCriado \e[0m"

echo -e "\e[1;33mInstalando: phpMyAdmin \e[0m"
cd /usr/src/ &&
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz &&
wget https://files.phpmyadmin.net/phpmyadmin.keyring &&
gpg --import phpmyadmin.keyring &&
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz.asc &&
gpg --verify phpMyAdmin-latest-all-languages.tar.gz.asc &&
mkdir /var/www/html/phpMyAdmin &&
tar xvf phpMyAdmin-latest-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpMyAdmin/ &&
cp -p /var/www/html/phpMyAdmin/config.sample.inc.php /var/www/html/phpMyAdmin/config.inc.php &&
cp -p /var/www/html/phpMyAdmin/config.inc.php /var/www/html/phpMyAdmin/config.inc.php.sample &&
sed -i "/\$cfg\['blowfish_secret'\] = /s/''/'Ll0W*sUNrvyl5vif7$gKW#MF3wkkDfQ6'/" /var/www/html/phpMyAdmin/config.inc.php &&
chmod 660 /var/www/html/phpMyAdmin/config.inc.php &&
chown -R www-data:www-data /var/www/html/phpMyAdmin/ &&
systemctl restart apache2 &&
echo -e "\e[1;32mInstalado \e[0m"

# Instala e configura o unixODBC manual

#cd /usr/src/
#wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.7.tar.gz
#gunzip unixODBC*.tar.gz
#tar xvf unixODBC*.tar
#cd unixODBC*/
#./configure
#make
#make install

#echo "Instalando: MySQL ODBC"
#cd /usr/src/
#wget https://dev.mysql.com/get/Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.21-linux-glibc2.12-x86-64bit.tar.gz
#gunzip mysql-connector-odbc-8.0.21-linux-glibc2.12-x86-64bit.tar.gz
#tar xvf mysql-connector-odbc-8.0.21-linux-glibc2.12-x86-64bit.tar
#cd mysql-connector-odbc-8.0.21-linux-glibc2.12-x86-64bit
#cp -p bin/* /usr/local/bin
#cp -p lib/* /usr/local/lib
#cd /usr/local/bin
#myodbc-installer -a -d -n "MySQL ODBC 8.0 Driver" -t "Driver=/usr/local/lib/libmyodbc8w.so"
#myodbc-installer -a -d -n "MySQL ODBC 8.0" -t "Driver=/usr/local/lib/libmyodbc8a.so"
#myodbc-installer -d -l

#nano /etc/odbcinst.ini

#[MySQL]
#Description=ODBC for MySQL
#Driver=/usr/local/lib/libmyodbc8w.so
#Setup=/usr/lib/x86_64-linux-gnu/odbc/libodbcmyS.so
#FileUsage=1

#nano /etc/odbc.ini

#[asterisk1]
#Description=MySQL connection to 'asterisk' database
#Driver=MySQL
#Database=asterisk
#Server=localhost
#Port=3306
#Socket=/run/mysqld/mysqld.sock

echo -e "\e[1;33mInstalando: Asterisk 16 LTS \e[0m"
cd /usr/src/ &&
curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz &&
tar xvf asterisk-16-current.tar.gz &&
cd asterisk-16*/ &&
contrib/scripts/get_mp3_source.sh &&
contrib/scripts/install_prereq install &&
./configure &&
make menuselect.makeopts &&
./menuselect/menuselect --enable ODBC_STORAGE menuselect.makeopts
./menuselect/menuselect --enable format_mp3 menuselect.makeopts
./menuselect/menuselect --enable app_meetme menuselect.makeopts	
./menuselect/menuselect --enable DONT_OPTIMIZE menuselect.makeopts
./menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts
./menuselect/menuselect --enable codec_opus menuselect.makeopts
./menuselect/menuselect --enable codec_silk menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-EN-WAV menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-EN-ULAW menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-EN-ALAW menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-EN-GSM menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-EN-G729 menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-EN-G722 menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-ES-WAV menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-ES-ULAW menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-ES-ALAW menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-ES-GSM menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-ES-G729 menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-ES-G722 menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-FR-WAV menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-FR-ULAW menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-FR-ALAW menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-FR-GSM menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-FR-G729 menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-FR-G722 menuselect.makeopts
./menuselect/menuselect --enable MOH-OPSOUND-ULAW menuselect.makeopts
./menuselect/menuselect --enable MOH-OPSOUND-ALAW menuselect.makeopts
./menuselect/menuselect --enable MOH-OPSOUND-GSM menuselect.makeopts
./menuselect/menuselect --enable MOH-OPSOUND-G729 menuselect.makeopts
./menuselect/menuselect --enable MOH-OPSOUND-G722 menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-EN-WAV menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-EN-ULAW menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-EN-ALAW menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-EN-GSM menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-EN-G729 menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-EN-G722 menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-FR-WAV menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-FR-ULAW menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-FR-ALAW menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-FR-GSM menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-FR-G729 menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-FR-G722 menuselect.makeopts &&
make &&
make install &&
make samples &&
make config &&
ldconfig &&
echo -e "\e[1;32mInstalado \e[0m"

groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk.asterisk /etc/asterisk
chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk.asterisk /usr/lib/asterisk
sleep 1
cp -p /etc/default/asterisk /etc/default/asterisk.sample
sed -i 's|#AST_USER="asterisk"|AST_USER="asterisk"|i' /etc/default/asterisk
sed -i 's|#AST_GROUP="asterisk"|AST_GROUP="asterisk"|i' /etc/default/asterisk
cp -p /etc/asterisk/asterisk.conf /etc/asterisk/asterisk.conf.sample
sed -i 's|;runuser = asterisk|runuser = asterisk|i' /etc/asterisk/asterisk.conf
sed -i 's|;rungroup = asterisk|rungroup = asterisk|i' /etc/asterisk/asterisk.conf
#cp -p /etc/asterisk/res_odbc.conf /etc/asterisk/res_odbc.conf.sample
#sed -i 's|enabled => no|enabled => yes|i' /etc/asterisk/res_odbc.conf
#sed -i 's|dsn => asterisk|dsn => asterisk1|i' /etc/asterisk/res_odbc.conf
#sed -i 's|;username => myuser|username => asterisk|i' /etc/asterisk/res_odbc.conf
#sed -i 's|;password => mypass|password => asterisk|i' /etc/asterisk/res_odbc.conf

#nano /etc/asterisk/res_odbc.conf
#pooling => no
#limit => 1

# Ativa res_odbc.so no Modulo do Asterisk

#cp -p /etc/asterisk/modules.conf /etc/asterisk/modules.conf.sample
#sed -e 's/autoload=yes/autoload=yes\npreload => res_odbc.so' /etc/asterisk/modules.conf
#nano /etc/asterisk/modules.conf 
# Adicionar depois do autoload = yes
#preload => res_odbc.so

# Importação das tabelas do Asterisk

#cd /usr/src/asterisk-*/contrib/ast-db-manage
#cp -p config.ini.sample config.ini
#sed -i 's|mysql://user:pass@localhost/asterisk|mysql://asterisk:asterisk@localhost/asterisk|i' /usr/src/asterisk-*/contrib/ast-db-manage/config.ini

#apt install -y python-mysqldb python-pip 
#pip install alembic
#alembic -c config.ini upgrade head

# Habilitar e Reiniciar o serviço do Asterisk

systemctl restart asterisk
systemctl enable asterisk

asterisk -vvvc
asterisk -rvvv
