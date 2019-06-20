#!/bin/bash
PURGE_EXPECT_WHEN_DONE=0
CURRENT_MYSQL_PASSWORD=''
NEW_MYSQL_PASSWORD="${1}"

apt-get -yqq install expect
mysqld_safe --skip-grant-tables &
myPid=$!

echo "--> Wait 7s to boot up on pid ${myPid}"
sleep 7

echo "--> Set root password"

SECURE_MYSQL=$(expect -c "

set timeout 3
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"$CURRENT_MYSQL_PASSWORD\r\"

expect \"root password?\"
send \"y\r\"

expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"n\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"
apt-get -yqq purge expect
exit 0