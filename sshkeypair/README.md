# Create a SSH Key Pair

The default key pair is created in the _.ssh_ folder of user home as _.ssh/id_rsa_ and _.ssh/id_rsa.pub_. 
The _id_rsa.pub_ file contains the public key and the _id_rsa_ file contains the private key. 
 
It is also possible to create a _key pair_ to another folder. 

In the following example a key pair ist created in the _./key_ folder with the name _hetzner_.

```shell
ssh-keygen

Generating public/private rsa key pair.
Enter file in which to save the key (~/.ssh/id_rsa): ~/.key/hetzner        
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in ~/.key/hetzner.
Your public key has been saved in ~/.key/hetzner.pub.
The key fingerprint is:
SHA256:9P2kVb+Ixvbo4bSU467gHdaJ30iF0mWhpEUymGyabTc mba@itbmba
The key's randomart image is:
+---[RSA 3072]----+
|      . oo.+ .   |
|       =  * . .  |
|      = .. . o  .|
|     o + E..+  ..|
|      . S.oo..o .|
|          = ==. .|
|       . + #.... |
|      . + @ O    |
|       . o+X o   |
+----[SHA256]-----+
```

You can check the created files:

```shell
ls -al ~/.key/h*
-rw-------  1 mbach  staff  2602 11 Apr 17:57 /Users/mbach/.key/hetzner
-rw-r--r--  1 mbach  staff   568 11 Apr 17:57 /Users/mbach/.key/hetzner.pub
```

The public key is in the file hetzner.pub:

```shell
cat ~/.key/hetzner.pub
ssh-rsa AAA ....

```

The privat key ist in the file hetzner:

```sh
cat ~/.key/hetzner
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

### Access a remote vm with the private key

```sh
ssh -i ~/.key/hetzner ubuntu@xxx.xxx.xxx.xxx
```



### Alias for accessing an ssh remote vm

```sh
alias uvm01='ssh -i ~/.key/hetzner ubuntu@xxx.xxx.xxx.xxx'
```

## Use the Key Pair

You can login to the hetzner cloud and use the key pair in your project.

