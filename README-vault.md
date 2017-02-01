
This repo contains a vault cluster runs with etcd backend. By default, the vault and etcd are running
on the same instance. 3 instances are created. 

With this setup, you can afford to lose one machine and still keep etcd healthy, so if needed, only reboot machines one at a time and
check etcd health before reboot another.

## Get ips of the vault servers

You can get ips of the vault servers by:

```
$ make get_vault_ips
```

The ssh access is open to your own machine's IP from where you built the vault.

## Initialize and unseal the vault

You need to run Vault initialization on one of the vault servers. The master key and 5 unsealing keys will be stored in etcd K/V store.
You need to run unseal process on all vault servers after its reboot.

* Copy scripts/setup_vault.sh to all vault servers:

```
$ scp scripts/setup_vault.sh core@<vault-server-ips>:/tmp
```

* Initialize and unseal the vault servers

Run this on all vault servers - note it is okay to run setup_vault.multiple times. It will skip initialization if the vault is already
initialized.
```
$ ssh core@<vault-server-ips>
$ cd /tmp
$ ./setup_vault.sh
```

## Validate vault setup

This doesn't need vault authentication

```
$ vault status
core@ip-10-10-6-72-vault /tmp $vault status
Sealed: false
Key Shares: 5
Key Threshold: 3
Unseal Progress: 0
Version: 0.6.4
Cluster Name: vault-cluster-4932646e
Cluster ID: b47b8de3-b609-e730-d2f2-c894d1c77ec8
```
Authenticate to vault and check mounts:

```
$ vault auth $(etcdctl get /service/vault/root-token)
Successfully authenticated! You are now logged in.
token: xxxxxx-ea73-1063-02bf-070f2ab60123
token_duration: 0
token_policies: [root]

$ core@ip-10-10-6-72-vault /etc/profile.d $vault mounts
Path        Type       Default TTL  Max TTL  Description
cubbyhole/  cubbyhole  n/a          n/a      per-token private secret storage
secret/     generic    system       system   generic secret storage
sys/        system     n/a          n/a      system endpoints used for control, policy and debugging
```
