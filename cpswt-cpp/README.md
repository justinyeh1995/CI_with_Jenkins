## Build Image
```sh
docker build -t cpswt-cpp:lts -f Dockerfile .
```

## Run
```sh
docker run -it --rm -p 8082:8080 -v /var/run/docker.sock:/var/run/docker.sock cpswt-cpp:lts
```