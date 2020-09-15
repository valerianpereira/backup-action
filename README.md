# 🗄️ backup-action
[GitHub Action](https://github.com/features/actions) for backing up DB & Directories.

First of all, Thanks 🙏 to @appleboy for [drone-ssh](https://github.com/appleboy/drone-ssh) & [ssh-action](https://github.com/appleboy/ssh-action) to make this happen.

<p align="center">
    <img src="https://raw.githubusercontent.com/valerianpereira/backup-action/master/images/backup.svg" width="200">
</p>

## Heads up !! Notes
This action backups the things and store it to `/github/workspace/backups` folder inside the container. You can attach several actions available at the [Marketplace](https://github.com/marketplace?type=actions) and store this backup to your choice of location.

## Pre Requisites
- SSH Key Access to Remote Server. [How to setup?](#setup-ssh-key)

## Example Usecase
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
        key: ${{ secrets.DEPLOY_KEY }}
        type: db
        db_type: mysql
        db_user: ${{ secrets.MYSQL_USER }}
        db_pass: ${{ secrets.MYSQL_PASS }}
        db_port: 3306
        db_name: world
```

output:

```sh
DB type: mysql
🏃‍♂️ Running commands over ssh...
======CMD======
mysqldump -q -u *** -P 3306 -p'***' world | gzip -9 > mysql-world.1109201613.sql.gz
======END======
err: mysqldump: [Warning] Using a password on the command line interface can be insecure.
==============================================
✅ Successfully executed commands to all host.
==============================================
🔑 Loading the deploy key...
Done!! 🍻
🔄 Sync the mysql backups... 🗄
Warning: Permanently added '***' (ECDSA) to the list of known hosts.
receiving incremental file list
mysql-world.1109201613.sql.gz
              0   0%    0.00kB/s    0:00:00  
        623.78K  18%  605.53kB/s    0:00:04  
          3.45M 100%    2.32MB/s    0:00:01 (xfr#1, to-chk=0/1)
sent 51 bytes  received 3.46M bytes  628.39K bytes/sec
total size is 3.45M  speedup is 1.00
🤔 Whats the location of backups...
/github/workspace/backups
🔍 Show me backups... 😎
total 3M     
-rw-r--r--    1 ***     ***        3.3M Sep 11 16:14 mysql-world.1109201613.sql.gz
```

### More Examples with Additional Attachments:
* [Backup & Push to S3](./examples/backup-postgres-push-to-s3.yml)
* [Backup & Push to Server via Rsync](./examples/backup-mongo-push-to-server-rsync.yml)
* [Backup & Push to Server via SCP](./examples/backup-mongo-push-to-server-scp.yml)
* [Backup & Push to Artifacts](./examples/backup-mysql-push-to-email.yml)
* [Backup & Push to Github](./examples/backup-postgres-push-to-s3.yml)

### TIP: You can refer to [ci.yml](./.github/workflows/ci.yml) for more understanding.

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

Backup Config:
* type: type of backup to be triggered (directory or db) `required`
* db_type: type of database `eg: mongo / postgres / mysql`
* db_user: database username `required`
* db_pass: database password `(optional)`
* db_name: database name `required`
* db_host: database host `default: localhost`
* db_port: database port
* auth_db: authenticationDatabase Required for Mongo DB v4.4.0 `default: admin`
* args: additional arguments with backup command if you want to pass `optional`
* dirpath: directory path to be backuped `required when type is set to directory`

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

<div id="setup-ssh-key"/>

## Setting up SSH Key

Login to Remote Server

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

## Disclaimer
- Check your keys.
- Check your custom scripts properly.
- Pass all credentials from Github Secrets.
- Pass DB Credentials with Read-only access to database.
- Use it at your own risk! 🙏

## Roadmap
- [ ] Add Backup & Restore Commands Explanations to ReadME
- [ ] Features to generate Backup Reports and Store it in txt file.

## Contributions
If you've ever wanted to contribute to open source, and a great cause, now is your chance!

Suggestions, Feedbacks, Improvements & Fixes are most welcome. 🙏

## Follow Us
<a href="https://github.com/dr5hn" target="_blank">
<img style="height:auto;" width="50" class="avatar avatar-user width-full border bg-white" src="https://avatars0.githubusercontent.com/u/6929121?s=460&u=71cfda00052973345244b2831e50aac7c83c0415&v=4">
</a><a href="https://github.com/valerianpereira" target="_blank">
<img style="height:auto;" width="50" class="avatar avatar-user width-full border bg-white" src="https://avatars3.githubusercontent.com/u/5975506?s=460&u=92b98874d3f074114501328d005382c81422f226&v=4">
</a>

####  That's all Folks. Enjoy.
