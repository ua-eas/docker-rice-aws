FROM 760232551367.dkr.ecr.us-west-2.amazonaws.com/kuali/java8tomcat7

RUN groupadd -r kuali && useradd -r -g kuali kualiadm

# copy in the tomcat utility scripts
COPY bin /usr/local/bin/

# set rice web app directory owner and group
RUN chmod +x /usr/local/bin/*

# create some useful shorcut environment variables
ENV TOMCAT_BASE_DIR=$CATALINA_HOME
ENV TOMCAT_SHARE_LIB=$TOMCAT_BASE_DIR/lib
ENV TOMCAT_SHARE_BIN=$TOMCAT_BASE_DIR/bin
ENV TOMCAT_WEBAPPS_DIR=$TOMCAT_BASE_DIR/webapps
ENV TOMCAT_RICE_DIR=$TOMCAT_WEBAPPS_DIR/rice
ENV TOMCAT_RICE_WEBINF_DIR=$TOMCAT_RICE_DIR/WEB-INF
ENV TRANSACTIONAL_DIRECTORY=/transactional
ENV CONFIG_DIRECTORY=/configuration
ENV LOGS_DIRECTORY=/logs
ENV SECURITY_DIRECTORY=/security
ENV TOMCAT_CONFIG_DIRECTORY=/configuration/tomcat-config
ENV RICE_CONFIG_DIRECTORY=/configuration/rice-config
#FIXME is this needed?
ENV TOMCAT_RICE_CORE_DIR=$TOMCAT_RICE_DIR/rice-core-ua

# copy in the new relic jar file
COPY classes $TOMCAT_SHARE_LIB

# setup log rotate
#FIXME cron is different (or maybe not installed yet?) in CentOS
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
ADD logrotate /etc/logrotate.d/tomcat7
RUN chmod 644 /etc/logrotate.d/tomcat7

# Copy the Application WAR in
COPY files/rice.war $TOMCAT_RICE_DIR/rice.war

ENTRYPOINT /usr/local/bin/tomcat-start
