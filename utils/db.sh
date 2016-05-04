#################################################
#  db twig utils
#  (c) 2016 Inkton
#
#	All content that appear under NEST_HOME
#	are shared between the nest cushions.
# 	Use Twigs to change the application
# 	that operate on the content.
#
#  Rajitha Wijayaratne
#################################################

db_init() {
	DB_NAME=$(cat $NEST_APP_REGISTRY_PATH | jq -r '.database.name')
	DB_USER=$(cat $NEST_APP_REGISTRY_PATH | jq -r '.database.user')
	DB_PASSWORD=$(cat $NEST_APP_REGISTRY_PATH | jq -r '.database.password')
	DB_HOST_IP=$(cat $NEST_APP_REGISTRY_PATH | jq -r '.database.host_ip')
}

db_change_password() {
	db_init

	if [ "$NEST_DB_VENDOR" = mysql ]; then
		mysql -u $DB_USER -p$DB_PASSWORD -h $DB_HOST_IP $DB_NAME -e \
			'UPDATE mysql.user SET password=PASSWORD("$DB_PASSWORD") WHERE user="$DB_USER" AND Host="$DB_HOST_IP";FLUSH PRIVILEGES;'
	elif [ "$NEST_DB_VENDOR" = postgres ]; then
		sudo -u postgres psql -U $DB_USER -d $DB_NAME -c "alter user $DB_USER with password '$DB_PASSWORD';"
	fi
}

db_backup_schema() {
	db_init

	if [ "$NEST_DB_VENDOR" = mysql ]; then
		mysqldump --no-data $NEST_DB_BACKUP_OPTIONS --user $DB_USER -p$DB_PASSWORD --host $DB_HOST_IP $DB_NAME > $NEST_APP_DB_CREATE_SCRIPT_PATH
	elif [ "$NEST_DB_VENDOR" = postgres ]; then
		pg_dump --schema-only --ignore-version --host $DB_HOST_IP --password $DB_PASSWORD --username $DB_USER --verbose --file  > $NEST_APP_DB_CREATE_SCRIPT_PATH
	fi
}

db_backup_data() {
	db_init

	if [ "$NEST_DB_VENDOR" = mysql ]; then
		mysqldump --no-create-db --no-create-info $NEST_DB_BACKUP_OPTIONS --user $DB_USER -p$DB_PASSWORD --host $DB_HOST_IP $DB_NAME > $NEST_APP_DB_DATA_SCRIPT_PATH
	elif [ "$NEST_DB_VENDOR" = postgres ]; then
		pg_dump --data-only --ignore-version --host $DB_HOST_IP --password $DB_PASSWORD --username $DB_USER --verbose --file  > $NEST_APP_DB_DATA_SCRIPT_PATH
	fi
} 

db_restore_schema() {
	db_init

	if [ "$NEST_DB_VENDOR" = mysql ]; then	
		mysqlimport --delete --user $DB_USER -p$DB_PASSWORD --host $DB_HOST_IP $DB_NAME <  $NEST_APP_DB_CREATE_SCRIPT_PATH
	elif [ "$NEST_DB_VENDOR" = postgres ]; then
		pg_restore --clean --ignore-version --host $DB_HOST_IP --password $DB_PASSWORD --username $DB_USER --dbname $DB_NAME --verbose < $NEST_APP_DB_CREATE_SCRIPT_PATH
	fi
}

db_restore_data() {
	db_init

	if [ "$NEST_DB_VENDOR" = mysql ]; then	
		mysqlimport --delete --user $DB_USER -p$DB_PASSWORD --host $DB_HOST_IP $DB_NAME <  $NEST_APP_DB_DATA_SCRIPT_PATH
	elif [ "$NEST_DB_VENDOR" = postgres ]; then
		pg_restore --clean --ignore-version --host $DB_HOST_IP --password $DB_PASSWORD --username $DB_USER --dbname $DB_NAME --verbose < $NEST_APP_DB_DATA_SCRIPT_PATH
	fi
}

!@
