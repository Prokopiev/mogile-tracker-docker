#!/bin/bash
set -x

if [ "`echo ${NODE_HOST}`" == "" ]
then
  NODE_HOST="mogile-node"
fi

if [ "`echo ${NODE_PORT}`" == "" ]
then
  NODE_PORT="7500"
fi

if [ "`echo ${MYSQL_ROOT_USER}`" == "" ]
then
  MYSQL_ROOT_USER="root"
fi

if [ "`echo ${MYSQL_ROOT_PASSWORD}`" == "" ]
then
  MYSQL_ROOT_PASSWORD="root"
fi

if [ "`echo ${MYSQL_MOGILE_DB}`" == "" ]
then
  MYSQL_MOGILE_DB="mogilefs"
fi

if [ "`echo ${MYSQL_MOGILE_USER}`" == "" ]
then
  MYSQL_MOGILE_USER="mogile"
fi

if [ "`echo ${MYSQL_MOGILE_PASSWORD}`" == "" ]
then
  MYSQL_MOGILE_PASSWORD="mogile"
fi

if [ "`echo ${MYSQL_MOGILE_HOST}`" == "" ]
then
  MYSQL_MOGILE_HOST="localhost"
fi

if [ "`echo ${MYSQL_PORT}`" == "" ]
then
  MYSQL_PORT="3306"
fi

mogdbsetup --type=MySQL --yes --dbport=${MYSQL_PORT} --dbhost=${MYSQL_MOGILE_HOST} --dbrootuser=${MYSQL_ROOT_USER} --dbrootpass=${MYSQL_ROOT_PASSWORD} --dbname=${MYSQL_ROOT_PASSWORD} --dbuser=${MYSQL_MOGILE_USER} --dbpassword=${MYSQL_MOGILE_PASSWORD}

sed -i "s/\MYSQL_MOGILE_HOST/${MYSQL_MOGILE_HOST}/g" /etc/mogilefs/mogilefsd.conf
sed -i "s/\MYSQL_MOGILE_DB/${MYSQL_MOGILE_DB}/g" /etc/mogilefs/mogilefsd.conf
sed -i "s/\MYSQL_MOGILE_USER/${MYSQL_MOGILE_USER}/g" /etc/mogilefs/mogilefsd.conf
sed -i "s/\MYSQL_MOGILE_PASSWORD/${MYSQL_MOGILE_PASSWORD}/g" /etc/mogilefs/mogilefsd.conf
sed -i "s/\MYSQL_MOGILE_PORT/${MYSQL_MOGILE_PORT}/g" /etc/mogilefs/mogilefsd.conf

sudo -u mogile mogilefsd --daemon -c /etc/mogilefs/mogilefsd.conf

mogadm --trackers=127.0.0.1:7001 host add mogilestorage --ip=${NODE_HOST} --port=${NODE_PORT} --status=alive
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 1
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 2

if [ "`echo ${DOMAIN_NAME}`" != "" ]
then
  mogadm --trackers=127.0.0.1:7001 domain add ${DOMAIN_NAME}
  mogadm class modify sbf default --replpolicy='MultipleDevices()'

  # Add all given classes
  if [ "`echo ${CLASS_NAMES}`" != "" ]
  then
    for class in ${CLASS_NAMES}
    do
      mogadm --trackers=127.0.0.1:7001 class add ${DOMAIN_NAME} $class --replpolicy="MultipleDevices()"
    done
  fi
fi

mogadm check

pkill mogilefsd

sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf
