## Troubles I ran into:
- [x] MongoDB env var had a typo, it was written `ADDOM` in the .env file and
    the code expected `ADDON`. I solved this by starting a Node.js console by
    running `node` inside a terminal, loading the `.env` file and checking its contents
    inside the node console.
- [x] MongoDB connection had ssl disabled, I had to enable it in the URL
provided.
- [x] MongoDB password was a base64 one so I had to decrypt it.

## Notes:
- I don't want to deal with things under the hood that can impact the way that
    the node engine works so that's why I chose the node-slim Docker image
    instead of the alpine one, just because I don't want to run into any
    surprises regarding glibc vs musl.
- Tini is just a tool that I'm experimenting. It is a tool designed to run
    processes under a valid init inside containers so it can track down and
    sucessfully kill any other zombie child processes that the main process
    may spawn.
- `infra/base` shouldn't even be in this repo since this is the application repo.
    `infra/app` could also be on another repo that controls the organizations
    infrastructure.
    `infra/global` is just to create the bucket that will have the Terraform
    state files inside.
- I ran into issues with the ecs-agent that I was installing in the EC2 instance
    via the user agent. It was conflicting with the Docker service that
    was already present in the machine.
