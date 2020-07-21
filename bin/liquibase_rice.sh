#!/bin/bash
# liquibase_rice.sh: main liquibase script based on liquibase_kfs.sh
# Calls liquibase with correct database parameters
# for this environment, path to ojdbc6.jar file.

RICE_CONFIG_FILE=$RICE_CONFIG_DIRECTORY/rice-config.xml

# username, password and url are passed in from the rice config file
LIQUIBASE_DB_USERNAME=$(grep "datasource.username" $RICE_CONFIG_FILE | sed -e 's/^[ \t]*//' | sed -e 's/<param name="datasource\.username">//' | sed -e 's/<\/param>//')
LIQUIBASE_DB_PASSWORD=$(grep "datasource.password" $RICE_CONFIG_FILE | sed -e 's/^[ \t]*//' | sed -e 's/<param name="datasource\.password">//' | sed -e 's/<\/param>//')
LIQUIBASE_DB_URL=$(grep "datasource.url" $RICE_CONFIG_FILE | sed -e 's/^[ \t]*//' | sed -e 's/<param name="datasource\.url">//' | sed -e 's/<\/param>//')

exec /usr/bin/java -jar $LIQUIBASE_HOME/liquibase.jar \
--url="$LIQUIBASE_DB_URL" \
--username=$LIQUIBASE_DB_USERNAME \
--password=$LIQUIBASE_DB_PASSWORD \
--classpath=$TOMCAT_SHARE_LIB/ojdbc6.jar \
--driver=oracle.jdbc.driver.OracleDriver \
--logLevel=info \
$@