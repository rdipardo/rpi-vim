#!/bin/sh
[ -f .env ] && eval "$(cat .env)"
[ "$SSH_PORT" ] && PORT="$SSH_PORT" || PORT=5022
[ "$SSH_HOST" ] && SRV="$SSH_HOST" || SRV='pi@localhost'
[ "$WORK_DIR" ] && WORK_DIR="$WORK_DIR" || WORK_DIR='~'
EXE=$(basename "${1%%.*}")

[ -z "$EXE" ] && echo Missing buffer name! && exit 1
echo "Executing $EXE on $SRV . . ."
ssh $SSH_PARAMS -Tq -p "$PORT" "$SRV" \
<<CMD
  cd $WORK_DIR/$(basename "$(dirname "$1")")
  ./$EXE
CMD
