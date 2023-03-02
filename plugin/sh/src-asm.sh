#!/bin/sh
# shellcheck source=plugin/sh/src-cp.sh
. "$(dirname "$0")/src-cp.sh"

[ -f .cflags ] && eval "$(cat .cflags)"
[ "$CFLAGS" ] && CFLAGS="$CFLAGS"
[ "$CXXFLAGS" ] && CXXFLAGS="$CXXFLAGS"
[ "$LDFLAGS" ] && LDFLAGS="$LDFLAGS"
BIN="/home/${SRV%@*}/bin"
ARG=$(basename "$1")

if [ "$2" = 'all' ]; then
  if [ -n "$(find "$(dirname "$1")" -maxdepth 1 -iname makefile)" ]; then
    BIN='make'
    ARG="$3"
    CFLAGS=
    CXXFLAGS=
    LDFLAGS=
  else
    BIN="$BIN/asm-make"
  fi
else
  (echo "${1##*.}" | grep -Eq '^c[px]{,2}$') && BIN="$BIN/asm-cc" || BIN="$BIN/asm"
fi

ssh $SSH_PARAMS -Tq -p "$PORT" "$SRV" \
<<CMD
  cd $WORK_DIR/$(basename "$(dirname "$1")")
  CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" $BIN $ARG
  ls -lhAG .
CMD
