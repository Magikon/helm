# helm, gcloud, docker, kubeval

### To know the latest releases
    HELM_VERSION=$(curl -s https://github.com/helm/helm/releases | sed -n '/Latest release<\/a>/,$p' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | awk '{print substr($1,2); }')
    KUBEVAL_VERSION=$(curl -s https://github.com/instrumenta/kubeval/releases/ | sed -n '/Latest release<\/a>/,$p' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    CLOUD_SDK_VERSION=$(curl -s https://github.com/google-cloud-sdk/google-cloud-sdk/releases | sed -n '/Releases<\/a>/,$p' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | awk '{print substr($1,2); }')
    DOCKER_VERSION=$(curl -s https://github.com/docker/docker-ce/releases | sed -n '/Latest release<\/a>/,$p' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | awk '{print substr($1,2); }')
    
### for build use
    docker build -t yourtag --build-arg HELM_VERSION=v$HELM_VERSION --build-arg KUBEVAL_VERSION=$KUBEVAL_VERSION --build-arg CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION --build-arg DOCKER_VERSION=$DOCKER_VERSION .
    docker build -f DockerfileAlpine -t yourtag-alpine --build-arg HELM_VERSION=v$HELM_VERSION --build-arg KUBEVAL_VERSION=$KUBEVAL_VERSION --build-arg DOCKER_VERSION=$DOCKER_VERSION .
    
### Images can be found here 
    https://cloud.docker.com/repository/docker/mikayel/helm



