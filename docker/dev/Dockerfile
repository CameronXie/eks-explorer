FROM cameronx/aws-deployer:latest AS develop

RUN set -eux \
    && apt-get update && apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      jq \
      jsonnet \
      less \
      lsb-release \
      make \
      nginx \
      python3 \
      python3-pip \
      python3-venv \
      shellcheck \
      tree \
      unzip \
      vim \
      zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

ENV PATH /usr/local/go/bin:$PATH
ARG GOLANG_VERSION=1.23.3
RUN set -eux; \
    url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz"; \
    sha256='a0afb9744c00648bafb1b90b4aba5bdb86f424f02f9275399ce0c20b93a2c3a8'; \
    wget -O go.tgz "$url" --progress=dot:giga; \
    echo "$sha256 *go.tgz" | sha256sum -c -; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz

ARG ACTIONLINT_VERSION=1.7.8
ARG ARGOCD_VERSION=v2.13.1
ARG ARGO_ROLLOUTS_VERSION=v1.7.2
ARG OTELCOL_VERSION=0.133.0
ARG TERRAFORM_VERSION=1.9.8
ARG TFLINT_VERSION=v0.54.0

RUN set -eux \
    # install actionlint
    && wget -q -O actionlint.tar.gz https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz \
    && tar -xzf actionlint.tar.gz \
    && mv actionlint /usr/local/bin \
    # install argocd
    && curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 \
    && install -m 555 argocd-linux-amd64 /usr/local/bin/argocd \
    && rm argocd-linux-amd64 \
    # install argo rollouts
    && curl -sSL -o kubectl-argo-rollouts-linux-amd64 https://github.com/argoproj/argo-rollouts/releases/download/${ARGO_ROLLOUTS_VERSION}/kubectl-argo-rollouts-linux-amd64 \
    && chmod +x ./kubectl-argo-rollouts-linux-amd64 \
    && mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts \
    # install terraform
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    # install OpenTelemetry Collector Contrib \
    && curl -fsSL https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTELCOL_VERSION}/otelcol-contrib_${OTELCOL_VERSION}_linux_amd64.tar.gz  -o otelcol-contrib.tar.gz \
    && tar -xzf otelcol-contrib.tar.gz \
    && mv otelcol-contrib /usr/local/bin/ \
    && chmod +x /usr/local/bin/otelcol-contrib \
    && rm otelcol-contrib.tar.gz \
    # install tflint
    && curl -LO https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip tflint_linux_amd64.zip \
    && mv tflint /usr/local/bin/ \
    # clean up build directory
    && rm -rf /tmp/build
