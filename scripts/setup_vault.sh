#!/bin/bash
set -e

# pass -i for interactive run. Otherwise, automatically init and unseal.
interactive=${1:-'false'}

if [ "X$interactive" = 'X-i' ]; then
    read -p $'Running this script will initialize & unseal Vault, \nthen put your unseal keys and root token into Consul KV. \n\nIf you are sure you want to continue, type \'yes\': \n' ANSWER
  if [ "$ANSWER" != "yes" ]; then
     echo
     echo "Exiting without intializing & unsealing Vault, no keys or tokens were stored."
     echo
     exit 1
   fi
fi

els() { etcdctl ls /service/vault/$1; }
eset() { etcdctl set /service/vault/$1  $2; }
eget() { etcdctl get /service/vault/$1; }

if  ! etcdctl ls /service/vault ; then
    etcdctl mkdir /service/vault
fi
if [ ! $(els root-token 2> /dev/null ) ]; then
  echo "Initialize Vault"
  vault init | tee /tmp/vault.init > /dev/null

  # Store master keys and unseal keys in etcd for operator to retrieve and remove
  COUNTER=1
  cat /tmp/vault.init | grep '\(Unseal Key\)' | awk '{print $4}' | for key in $(cat -); do
    eset unseal-key-$COUNTER $key
    COUNTER=$((COUNTER + 1))
  done
  export ROOT_TOKEN=$(cat /tmp/vault.init | grep '^Initial' | awk '{print $4}')
  eset root-token $ROOT_TOKEN

  echo "Tempoary key files are in /tmp/vault.init. You can remove keys from disk: shred /tmp/vault.init"
  #shred /tmp/vault.init
else
  echo "Vault has already been initialized, skipping."
fi

echo "Unsealing Vault"
vault unseal $(eget unseal-key-1)
vault unseal $(eget unseal-key-2)
vault unseal $(eget unseal-key-3)

echo "Vault setup complete."

instructions() {
  cat <<EOF
We use an instance of HashiCorp Vault for secrets management.
It has been automatically initialized and unsealed once. Future unsealing must
be done manually.
The unseal keys and root token have been temporarily stored in Etcd K/V.
  /service/vault/root-token /service/vault/unseal-key-{1..5}
Please securely distribute and record these secrets and remove them from Consul.
EOF

  exit 1
}

instructions
