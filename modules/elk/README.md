create coreos machine with elk stack running on it!

one machine with all three tools installed


backup

    - name: logstash.service
      command: start
      content: |
        [Unit]
        Description=logstash
        After=docker.service
        Requires=docker.service
        After=elasticsearch.service
        Requires=elasticsearch.service          
        [Service]
        EnvironmentFile=/etc/environment
        TimeoutStartSec=0
        # Change killmode from "control-group" to "none" to let Docker remove
        # work correctly.
        KillMode=none        
        ExecStartPre=/usr/bin/docker pull gocd/gocd-agent:16.1.0
        ExecStartPre=-/usr/bin/docker rm %n
        ExecStart=/usr/bin/sh -c "/usr/bin/docker run --rm --name %n -e AGENT_KEY=123456789abcdef --link gocd-server.service:go-server gocd/gocd-agent:16.1.0"
        ExecStop=-/usr/bin/docker stop %n
        RestartSec=10
        Restart=always
    - name: kibana.service
      command: start
      content: |
        [Unit]
        Description=kibana
        After=docker.service
        Requires=docker.service
        After=elasticsearch.service
        Requires=elasticsearch.service          
        [Service]
        EnvironmentFile=/etc/environment
        TimeoutStartSec=0
        # Change killmode from "control-group" to "none" to let Docker remove
        # work correctly.
        KillMode=none        
        ExecStartPre=/usr/bin/docker pull gocd/gocd-agent:16.1.0
        ExecStartPre=-/usr/bin/docker rm %n
        ExecStart=/usr/bin/sh -c "/usr/bin/docker run --rm --name %n -e AGENT_KEY=123456789abcdef --link gocd-server.service:go-server gocd/gocd-agent:16.1.0"
        ExecStop=-/usr/bin/docker stop %n
        RestartSec=10
        Restart=always        