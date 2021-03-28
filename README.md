# helm, gcloud, docker
    
### build
    HELM_VERSION=3.5.3
    DOCKER_VERSION=20.10.5
    CLOUD_SDK_VERSION=333.0.0
    ALPINE_VERSION=3.13.3
	
    chmod -R +x ./functions/
    docker build -t $DOCKER_IMAGE_TAG_VERSION --build-arg HELM_VERSION=v$HELM_VERSION --build-arg CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION --build-arg DOCKER_VERSION=$DOCKER_VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION .
    docker build -f DockerfileAlpine -t $DOCKER_IMAGE_TAG_VERSION-alpine --build-arg HELM_VERSION=v$HELM_VERSION --build-arg DOCKER_VERSION=$DOCKER_VERSION .
 
    
### Images can be found here 
    https://cloud.docker.com/repository/docker/mikayel/helm



