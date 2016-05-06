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

