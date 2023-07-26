Documentation for works at 2023 ISIS internship

## Environment Description

The host machine is expected to be a Linux machine with a x86 architecture.  
The host machine is expected to have the following software installed:

- Docker
- [Nginx](https://www.nginx.com/resources/wiki/start/topics/tutorials/install/)
- [Jenkins](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu)

## Configuration 
Jenkins & Docker

Jenkins & Nginx
- [Configure Nginx as a reverse proxy for Jenkins](https://www.jenkins.io/doc/book/system-administration/reverse-proxy-configuration-with-jenkins/reverse-proxy-configuration-nginx/)


## Configure Jenkins Plugins

## Configure Jenkins Global Tool Configuration

## Configure Jenkins Job 
Jenkins new Job

add ssh key

when jenkins runs, the user became `jenkins`, and thus, there should be a pair of ssh keys under `JENKINS_HOME`, in ubuntu it's `/var/lib/jenkins`. Also, add the public key to the github account. Add github.com to the `known_hosts` file.
Besides, the `jenkins` user should be added to the `docker` group, so that it can run docker commands without `sudo`. Remember to restart jenkins after adding the user to the `docker` group.
```sh
```shell
sudo su - jenkins -s /bin/bash
ssh-keygen # generate ssh key
ssh -T git@github.com # add github.com to known_hosts
exit
```
