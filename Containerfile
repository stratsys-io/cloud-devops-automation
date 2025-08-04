FROM docker.io/node:lts-alpine3.20

# Set shell to use pipefail for safer piping
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Pin package versions (replace x.y.z with actual versions)
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN apk add --no-cache --virtual .pipeline-deps readline linux-pam && \
    apk add --no-cache bash sudo shadow jq && \
    apk del .pipeline-deps
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN apk add --no-cache curl openssl docker-cli git openssh-client yq

# Resolve Dependencies [trivy]
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.18.3
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Resolve Dependencies [Helm]
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | DESIRED_VERSION=v3.16.2 bash
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Resolve Dependencies [ArgoCD]
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.14.5/argocd-linux-amd64 && chmod +x /usr/local/bin/argocd

# Resolve Dependencies [kubectl]
RUN curl -o /usr/local/bin/kubectl -L "https://dl.k8s.io/release/v1.28.5/bin/linux/amd64/kubectl" && chmod +x /usr/local/bin/kubectl

RUN curl -o /usr/local/bin/hadolint -L "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64" && chmod +x /usr/local/bin/hadolint

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"
CMD [ "/bin/bash" ]
