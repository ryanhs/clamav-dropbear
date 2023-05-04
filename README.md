# Clamav inside docker +dropbear

Clamav inside dropbear

included:
- clamav
- dropbear
- scp

## WHY?

After much thought, how to securly separate Clamav from main docker process,
we have some options:

1. use docker.sock inside parent process, not recommended to give that kind of privilege
2. use something like kestra, and make a http trigger, its nice good, but currently free version of kestra doesnt handle authentication, not a choice to left it open
3. use ssh server inside a worker (Clamav)

> ssh server is not really a best practice inside a container. But, its more secure rather than 2 others options.


### SSH_PUB_KEY

SSH_PUB_KEY is special environment variable to set a single public key for authorized_keys.
hint: you can actually put it inside docker-compose `environment`


#### concept, using azure devops server for git clone

1. ssh into this Clamav server
2. run `~/devops-scan.sh "http://visual...com/project/_git/acme" my_pat

> devops-scan will return exit code 16 if there is an ongoing process. only 1 scan at a time (lock file)

#### example run 1:

```sh
  docker run --rm -e SSH_PUB_KEY="`cat ~/.ssh/id_rsa.pub`" -p 22:22 -v $PWD/persist:/var/lib/clamav ryanhs/clamav-dropbear:latest
```

on client side: (clamav docker on port 2201)

```sh
  ssh -p 2201 node@localhost

  # without verification, just because its localhost, or you can map volume host key
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2203 node@localhost
```


## NOTES

run `freshclam -l /dev/null --stdout  -F` before anyscan.

example: `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2203 node@localhost freshclam -l /dev/null --stdout  -F`