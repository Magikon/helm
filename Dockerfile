ARG DOCKER_VERSION=latest
ARG ALPINE_VERSION=latest
FROM docker:${DOCKER_VERSION} as dockerbase

ARG ALPINE_VERSION=${ALPINE_VERSION}
FROM alpine:${ALPINE_VERSION}

ARG HELM_VERSION=v3.7.2

ENV HELM_VERSION=${HELM_VERSION}
ENV DOCKER_CLI_EXPERIMENTAL=enabled

ENV PATH=$PATH:/google-cloud-sdk/bin

COPY --from=mikayel/cloudflare-lite-api /usr/local/bin/cflite /usr/local/bin/cflite

COPY ./functions/. /usr/local/bin/

RUN apk --update add --no-cache ca-certificates curl jq gettext findutils tar gzip bash python3 git openssh-client py-crcmod libc6-compat gnupg \
    && ln -sf python3 /usr/bin/python && python3 -m ensurepip && pip3 install --no-cache --upgrade pip setuptools

COPY --from=dockerbase /usr/local/bin/docker /usr/local/bin/docker

RUN curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xvz && mv linux-amd64/helm /usr/local/bin/helm && rm -rf linux-amd64 && \
    helm plugin install https://github.com/viglesiasce/helm-gcs > /dev/null 2>&1 && \
    helm plugin install https://github.com/databus23/helm-diff > /dev/null 2>&1 && \
    helm plugin install https://github.com/thynquest/helm-pack.git > /dev/null 2>&1 && find /tmp/* | xargs rm -fr

RUN curl -O https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    tar xzf google-cloud-sdk.tar.gz && rm google-cloud-sdk.tar.gz && \
    google-cloud-sdk/bin/gcloud --quiet components install kubectl beta kustomize gsutil> /dev/null 2>&1 && \
    google-cloud-sdk/bin/gcloud --quiet config set core/disable_usage_reporting true > /dev/null 2>&1 && \
    google-cloud-sdk/bin/gcloud --quiet config set component_manager/disable_update_check true > /dev/null 2>&1 && \
    google-cloud-sdk/bin/gcloud --quiet config set metrics/environment github_docker_image > /dev/null 2>&1 && \
    find /google-cloud-sdk -type d -name "*backup*" | xargs rm -fr && \
    rm -f /google-cloud-sdk/bin/kubectl.*

VOLUME ["/root/.config"]