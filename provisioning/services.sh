$!/usr/bin/env bash
timedatectl set-timezone ${VAGRANT_TIMEZONE}

#Pre-set lamp server config options
debconf-set-selections <<< "mysql-server mysql-server/root_password password ${VAGRANT_DEV_MYP}"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${VAGRANT_DEV_MYP}"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean false"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password ${VAGRANT_DEV_MYP}"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password ${VAGRANT_DEV_MYP}"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password ${VAGRANT_DEV_MYP}"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"

#install apt packages
apt-get update && apt-get install -y zip lamp-server^ php-mbstring php7.0-intl php7.0-mbstring php-gettext imagemagick php-imagick php-curl phpmyadmin git beanstalkd php-redis redis-server composer;

#create default database
mysql -uroot -p${VAGRANT_DEV_MYP} -e "CREATE DATABASE IF NOT EXISTS ${VAGRANT_DB} DEFAULT COLLATE = 'utf8_unicode_520_ci'";

#deploy apache config
cp -ua ${VAGRANT_MOUNT_DIR}/provisioning/apache2 /etc/
cd /etc/apache2/sites-available/
sed -i.previous 's/__PROJECT_NAME__/'${VAGRANT_PROJECT_NAME}'/' *.conf
a2ensite *${VAGRANT_ENVIRONMENT}*.conf && a2dissite *default*.conf;
a2enmod rewrite
service apache2 reload

#deploy redis config
cp -ua ${VAGRANT_MOUNT_DIR}/provisioning/redis /etc/
service redis-server restart

#deploy bash profile
cp -ua ${VAGRANT_MOUNT_DIR}/provisioning/bash/bash_profile ${VAGRANT}/.bash_profile
sed -i.previous 's/__PROJECT_NAME__/'${VAGRANT_PROJECT_NAME}'/' ${VAGRANT}/.bash_profile


#Install composer packages
cd ${VAGRANT_MOUNT_DIR}
cd ..
cp -r ${VAGRANT_PROJECT_NAME} /tmp/${VAGRANT_PROJECT_NAME}
rm -rf ${VAGRANT_PROJECT_NAME}/*
rm -rf ${VAGRANT_PROJECT_NAME}/.??*
composer create-project acquia/lightning-project ${VAGRANT_PROJECT_NAME} --no-interaction
cp -r /tmp/${VAGRANT_PROJECT_NAME}/* ${VAGRANT_PROJECT_NAME}/
if [ -e ${VAGRANT_PROJECT_NAME}/vendor ]
then
    echo "Move successful; deleting temp project."
    rm -rf /tmp/${VAGRANT_PROJECT_NAME}
fi