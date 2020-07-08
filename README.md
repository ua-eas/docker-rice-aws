University of Arizona Kuali Rice Docker Image
=======================================================

This repository is for the Kuali team's Rice image used for the UAccess Financials application.

### Description
This project defines an image used for the Rice Docker container.

### Requirements
This is based on a **java11tomcat8** tagged image from the _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/tomcat8_ AWS ECR repository. 

### Local Testing
The following steps can be used to troubleshoot changes to the Dockerfile without running Rice (which requires a valid UAF database):
1. Make sure you have a `kuali/tomcat8:java11tomcat8-ua-release-$BASE_IMAGE_TAG_DATE` image in your Docker repository. (This may require a local build of the *java11tomcat8* base image).
2. Temporarily change the Dockerfile to define the base image as `FROM kuali/tomcat8:java11tomcat8-ua-release-$BASE_IMAGE_TAG_DATE` and the ENTRYPOINT as `ENTRYPOINT /usr/local/bin/local-testing.sh`.
3. Run this on the command line to get a rice.war of the Rice build to include in your Docker image. The $RICE_APP_VERSION should be what is in a parent pom.xml (e.g. 2.7.0-ua-release54-SNAPSHOT), and $RICE_BRANCH_NAME should be an existing feature branch or rice-2.6-ua-development. 
Example for Linux: `wget "https://kfs.ua-uits-kuali-nonprod.arizona.edu/nexus/service/local/artifact/maven/redirect?r=snapshots&g=org.kuali.rice&a=rice-standalone&v=$RICE_APP_VERSION&e=war&c=$RICE_BRANCH_NAME" -O files/rice.war`
Example for Mac: `curl "https://kfs.ua-uits-kuali-nonprod.arizona.edu/nexus/service/local/artifact/maven/redirect?r=snapshots&g=org.kuali.rice&a=rice-standalone&v=$RICE_APP_VERSION&e=war&c=$RICE_BRANCH_NAME" -o "files/rice.war"`
4. Run this command to build a *rice* Docker image, replacing $BASE_IMAGE_TAG_DATE with the date referenced in step 1: `docker build --build-arg BASE_IMAGE_TAG_DATE=$BASE_IMAGE_TAG_DATE -t kuali/rice:rice-ua-release-test .`
5. You can run a rice Docker container using a command like: `docker run -d --name=rice --privileged=true kuali/rice:rice-ua-release-test .`
6. Delete the files/rice.war and undo the temporary changes to the Dockerfile before committing your changes.

### Building With Jenkins
The build command we use is `docker build --build-arg DOCKER_REGISTRY=${DOCKER_REGISTRY} --build-arg BASE_IMAGE_TAG_DATE=${BASE_IMAGE_TAG_DATE} -t ${DOCKER_REPOSITORY_NAME} .`
* `$DOCKER_REGISTRY` is the location of the Docker image repository in AWS. The value will be a variable in our Jenkins job and defined as `397167497055.dkr.ecr.us-west-2.amazonaws.com`.
* `$BASE_IMAGE_TAG_DATE` corresponds to the creation date in a tag of the *java8tomcat7* Docker image.
* `$DOCKER_REPOSITORY_NAME` is the name of the AWS ECR repository, which is _kuali/rice_.
* `$TAG` is the image tag we construct. It has the version of the KualiCo Rice code that the UA code is based on, the _ua-release_ number, whether it is a release or a snapshot, and the Jira ticket number if this is for a prototype environment.

We then tag and push the image to AWS with commands similar to the following: 
```
docker tag ${DOCKER_REPOSITORY_NAME}:latest ${DOCKER_REPOSITORY_URI}:${APP_TAG}
docker push ${DOCKER_REPOSITORY_URI}:${APP_TAG}
```

Examples of resulting tags:
- Daily/snapshot build: _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/rice:dev_
- Prototype build: _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/rice:FIN-629-2.6.0-ua-release51-SNAPSHOT-rice-2.6-ua-development_
- Release build: _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/rice:2.6.0-ua-release51_

Jenkins link: https://kfs-jenkins.ua-uits-kuali-nonprod.arizona.edu/job/Development/

### Running A Container
The Rice Docker container is run on an EC2 instance in AWS. 

More information can be found on Confluence: https://confluence.arizona.edu/display/KAST/AWS+Environment+Basics.

### Liquibase
We utilize liquibase to apply and keep track of database changes. It is run before Tomcat starts up the Rice application. The current liquibase was downloaded from https://www.liquibase.org/download, and then added to this project in the liquibase folder.