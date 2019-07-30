ARG DOCKER_VERSION=test
FROM docker:${DOCKER_VERSION} as dockerbase

FROM alpine

ARG KUBEVAL_VERSION=test
ARG HELM_VERSION=test
ARG CLOUD_SDK_VERSION=test

ENV KUBEVAL_VERSION=$KUBEVAL_VERSION
ENV HELM_VERSION=$HELM_VERSION
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV PATH=/google-cloud-sdk/bin:$PATH

RUN apk --update add --no-cache ca-certificates curl python py-crcmod bash libc6-compat openssh-client git gnupg jq gettext

RUN curl -L https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz | tar xz -C /usr/local/bin

RUN curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xvz && mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && rm -rf linux-amd64 && helm init --client-only && \
    helm plugin install https://github.com/viglesiasce/helm-gcs > /dev/null 2>&1 && \
    helm plugin install https://github.com/databus23/helm-diff > /dev/null 2>&1 && \
    helm plugin install https://github.com/rimusz/helm-tiller > /dev/null 2>&1

COPY --from=dockerbase /usr/local/bin/docker /usr/local/bin/docker

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    google-cloud-sdk/install.sh --path-update=true --bash-completion=true --additional-components kubectl alpha beta && \
    google-cloud-sdk/bin/gcloud --quiet config set core/disable_usage_reporting true && \
    google-cloud-sdk/bin/gcloud --quiet config set component_manager/disable_update_check true && \
    google-cloud-sdk/bin/gcloud --quiet config set metrics/environment github_docker_image && \
    find /google-cloud-sdk -type d -name "*backup*" | xargs rm -fr && \
    rm -f /google-cloud-sdk/bin/kubectl.*
    
VOLUME ["/root/.config"]
