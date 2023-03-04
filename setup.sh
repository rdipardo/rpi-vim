#!/bin/sh
set -e
[ -f .env ] && eval "$(cat .env)"
[ "$SSH_PORT" ] && PORT="$SSH_PORT" || PORT=5022
[ "$SSH_HOST" ] && SRV="$SSH_HOST" || SRV='pi@localhost'
[ "$WORK_DIR" ] && WORK_DIR="$WORK_DIR" || WORK_DIR='~'
[ "$1" ] && [ -z "$KEY_FILE" ] && KEY_FILE="$1" || KEY_FILE=~/.ssh/rpi_vm
[ "$2" ] && [ -z "$SSH_PASSWORD" ] && SSH_PASSWORD="$2" || SSH_PASSWORD=

if ! [ -f "$KEY_FILE" ];then
  ssh-keygen -t rsa -P "$SSH_PASSWORD" -f "$KEY_FILE"
  (cat<<-EOF

Host ${SRV#*@}
  IdentityFile $KEY_FILE
  Port $PORT
  User ${SRV%@*}
  AddressFamily inet
  Protocol 2
  ControlMaster auto
  ControlPath  /tmp/%r@%h-%p
# PreferredAuthentications publickey
EOF
) >> ~/.ssh/config
fi

ssh-copy-id -i "${KEY_FILE}.pub" -p$PORT $SRV
touch .hushlogin # https://stackoverflow.com/a/3763539
rsync -v -e="ssh -p$PORT" .hushlogin "$SRV:~"
rsync -v -e="ssh -p$PORT" "${RPI_VIM_HOME:-.}/"bin/* "$SRV:~/bin/"
# shellcheck disable=SC2086
ssh $SSH_PARAMS -Tq -p "$PORT" "$SRV" "mkdir -p $WORK_DIR"
rm .hushlogin
