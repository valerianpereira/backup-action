# 🗄️ backup-action
[GitHub Action](https://github.com/features/actions) for backing up DB & Directories.
First of all, Thanks to @appleboy for [drone-ssh](https://github.com/appleboy/drone-ssh) to make this happen.

<p align="center">
    <img src="https://raw.githubusercontent.com/valerianpereira/backup-action/master/images/backup.svg" width="200">
</p>

## Pre Requisites
- Configure Deploy Key to Remote Server

## Usage
Backing up the DBs

```yaml
name: backup db
on:
  schedule:
    - cron: "0 10 * * 1" # Every Monday at 10 AM UTC
jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - name: Backup MySQL DB
      uses: valerianpereira/backup-action@master
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        password: ${{ secrets.PASSWORD }}
        port: ${{ secrets.PORT }}
        deploy_key: ${{ secrets.DEPLOY_KEY }}
        type: db
        db_type: mysql
        db_user: ${{ secrets.MYSQL_USER }}
        db_pass: ${{ secrets.MYSQL_PASS }}
        db_port: 3306
        db_name: world
```

output:

```sh
🗃️Backup type: db
DB type: mysql
🏃‍♂️Running commands over ssh...
======CMD======
mysqldump -q -u *** -P 3306 -p'***' world | gzip -9 > mysql-world.1109201541.sql.gz
======END======
err: mysqldump: [Warning] Using a password on the command line interface can be insecure.
==============================================
✅ Successfully executed commands to all host.
==============================================
🔑Loading the deploy key...
Done!! 🍻
🔄Sync the mysql backups... 🗄
Warning: Permanently added '***' (ECDSA) to the list of known hosts.
receiving incremental file list
mysql-world.1109201541.sql.gz

              0   0%    0.00kB/s    0:00:00  
        788.02K  ***%  763.44kB/s    0:00:03  
          3.45M 100%    2.32MB/s    0:00:01 (xfr#1, to-chk=0/1)

sent 51 bytes  received 3.46M bytes  628.39K bytes/sec
total size is 3.45M  speedup is 1.00
🔍Show me backups...
total 3376
-rw-r--r--    1 ***     ***       3454028 Sep 11 15:41 mysql-world.1109201541.sql.gz
```

## Input variables

See [action.yml](./action.yml) for more detailed information.

* host - ssh host
* port - ssh port, default is `22`
* username - ssh username
* password - ssh password
* passphrase - the passphrase is usually to encrypt the private key
* sync - synchronous execution if multiple hosts, default is false
* timeout - timeout for ssh to remote host, default is `30s`
* command_timeout - timeout for ssh command, default is `10m`
* key - content of ssh private key. ex raw content of ~/.ssh/id_rsa
* key_path - path of ssh private key
* fingerprint - fingerprint SHA256 of the host public key, default is to skip verification
* script - execute commands
* script_stop - stop script after first failure
* envs - pass environment variable to shell script
* debug - enable debug mode
* use_insecure_cipher - include more ciphers with use_insecure_cipher (see [#56](https://github.com/appleboy/ssh-action/issues/56))
* cipher - the allowed cipher algorithms. If unspecified then a sensible

SSH Proxy Setting:

* proxy_host - proxy host
* proxy_port - proxy port, default is `22`
* proxy_username - proxy username
* proxy_password - proxy password
* proxy_passphrase - the passphrase is usually to encrypt the private key
* proxy_timeout - timeout for ssh to proxy host, default is `30s`
* proxy_key - content of ssh proxy private key.
* proxy_key_path - path of ssh proxy private key
* proxy_fingerprint - fingerprint SHA256 of the proxy host public key, default is to skip verification
* proxy_use_insecure_cipher - include more ciphers with use_insecure_cipher (see [#56](https://github.com/appleboy/ssh-action/issues/56))
* proxy_cipher - the allowed cipher algorithms. If unspecified then a sensible

### Setting up SSH Key

Make sure to follow the below steps while creating SSH Keys and using them.
Login with username specified in Github Secrets. Generate a RSA Key-Pair:

 ```bash
 ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
 ```

Add newly generated key into Authorized keys. Read more about authorized keys [here](https://www.ssh.com/ssh/authorized_keys/).

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

Copy Private Key content and paste in Github Secrets.

```bash
clip < ~/.ssh/id_rsa
```

See the detail information about [SSH login without password](http://www.linuxproblem.org/art_9.html)
