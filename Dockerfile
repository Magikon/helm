ARG DOCKER_VERSION=19.03.1
ARG ALPINE_VERSION=3.10.1
FROM docker:${DOCKER_VERSION} as dockerbase

ARG ALPINE_VERSION=${ALPINE_VERSION}
FROM alpine:${ALPINE_VERSION}

ARG KUBEVAL_VERSION=0.13.0
ARG HELM_VERSION=v2.14.3
ARG CLOUD_SDK_VERSION=257.0.0

ENV KUBEVAL_VERSION=${KUBEVAL_VERSION}
ENV HELM_VERSION=${HELM_VERSION}
ENV CLOUD_SDK_VERSION=${CLOUD_SDK_VERSION}
ENV DOCKER_CLI_EXPERIMENTAL=enabled

ENV PATH=$PATH:/google-cloud-sdk/bin

COPY --from=mikayel/cloudflare-lite-api /usr/local/bin/cflite /usr/local/bin/cflite
COPY ./functions/. /usr/local/bin/

RUN chmod +x /usr/local/bin/*; apk --update add --no-cache ca-certificates curl python py-crcmod bash libc6-compat openssh-client git gnupg jq gettext findutils tar gzip

RUN curl -L https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz | tar xz -C /tmp && mv /tmp/kubeval /usr/local/bin/kubeval

RUN curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xvz && mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64 && helm init --client-only && \
    helm plugin install https://github.com/viglesiasce/helm-gcs > /dev/null 2>&1 && \
    helm plugin install https://github.com/databus23/helm-diff > /dev/null 2>&1 && \
    helm plugin install https://github.com/rimusz/helm-tiller > /dev/null 2>&1 && rm -rf /tmp/*

COPY --from=dockerbase /usr/local/bin/docker /usr/local/bin/docker

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    google-cloud-sdk/install.sh --path-update=true --bash-completion=true --additional-components kubectl alpha beta > /dev/null 2>&1 && \
    google-cloud-sdk/bin/gcloud --quiet config set core/disable_usage_reporting true > /dev/null 2>&1 && \
    google-cloud-sdk/bin/gcloud --quiet config set component_manager/disable_update_check true > /dev/null 2>&1 && \
    google-cloud-sdk/bin/gcloud --quiet config set metrics/environment github_docker_image > /dev/null 2>&1 && \
    find /google-cloud-sdk -type d -name "*backup*" | xargs rm -fr && \
    rm -f /google-cloud-sdk/bin/kubectl.* 
    
VOLUME ["/root/.config"]