# Setup for Simple Container Infrastructure

[https://github.com/mbachmann/traefik-v2-dev-ci-pipeline](https://github.com/mbachmann/traefik-v2-dev-ci-pipeline)

This repository contains a setup for a virtual machine at the hetzner cloud infrastucture 
including a docker based container infrastucture with a traefik v2 remote proxy. 

The setup of the server is done by using the hetzner hcloud-cli and cloud-init.

## Prerequisite

- bash console (windows cmd-line or PowerShell is not working). On Windows install [git bash](https://git-scm.com/downloads).
- hcloud-cli from Hetzner [hcloud](hcloud/README.md).
- _HCloud token_ from the Hetzner Cloud [hcloud](hcloud/README.md).
- With the _DNS token_ records can be automatically synchronized with the [Hetzner DNS Api](https://dns.hetzner.com/).
- You need to update your own project repository before creating a server. Therefore, you need a **fork** of this repository.
**Go to GitHub and create a fork**. Any change of this repository requires a _commit and push_ before creating a server. This
repository is cloned in the new created server and will be used to boot the container infrastructure.


### Create a hcloud-token.local file

In order to access the Hetzner cloud API you need an api token. The api-token is safed in the _hcloud-token.local_ file.

- Create a file in the folder **_local_** with name _hcloud-token.local_.
- Copy the token from your project in  [Hetzner Cloud Console](https://console.hetzner.cloud/projects) to the file  _hcloud-token.local_.

![](readme/hcloud-token.png)

### Create a dns-token.local file

If you want automatically update the DNS records, you can use the Hetzner DNS Api.

- Create a file in the folder **_local_** with name _dns-token.local_
- Copy the token from your project in  [Hetzner DNS Console](https://dns.hetzner.com/settings/api-token) to the file  _dns-token.local_.
You can create a new access token and copy it to the file. The Hetzner CNS Console allows you to [add a new zone](https://dns.hetzner.com/add-zone) which has been 
registered at another registrar **without** transfering the dns-registration to Hetzner.

![](readme/dns-token.png)

### Get the DNS ZoneID and adjust 

In order to access the dns api for the desired zone we need the ZoneID. 

- Go to the [Hetzner DNS Console](https://dns.hetzner.com/settings/api-token) and click on the desired zone.
- The ZoneId is visible the browser url. Copy the ZoneID to the file _scripts/environment.sh_.

![](readme/dns-zone-id.png)

Adjust the environment variables in the file _scripts/environment.sh_.

```shell
export USE_HETZNER_DNS_API="true"
export DOMAIN_URL="sintares.com"
# recover zone id with getzones, defined in dns.sh
export ZONE_ID="aUypFiQLNDVPCUA3GJ8MLJ"
```

### Adjust the hcloud/cloud-init.yml file

The file _hcloud/cloud-init.yml_ is used to set up _Ubuntu_. 

1. Delete the entries in ```ssh_authorized_keys:```.

```yaml
  ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3qXq80S4wl5dpFtHoGpEe0LERxaVgZimejhdbatE3FFodG33V2UgErkhdKogdqa5SwzKITOgUYVVingOUkocqn4U9kGN2HvtaWf6iyROi4bC+NiqYfYkHRt1ETQtWxDWtH5Bp4UlvdB6TNJuZAFNGRaeOiv79UNK7P7SClXFZ/w0lKGxwt30hZDT73rKjUnm/f09KcAmurM4YHPDqV70dKcGdR5pAoCxSvWvYjf9cc1Jy8jZAR4wt/kFBuu2F6YFpTn0ygY6Kg/1DufD7ggERqNGzKvbKvxNBmck7qxxTBGxZ7baqkrLBMkmZ2RvTjlnyE9jw9WrzebfHEFirwqJMtX8gPl7lpvkKvtykPQq/tXk2LZi+ycHRDeohLWrz5TIZ8Xjc8fnxuxiWuyvmHJrVjW5LkU6SjPoakzXNXTDlgN7Fde/N4A8uX6k7JUB9dA2jGJ/WyilDU6NeniDFDLqI2rX75UB2cb4KIPkEIGzIpK6AE6opwIlkAlNqGRByyMs= mbach@s001
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrscyixoq3xozuTYn0G3GNADNLnSaOAmkzC2ltiEvB6SNDGpTrYi/BstnexmfIqYwwaOMIgivhebYGgHlyTxn9WFS2060om7jsz8DnZKMpWLTLHQ4gC0IjnUJCb53NUCmo5/2KupM8bSWrZgupN65nvjr8LkYC5tZBqWKDuNo4YcSpfQwK0GGpVIW7rRV6zbl6EDIxGJbaWpDlY9Zy8hgVoBlfROJfHNCP7DMEosVsWC5RTLV+GfeboDS++JLjP6BEeDmk1FCLcZzybjQ4On80fzy2Vn1DQPpWIde5c1tgzGzDOD2NoluTmexkqBt24QmXL2W9406+QaNHcT0+Yb2Kleu2MSpp+NfIN0DPwbItNg9uk0p1TzWRDV2QTyxV4lMN9VeNOjN48YOi1K4/wX8u/0IikolqdMhmYC7JLst+Bxrp2VriZY2v5TV/3iEdtpn1DKWdvwHzfwpPEmzv0OWLSNBURa7EZtU3Hzu5u/veR0MTJzfGR3wOqEhvxcJlAb8= mbach@s001
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBv0l4kD0nT1At+90mbv7Q8v/Z73swmHCyuKoafBJ/BNNoWXxPcQpI5C7/YPFDvIoXEUJQFRnvFSXiLKwjiAeWzlddWIprWq77PmybqmWC99uIToXrJ+5o4fteWi7cy6rhN1gfROgP6hSX3pwj59sF1LzomHHIQd1+vU3+xEwNVstGZnOOSr5sKUCvGhvHbyPMgpOaUOqjTaDoJz29wXI62NKgz0D2f2uMSsIwU6npXxQMSZMohGOjvFmaTNQx0b+NVzNxnB3DvIH1Rb/+0W1OxcWq0OkBU8mq4TslMPmaF0Y3AcSlhVm4zU6T/UdzSVfOsN4yEu+i+D02AuBhs4Ks8aOPlut7WTn5kCF82JOsJe6jsuZP7iaGagRhaar3+KilTkVfr1GgaMpnEXAX+kXiOUsTRqaiDRausUjq4sQPd7lvr0WtjcYxZF1yV0sohCTt9crL2lTmmF9Q3yEw6mT9ok7EJn3wRaSpnE904NwIbR1ffrRWIojVm6blSBoEfEM= mbach@itbmba14

```

Each entry represents a public key which can be used to login with ssh to the server. The _createServer script_ will automatically add the
public key from the file _local/id_rsa.pub_ to cloud-init.yml. If the key does not exist, it will be created automatically and registered through the api at Hetzner.

2. Add your **forked repository url** to the file _hcloud/cloud-init.yml_.

```yaml
  - git clone https://github.com/mbachmann/traefik-v2-dev-ci-pipeline /home/ubuntu/traefik-v2-dev-ci-pipeline
```

Replace the url _https://github.com/mbachmann/traefik-v2-dev-ci-pipeline_ with your own url.

### Adjust the scripts/environment.sh file for the server parameters

The parameter for the server can be adjusted in the file _scripts/environment.sh_.

1. Project name as defined in https://console.hetzner.cloud/projects.

```shell
export HCLOUD_PROJECT_NAME="cas-oop"
```

2. Arbitrary user name

```shell
export HCLOUD_USER_NAME="mbach"
```

3. Arbitrary server name

```shell
export SERVER_NAME="s004"
```

4. Server type as in https://www.hetzner.com/cloud

| ID  | NAME | CORES | CPU TYPE  | MEMORY  | DISK   | STORAGE TYPE |
|-----|------|-------|-----------|---------|--------|----------|
| 1   | cx11 | 1     | shared    | 2.0 GB  | 20 GB  | local    |
| 3   | cx21 | 2     | shared    | 4.0 GB  | 40 GB  | local    |
| 5   | cx31 | 2     | shared    | 8.0 GB  | 80 GB  | local    |
| .   | ...  | .     | ..        | ..      | ..     | ..       |
| 11  | ccx11 | 2    | dedicated | 8.0 GB  | 80 GB  | local    |
| 12  | ccx21 | 2    | dedicated | 16.0 GB | 160 GB | local    |
| .   | ...  | .     | ..        | ..      | ..     | ..       |
```shell
export SERVER_TYPE="cx11"
```

5. Server image as in https://console.hetzner.cloud/projects/1414551/servers/create 

Can be one of the image: centos-7, centos-stream-8, centos-stream-9, ubuntu-18.04, ubuntu-20.04, 
ubuntu-22.04, debian-10, debian-11, fedora-35, fedora-36. There are also predefined app images 
available like ruby, go, gitlab, docker-ce, lamp, nextcloud

```shell
export SERVER_IMAGE="ubuntu-20.04"
```

6. Server Location 

The current list of server locations can be listed with _hcloud location list_

| ID  | NAME | DESCRIPTION           | NETWORK ZONE | COUNTRY | CITY        |
|-----|------|-----------------------|--------------|---------|-------------|
| 1   | fsn1 | Falkenstein DC Park 1 | eu-central   | DE      | Falkenstein |
| 2   | nbg1 | Nuremberg DC Park 1   | eu-central   | DE      | Nuremberg   |
| 3   | hel1 | Helsinki DC Park 1    | eu-central   | FI      | Helsinki    |
| 4   | ash  | Ashburn, VA           | us-east      | US      | Ashburn, VA |

```shell
export SERVER_LOCATION="hel1"
```
7. During server setup, this repo is cloned -> change it to your forked repository.

```shell
export GIT_REPO=https://github.com/mbachmann/traefik-v2-dev-ci-pipeline
```

8. Create and attach an external volume

The server can be created with an external volume attached. In this case the container
persited volume is on this external volume. in case of server delete and recreate, the
data is saved on the external volume and gets not destroyed.

```shell
export USE_VOLUME="true"
```

- If USE_VOLUME is false then the persitent volume is in **/home/ubuntu/data**.
- If USE_VOLUME is true then the persitent volume is in **/mnt/storage1**.

### Adjust the scripts/environment.sh file for the containers

