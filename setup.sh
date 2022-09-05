#!/bin/sh
set -e
[ -f .env ] && eval "$(cat .env)"
[ "$SSH_PORT" ] && PORT="$SSH_PORT" || PORT=5022
[ "$SSH_HOST" ] && SRV="$SSH_HOST" || SRV='pi@localhost'
KEY_FILE=~/.ssh/rpi_vm

if ! [ -f "$KEY_FILE" ];then
  ssh-keygen -t rsa -P "$SSH_PASSWORD" -f "$KEY_FILE"
  (cat<<-EOF

Host ${SRV#*@}
  IdentityFile $KEY_FILE
  Port $PORT
  User ${SRV%@*}
EOF
) >> ~/.ssh/config
fi

ssh-copy-id -i "${KEY_FILE}.pub" -p$PORT $SRV
touch .hushlogin # https://stackoverflow.com/a/3763539
rsync -v -e="ssh -p$PORT" .hushlogin "$SRV:~"
rsync -v -e="ssh -p$PORT" ./bin/* "$SRV:~/bin/"
rm .hushlogin
