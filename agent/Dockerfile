FROM ubuntu:20.04
RUN apt update \
    && apt install -y ca-certificates openssh-client \
    wget curl iptables supervisor \
    && rm -rf /var/lib/apt/list/*

ENV DOCKER_CHANNEL=stable \
	DOCKER_VERSION=20.10.9 \
	DOCKER_COMPOSE_VERSION=1.29.2 \
	DEBUG=false
# Docker installation
RUN set -eux; \
	\
	arch="$(uname --m)"; \
	case "$arch" in \
        # amd64
		x86_64) dockerArch='x86_64' ;; \
        # arm32v6
		armhf) dockerArch='armel' ;; \
        # arm32v7
		armv7) dockerArch='armhf' ;; \
        # arm64v8
		aarch64) dockerArch='aarch64' ;; \
		*) echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
	esac; \
	\
	if ! wget -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	docker --version

COPY modprobe /usr/local/bin/
COPY supervisor/ /etc/supervisor/conf.d/
COPY logger.sh /opt/bash-utils/logger.sh

RUN chmod +x /usr/local/bin/modprobe
VOLUME /var/lib/docker

# Docker compose installation
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
	&& chmod +x /usr/local/bin/docker-compose && docker-compose version

HEALTHCHECK --interval=1m --timeout=2s CMD ps aux | grep --color=never [A]gent.Listener
RUN mkdir /agent
WORKDIR /agent
# basics:
RUN apt-get update && \
    apt-get install -y software-properties-common apt-transport-https && \
    apt-get upgrade -y && \
    apt-add-repository ppa:git-core/ppa && \
    apt-get update
# azure pipelines dependencies
# from: https://github.com/microsoft/azure-pipelines-agent/blob/25aa1872da9199dd3c7dc1721864887718ab27b4/src/Misc/layoutbin/installdependencies.sh#L107
RUN apt-get install -y libssl1.1 || apt-get install -y libssl1.0.2 || apt-get install -y libssl1.0.0 && \
    apt-get install -y libicu67 || apt-get install -y libicu66 || apt-get install -y libicu63 || apt-get install -y libicu60 || apt-get install -y libicu57 || apt-get install -y libicu55 || apt-get install -y libicu52
# other dependencies:
RUN apt-get install -y iproute2 libuuid1 libunwind8 gdebi-core build-essential libssl-dev
# tools
RUN apt-get install -y git wget curl zip unzip vim sudo iputils-ping python3 python3-pip jq
#users
RUN adduser --disabled-password --gecos '' agentuser && \
    adduser agentuser sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Microsoft keys:
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb
# dotnet
RUN apt-get update && apt-get install -y dotnet-sdk-6.0
ENV PATH="${PATH}:/home/agentuser/.dotnet/tools"
# az cli:
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y azure-cli
# pwsh:
RUN apt-get install -y powershell
# nvm/node/yarn:
RUN curl -fSsL https://deb.nodesource.com/setup_16.x | bash
RUN apt-get install -y nodejs
USER agentuser
RUN curl -fSso- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN [ "/bin/bash", "-c", "source $HOME/.nvm/nvm.sh && nvm i 12 && nvm i 14 && nvm i 16" ]
RUN [ "/bin/bash", "-c", "source $HOME/.nvm/nvm.sh && nvm alias default 16" ]
USER root
RUN curl -fsS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get -y --no-install-recommends install yarn
# kubectl:
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl
# helm 2:
RUN curl -fSsL https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash && \
    mv /usr/local/bin/helm /usr/local/bin/helm2
# helm 3:
RUN curl -fSsL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
# terraform:
RUN wget -q https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip -O terraform.zip && \
    unzip -d /usr/local/bin/ terraform.zip && \
    rm terraform.zip
# cleanup
RUN apt-get autoremove -y
# agent:
RUN curl -fSsL https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-linux-x64-2.198.3.tar.gz -o /agent/vsts-agent.tar.gz && \
    tar xzf /agent/vsts-agent.tar.gz && \
    rm /agent/vsts-agent.tar.gz
COPY configureAgent.sh runAgent.sh configureAndRun.sh /agent/
RUN chmod +x configureAndRun.sh configureAgent.sh runAgent.sh && \
    chown agentuser:agentuser configureAgent.sh runAgent.sh configureAndRun.sh
RUN chown -R agentuser:agentuser /agent
USER agentuser
STOPSIGNAL SIGINT
CMD [ "/agent/configureAndRun.sh" ]
