# C2-Pixler

```bash
# format code
nix fmt

# run the server
nix run

# server will be available on http://localhost:5000
```

### Building and running the docker image

```bash
# build the container image
nix build .#containerImage

# load the container image into docker
docker load < result

# start the c2-pixler container
docker compose up
```
