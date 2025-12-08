## GitHub Actions Self-hosted runnersをDockerで作る

- https://docs.github.com/actions/concepts/runners/self-hosted-runners

いつものことだがディストロごとに依存パッケージの名前が違う。Runner自体はrootで実行してはいけない。

<figure>
<figcaption>Dockerfile</figcaption>

```dockerfile
FROM ubuntu:24.04

# https://github.com/actions/runner
ARG ACTIONS_RUNNER_VERSION=2.329.0

# https://github.com/actions/runner/blob/main/docs/start/envlinux.md
#
# - liblttng-ust1 or liblttng-ust0
#   - Note, selecting 'liblttng-ust1t64' instead of 'liblttng-ust1'
# - libkrb5-3
# - zlib1g
# - libssl1.1, libssl1.0.2 or libssl1.0.0
#   - E: Couldn't find any package by glob 'libssl1.1'
#   - libssl3t64/noble-updates,noble-security,now 3.0.13-0ubuntu3.6 amd64
# - libicu63, libicu60, libicu57 or libicu55
#   - E: Unable to locate package libicu63
#   - libicu74/noble-updates 74.2-1ubuntu3.1 amd64
RUN apt-get update && apt-get install --yes --no-install-recommends \
  ca-certificates \
  curl \
  libicu74 \
  libkrb5-3 \
  liblttng-ust1t64 \
  libssl3t64 \
  zlib1g \
  && rm -rf /var/lib/apt/lists/*

RUN cd /home/ubuntu \
  && mkdir actions-runner && cd actions-runner \
  && curl -o actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz \
  && chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu/actions-runner

# https://github.com/user/repo/settings/actions/runners/new
#
# $ ./config.sh --url https://github.com/user/repo --token TOKEN
# $ ./run.sh
```

</figure>
<figure>
<figcaption>docker-compose.yaml</figcaption>

```yaml
services:
  actions-runner:
    build: .
    user: ubuntu
    tty: true
```

</figure>

```
$ docker compose build
$ docker compose up --detach
$ docker compose exec actions-runner bash

$ docker compose down
```
