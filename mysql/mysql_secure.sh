#!/bin/bash
PURGE_EXPECT_WHEN_DONE=0
CURRENT_MYSQL_PASSWORD=''
NEW_MYSQL_PASSWORD="${1}"

echo "$NEW_MYSQL_PASSWORD"

mysqld_safe --skip-grant-tables &
myPid=$!

echo "--> Wait 7s to boot up on pid ${myPid}"
sleep 7

echo "--> Set root password"

SECURE_MYSQL=$(expect -c "

set timeout 3
spawn mysql_secure_installation

expect \"Press y|Y for Yes, any other key for No:\"
send \"n\r\"

expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"

expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"

expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"

expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"

expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"
apt-get -yqq purge expect
exit 0