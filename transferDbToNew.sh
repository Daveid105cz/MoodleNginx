#!/bin/bash

# make a backup of mysql database running outside of docker
mysqldump -u root moodle > ./dbBackup.sql
# mysqldump -u root "$moodle_db_name" > "$newDir/database.sql" 


# fill the database in the container with the backup
docker exec -i moodle_database mysql -u moodle_user -ppassword moodle < ./dbBackup.sql

