# Check logs of particular container/service or systemd unit status?

e.g.

```
journalctl -exu gocd-agent-1
```

or

```
journalctl -exu gocd-agent-cd-prod.service
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

