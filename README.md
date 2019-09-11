# Evaluation points
* Correctness of implementation in scripts.
* Bash scripts best practices.
* Python code best practices.
* Use of git, appropriate commit messages.
* Documentation: README and inline code comments.
# Technical test:
Implement deployment of 3 tier application, which would run on Ubuntu server 18.04 LTS, would use Nginx, Postgres and Python code in consitent and repeatable way. You would need to automate deployment of:
1. Setup use of 10.0.0.2/18 static IP address, Netmask 255.255.192.0, gateway 10.0.0.1/18.
2. Install Nginx, configure it to serve static pages and dynamic pages via FCGI (python application).
3. Install PostgreSQL DBMS and create DB, user for DB, set users password.
4. Install simple Python application which would serve "Hello World!" via FCGI.
5. Make sure all your changes are persistent after reboot.
# Bonus points
* Use Ansible for server setup.

## Network configuration on the target machine:
```
rry@test:~$ cat /etc/netplan/50-cloud-init.yaml 
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens160:
            addresses:
            - 10.0.0.2/18
            gateway4: 10.0.0.1
            nameservers:
                addresses:
                - 10.0.0.1
    version: 2
rry@test:~$ sudo netplan apply
```

## Configuration of the target machine using Ansible playbook:
```
$ ansible --version
ansible 2.0.0.2
```

#### 1. Clone git repository:
```
git clone https://github.com/romryzh/90poe_test.git
```
#### 2. Generate SSH key-pair and copy public key to the target machine:
```
ssh-keygen -f ~/.ssh/ansible
ssh-copy-id -i ~/.ssh/ansible.pub <username>@10.0.0.2
```

#### 3. Replace `ansible_user` parameter in `hosts` inventory file with name of the user on the target machine.
#### 4. Run playbook (For Ansible versions above 2.6 use next command to run playbook: `ansible-playbook test_deploy.yml -K -i hosts`) :
```
rry@ansible:~/90poe_test/ansible$ ansible-playbook test_deploy.yml --ask-sudo-pass -i hosts
SUDO password:

PLAY ***************************************************************************

TASK [Check for Python] ********************************************************
ok: [host1]

TASK [Install Python] **********************************************************
skipping: [host1]

TASK [Ensure apt cache is up to date] ******************************************
ok: [host1]

TASK [Ensure packages are installed] *******************************************
ok: [host1] => (item=[u'postgresql', u'nginx', u'spawn-fcgi', u'python-flup', u'python-pip', u'python-psycopg2'])

TASK [Install web.py] **********************************************************
ok: [host1]

PLAY ***************************************************************************

TASK [Ensure database is created] **********************************************
ok: [host1]

TASK [Ensure user has access to database] **************************************
ok: [host1]

PLAY ***************************************************************************

TASK [Copy the nginx config file] **********************************************
changed: [host1]

TASK [Create symlink] **********************************************************
ok: [host1]

TASK [Copy default html page] **************************************************
ok: [host1]

TASK [Clone git repo] **********************************************************
changed: [host1]

TASK [Add exec permmisions to index.py] ****************************************
changed: [host1]

TASK [Copy and add exec permissions to fcgi init-script] ***********************
ok: [host1]

TASK [Add fcgi to autoboot] ****************************************************
ok: [host1]

TASK [Restart fcgi] ************************************************************
changed: [host1]

TASK [Restart nginx] ***********************************************************
changed: [host1]

PLAY RECAP *********************************************************************
host1                      : ok=15   changed=5    unreachable=0    failed=0

```
#### 5. Check PostgreSQL:
```
rry@test:~$ psql -h 127.0.0.1 -p 5432 -U testuser -W testdb
Password for user testuser:
psql (10.10 (Ubuntu 10.10-0ubuntu0.18.04.1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

testdb=>
testdb=> \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 testdb    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | postgres=CTc/postgres+
           |          |          |             |             | testuser=CTc/postgres
(4 rows)
testdb=> \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 testuser  |                                                            | {}

```
#### 7. Check hello-app:

```
rry@ansible:~/test/ansible$ curl http://10.0.0.2
<!DOCTYPE html>
<html>
<head>
<title>Welcome!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome!</h1>
<p>Path to dynamic page: <a href="dynamic">/dynamic</a></p>
<p>Path to static page: <a href="static">/static</a> </p>

<p><em>Have a good day!</em></p>
</body>
</html>

rry@ansible:~/test/ansible$ curl http://10.0.0.2/static/
<html>
<header><title>This is title</title></header>
<body>
Hello World from static page!
</body>
</html>
rry@ansible:~/test/ansible$ curl http://10.0.0.2/dynamic
<html>
<header><title>Dynamic page</title></header>
<body>
Hello World from dynamic page!
</body>
</html>
```
![1](https://raw.githubusercontent.com/romryzh/test/pictures/pictures/img1.png)
![2](https://raw.githubusercontent.com/romryzh/test/pictures/pictures/img2.png)
![3](https://raw.githubusercontent.com/romryzh/test/pictures/pictures/img3.png)
