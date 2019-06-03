#!/bin/bash
#######################################################
# $Name:         mysql_auto_backup.sh
# $Version:      1.0
# $Function:     Backup MySQL Databases Script
# $Author:       skywalkerwie
# $organization: https://github.com/skywalkerwei
# $Description:  定期备份MySQL数据库
# $Crontab:      10 3 * * *  bash ./backup/mysql_auto_backup.sh >/dev/null 2>&1
#######################################################

# Shell Env
SHELL_NAME="mysql_auto_backup.sh"

BASE_PATH="/wwwroot/backup"

# get current time
CURRENT_TIME=$(date '+%Y-%m-%d-%H:%M:%S')

# get data eg：201911
DIR_NAME=$(date -d yesterday +"%Y%m")

# get days eg：03
DAY=$(date -d yesterday +"%d")

# db name
DB_NAME="juhepay"

# backup path
BACKUP_PATH=$BASE_PATH/$DB_NAME/$DIR_NAME

# backup sql file name
BACKUP_NAME=${DAY}".sql"

# create log directory
mkdir -p $BACKUP_PATH

# run docker
RES=$(docker exec dnmp-mysql mysqldump -uroot -p123456 $DB_NAME > $BACKUP_PATH/$BACKUP_NAME)
echo $CURRENT_TIME-"备份结果："$? >> $BACKUP_PATH".log"
