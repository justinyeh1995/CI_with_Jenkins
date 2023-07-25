Documentation for works at 2023 ISIS internship

## Environment Description

The host machine is expected to be a Linux machine with a x86 architecture.  
The host machine is expected to have the following software installed:

- Docker
- [Nginx](https://www.nginx.com/resources/wiki/start/topics/tutorials/install/)
- [Jenkins](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu)

## Configuration 
Jenkins & Docker

Jenkins new Job

add ssh key

when jenkins runs, the user became `jenkins`, and thus, there should be a pair of ssh keys under `JENKINS_HOME`, in ubuntu it's `/var/lib/jenkins`. 
```
sudo su - jenkins -s /bin/bash
ssh-keygen
exit
```
