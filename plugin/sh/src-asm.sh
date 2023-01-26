#!/bin/sh
# shellcheck source=plugin/sh/src-cp.sh
. "$(dirname "$0")/src-cp.sh"

[ -f .cflags ] && eval "$(cat .cflags)"
[ "$CFLAGS" ] && CFLAGS="$CFLAGS"
[ "$CXXFLAGS" ] && CXXFLAGS="$CXXFLAGS"
[ "$LDFLAGS" ] && LDFLAGS="$LDFLAGS"

if [ "$2" = 'all' ]; then
  BIN=asm-make
else
  (echo "${1##*.}" | grep -Eq '^c[px]{,2}$') && BIN=asm-cc || BIN=asm
fi

ssh $SSH_PARAMS -Tq -p "$PORT" "$SRV" \
<<CMD
  cd $WORK_DIR/$(basename "$(dirname "$1")")
  CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
    /home/${SRV%@*}/bin/$BIN $(basename "$1")
  ls -lhAG .
CMD
