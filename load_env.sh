#!/bin/sh
set -e
[ "$RPI_ENV_PATH" ] && ENV_PATH="$RPI_ENV_PATH" || ENV_PATH='.'
RPI_ENV_FOUND=0
RPI_CFLAGS_FOUND=0
while [ $RPI_ENV_FOUND -ne 1 ] && [ -d "$ENV_PATH" ] &&\
      { [ ! -d '.git' ] || [ ! -d '.hg' ] || [ ! -d '.svn' ]; }
do
    cd "$ENV_PATH" || exit 0
    # local configs take precedence
    [ -f .cflags ] && [ $RPI_CFLAGS_FOUND -eq 0 ] &&\
      eval "$(cat .cflags)" && RPI_CFLAGS_FOUND=1
    [ -f .env ] &&\
      eval "$(cat .env)" && RPI_ENV_FOUND=1
    ENV_PATH="$ENV_PATH/.."
done
