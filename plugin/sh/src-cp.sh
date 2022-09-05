#!/bin/sh
[ -f .env ] && eval "$(cat .env)"
[ "$SSH_PORT" ] && PORT="$SSH_PORT" || PORT=5022
[ "$SSH_HOST" ] && SRV="$SSH_HOST" || SRV='pi@localhost'
[ "$WORK_DIR" ] && WORK_DIR="$WORK_DIR" || WORK_DIR='~'

echo "Sending $(basename "$1") to $SRV . . ."
ssh $SSH_PARAMS -Tq -p "$PORT" "$SRV" "mkdir -p $WORK_DIR" 2>/dev/null
set -e
rsync -e="ssh -p$PORT" "$1" "$SRV:$WORK_DIR/$(basename "$(dirname "$1")")/"
echo 'done'
