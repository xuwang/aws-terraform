1. Termiate AWS EC2  when no spare - expect fleet service to re-launch containers running on the EC2 and web applications automatically register with ELB. 
2. Kill container - expect systemd restart them
3. Termiates AWS EC2 when there is a standby - expect fleet service relocate container to standby
