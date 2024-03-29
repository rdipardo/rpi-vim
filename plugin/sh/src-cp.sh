#!/bin/sh
# shellcheck source=load_env.sh
RPI_ENV_PATH="$(dirname "$1")" . "$(dirname "$0")/../../load_env.sh"
[ "$SSH_PORT" ] && PORT="$SSH_PORT" || PORT=5022
[ "$SSH_HOST" ] && SRV="$SSH_HOST" || SRV='pi@localhost'
[ "$WORK_DIR" ] && WORK_DIR="$WORK_DIR" || WORK_DIR='~'
[ "$2" = 'all' ] && RECURSIVE='-r --del' && SRC="$(dirname "$1")/" || SRC="$1"
SRC_NAME="$(basename $SRC)" && [ -n "$RECURSIVE" ] && SRC_NAME="$SRC_NAME/*"

echo "Sending $SRC_NAME to $SRV . . ."
set -e
rsync --exclude-from="$(dirname "$0")/.rsyncignore" --exclude="$(basename "${1%%.*}")" \
  -u $RECURSIVE --port $PORT "$SRC" "$SRV:$WORK_DIR/$(basename "$(dirname "$1")")/"
echo 'done'
