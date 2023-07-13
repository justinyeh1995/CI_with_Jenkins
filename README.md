# CI_with_Jenkins
This repository is a test bed for cpswt projects

# Build image
```sh
docker build -t cpswt-meta:latest -f Dockerfile --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" .
```

# Run image
```sh
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -p 8088:8088 cpswt-meta:latest
```
