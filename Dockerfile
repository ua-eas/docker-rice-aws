FROM 760232551367.dkr.ecr.us-west-2.amazonaws.com/kuali/tomcat7:java8tomcat7

RUN groupadd -r kuali && useradd -r -g kuali kualiadm

# copy in the tomcat utility scripts
COPY bin /usr/local/bin/

# set rice web app directory owner and group
RUN chmod +x /usr/local/bin/*

# set up default umask for root
RUN echo "umask 002" >> /root/.bashrc

# create some useful shortcut environment variables
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
ENV SMTP_SECURITY_DIRECTORY=/security/smtp
ENV TOMCAT_CONFIG_DIRECTORY=/configuration/tomcat-config
ENV RICE_CONFIG_DIRECTORY=/configuration/rice-config

# copy in the new relic jar file
COPY classes $TOMCAT_SHARE_LIB

# setup log rotate
# theoretically logrotate will run every hour and use the configuration defined in the /etc/logrotate.d/tomcat7 file
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
ADD logrotate /etc/logrotate.d/tomcat7
RUN chmod 644 /etc/logrotate.d/tomcat7

# Copy the Application WAR in
COPY files/rice.war $TOMCAT_RICE_DIR/rice.war

# Install Sendmail Services
#http://docs.aws.amazon.com/ses/latest/DeveloperGuide/sendmail.html
RUN yum -y clean all && rpmdb --rebuilddb && yum -y install sendmail m4 sendmail-cf cyrus-sasl-plain

# Append /etc/mail/access file
RUN echo "Connect:email-smtp.us-west-2.amazonaws.com RELAY" >> /etc/mail/access
# Regenerate /etc/mail/access.db
RUN rm /etc/mail/access.db && sudo makemap hash /etc/mail/access.db < /etc/mail/access
# Save a back-up copy of /etc/mail/sendmail.mc and /etc/mail/sendmail.cf
RUN cp /etc/mail/sendmail.mc /etc/mail/sendmail.mc.old
RUN cp /etc/mail/sendmail.cf /etc/mail/sendmail.cf.old
# Update /etc/mail/sendmail.mc file with AWS Region info
COPY sendmail/sendmail.mc /etc/mail/sendmail.mc
RUN  sudo chmod 666 /etc/mail/sendmail.cf
RUN  sudo m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
RUN  sudo chmod 644 /etc/mail/sendmail.cf

ENTRYPOINT /usr/local/bin/tomcat-start
