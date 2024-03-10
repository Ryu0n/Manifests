FROM ubuntu:20.04

ARG RUNNER_VERSION="2.311.0"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip redis-tools

ENV YQ_VERSION=4.13.2
ENV YQ_PATH=/usr/local/bin/yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o ${YQ_PATH} && \
    chmod +x ${YQ_PATH}

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
&& curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
&& tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

RUN curl -fsSL https://get.docker.com | sh

RUN pip3 install awscli

COPY start.sh start.sh
RUN chmod +x start.sh
USER docker
ENTRYPOINT ["./start.sh"]
