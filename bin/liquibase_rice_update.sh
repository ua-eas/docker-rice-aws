#!/bin/bash
#Update Database with Liquibase Changesets if they exist
LIQUIBASE_BIN=/usr/local/bin/
LIQUIBASE_CHANGELOG_DIR=$UA_DB_CHANGELOGS_DIR/edu/arizona/changelog
APP_VERSION=$1

cd $LIQUIBASE_CHANGELOG_DIR

LIQUIBASE_STATUS=$($LIQUIBASE_BIN/liquibase_rice.sh --changeLogFile=db.changelog-master.xml status)
 if [[ $LIQUIBASE_STATUS =~ "change sets have not been applied" ]]; then
  $LIQUIBASE_BIN/liquibase_rice.sh --changeLogFile=db.changelog-master.xml update
  $LIQUIBASE_BIN/liquibase_rice.sh tag $APP_VERSION
 fi 
