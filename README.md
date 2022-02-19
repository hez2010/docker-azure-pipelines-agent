# Azure Pipelines Agent Docker Image for Docker-in-Docker

This repository contains `Dockerfile` definitions for azure-pipelines-agent with docker-in-docker support.

This project allows the Azure Pipelines Agent to run on Docker or Kubernetes (with Helm), and supports running container job.

Use: `docker pull ghcr.io/hez2010/docker-azure-pipelines-agent:main`

## Configuration

For `latest`, you need to set these environment variables:


- `AGENT_PAT`: The personal access token from Azure Pipelines. Required. See
  [Microsoft Docs](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#authenticate-with-a-personal-access-token-pat) for instructions on how to create the PAT.
- `AGENT_POOL`: The agent pool. Optional. Default value: `Default`
- `AGENT_URL`: The URL of tenant.
- `AGENT_DOCKER_MTU_VALUE`: making sure it is less than the host docker MTU value, or you'll face networking issue


## License

This software is open source, licensed under the Apache License, Version 2.0.
See [LICENSE.txt](https://github.com/lambda3/azure-pipelines-agent/blob/master/LICENSE.txt) for details.
Check out the terms of the license before you contribute, fork, copy or do anything
with the code. If you decide to contribute you agree to grant copyright of all your contribution to this project, and agree to
mention clearly if do not agree to these terms. Your work will be licensed with the project at Apache V2, along the rest of the code.
