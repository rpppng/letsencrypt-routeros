# Let's Encrypt RouterOS / Mikrotik
**Let's Encrypt certificates for RouterOS / Mikrotik**

*UPD 2022-07-11: First Release*

[![Mikrotik](https://i.mt.lv/mtv2/logo.svg)](https://mikrotik.com/)


### How it works:
* Dedicated Linux renew and push certificates to RouterOS / Mikrotik
* After CertBot renew your certificates
* The script connects to RouterOS / Mikrotik using RSA Key (without password or user input)
* Delete previous certificate files
* Delete the previous certificate
* Upload two new files: **Certificate** and **Key**
* Import **Certificate** and **Key**
* Change **SSTP Server Settings** to use new certificate
* Delete certificate and key files form RouterOS / Mikrotik storage

### Installation on Ubuntu 20.04
*Similar way you can use on Debian/CentOS/AMI Linux/Arch/Others*

Download the repo to your system
```sh
sudo -s
cd /opt
git clone https://github.com/rpppng/letsencrypt-routeros
```
Edit the settings file:
```sh
vim /opt/letsencrypt-routeros/letsencrypt-routeros.settings
```
| Variable Name | Value | Description |
| ------ | ------ | ------ |
| ROUTEROS_USER | admin | user with admin rights to connect to RouterOS |
| ROUTEROS_HOST | 10.10.10.1 | RouterOS\Mikrotik IP |
| ROUTEROS_SSH_PORT | 22 | RouterOS\Mikrotik PORT |
| ROUTEROS_PRIVATE_KEY | /opt/letsencrypt-routeros/id_rsa | Private Key to connecto to RouterOS |
| DOMAIN | mydomain.com | Use main domain for wildcard certificate or subdomain for subdomain certificate |


Change permissions:
```sh
chmod +x /opt/letsencrypt-routeros/letsencrypt-routeros.sh
chmod +x /opt/letsencrypt-routeros/letsencrypt-routeros-prehook.sh
```
Generate RSA Key for RouterOS

*Make sure to leave the passphrase blank (-N "")*

```sh
ssh-keygen -t rsa -f /opt/letsencrypt-routeros/id_rsa -N ""
```

Send Generated RSA Key to RouterOS / Mikrotik
```sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
scp -P $ROUTEROS_SSH_PORT /opt/letsencrypt-routeros/id_rsa.pub "$ROUTEROS_USER"@"$ROUTEROS_HOST":"id_rsa.pub" 
```

### Setup RouterOS / Mikrotik side
*Check that user is the same as in the settings file letsencrypt-routeros.settings*

*Check Mikrotik ssh port in /ip services ssh*

*Check Mikrotik firewall to accept on SSH port*
```sh
:put "Enable SSH"
/ip service enable ssh

:put "Add to the user RSA Public Key"
/user ssh-keys import user=admin public-key-file=id_rsa.pub
```

### CertBot Let's Encrypt
Install CertBot using official manuals https://certbot.eff.org/instructions

*for Ubuntu 20.04*
```sh
install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

***To use script with CertBot hooks:***

*follow CertBot instructions*
```sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
certbot certonly --standalone -d $DOMAIN --pre-hook /opt/letsencrypt-routeros/letsencrypt-routeros-prehook.sh --post-hook /opt/letsencrypt-routeros/letsencrypt-routeros.sh
```

### Usage of the script
*To use settings form the settings file:*
```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh
```
*To use script without settings file:*

```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]
```
*To use script with CertBot hooks for wildcard domain:*
```sh
certbot certonly --preferred-challenges=dns --manual -d *.$DOMAIN --manual-public-ip-logging-ok --post-hook /opt/letsencrypt-routeros/letsencrypt-routeros.sh --server https://acme-v02.api.letsencrypt.org/directory
```
---
### Licence MIT
Copyright 2018 Konstantin Gimpel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
