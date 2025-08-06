FROM docker.io/node:lts-alpine3.20

# Set shell to use pipefail for safer piping
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install base packages and Azure DevOps dependencies
RUN apk add --no-cache --virtual .pipeline-deps readline linux-pam && \
    apk add --no-cache bash sudo shadow jq curl openssl docker-cli docker-cli-buildx git openssh-client yq ca-certificates && \
    apk del .pipeline-deps

# Resolve Dependencies [trivy]
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.55.2

# Resolve Dependencies [Helm]
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | DESIRED_VERSION=v3.16.3 bash

# Resolve Dependencies [ArgoCD]
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.14.7/argocd-linux-amd64 && chmod +x /usr/local/bin/argocd

# Resolve Dependencies [kubectl]
RUN curl -o /usr/local/bin/kubectl -L "https://dl.k8s.io/release/v1.31.2/bin/linux/amd64/kubectl" && chmod +x /usr/local/bin/kubectl

# Resolve Dependencies [hadolint]
RUN curl -o /usr/local/bin/hadolint -L "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64" && chmod +x /usr/local/bin/hadolint

# Create Azure DevOps agent user
RUN adduser -D -s /bin/bash azp

# Set up docker group and add azp user to it
RUN addgroup docker && adduser azp docker

# Configure sudo for azp user
RUN echo "azp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /azp

# Set environment variables for Azure DevOps
ENV AGENT_ALLOW_RUNASROOT=1

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"
CMD [ "/bin/bash" ]
