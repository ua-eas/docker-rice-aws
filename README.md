University of Arizona Kuali Rice Docker Image
=======================================================

This repository is for the Kuali team's Rice image used for the UAccess Financials application.

### Description
This project defines an image used for the Rice Docker container.

### Requirements
This is based on a **java8tomcat7** tagged image from the _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/tomcat7_ AWS ECR repository. 

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
