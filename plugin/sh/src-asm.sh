#!/bin/sh
# shellcheck source=plugin/sh/src-cp.sh
. "$(dirname "$0")/src-cp.sh"

if [ "$2" = 'all' ]; then
  BIN=asm-make
else
  (echo "${1##*.}" | grep -Eq '^c[px]{,2}$') && BIN=asm-cc || BIN=asm
fi

ssh $SSH_PARAMS -Tq -p "$PORT" "$SRV" \
<<CMD
  cd $WORK_DIR/$(basename "$(dirname "$1")")
  /home/${SRV%@*}/bin/$BIN $(basename "$1")
  ls -lhAG .
CMD
