# How to get into the CoreOS machine?

```
ssh -i <key pem file> core@<public-ip>
```

# Check logs of particular container/service or systemd unit status?

e.g.

```
journalctl -exu gocd-agent-1
```

or

```
journalctl -exu gocd-agent-cd-prod.service
```

For each of our essential services, we should check the status and logs. The general way of doing this is:

```
systemctl status -l <service>
```

```
journalctl -b -u <service>
```

# How to check `systemd` unit status?

```
systemctl status gocd-agent-1
```

# How to check full system journal logs?

```
journalctl --since "2015-03-20 08:49"
```

# How to list systemd units?

```
list systemd units
```

list specific units

```
systemctl list-units | grep fleet
```

# How to restart a particular systemd unit?

```
systemctl restart fleet.service
```

# What are unit types?


Two types of units can be run in your cluster — standard and global units. Standard units are long-running processes that are scheduled onto a single machine. If that machine goes offline, the unit will be migrated onto a new machine and started.

Global units will be run on all machines in the cluster.

# What are `fleet` commands?

```
fleetctl submit hello.service
```

```
fleetctl start hello.service
```

```
fleetctl status hello.service
```

To see the output of the service, call:
```
fleetctl journal hello.service
```

```
fleetctl destroy hello.service
```

# How to make a new shell script executable?

```
sudo chmod a+x script-name.sh
```

# How to show all installed unit files?

```
systemctl list-unit-files
```

# How to find the mounted volumes?

you can verify presence of your volume with `lsblk` command

# What are systemd units specifiers %i, %p, %n, etc.?

[Systemd Specifiers](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Specifiers)

# Vagrant window issues?

We have noticed that for some reason make instructions which create directories fail when the host machine OS is windows; the work around is to get into the vagrant machine and then clone the repo

 