#!/bin/sh
set -e
[ -f .env ] && eval "$(cat .env)"
[ "$OS_IMAGE_URL" ] && \
  IMG_URL="$OS_IMAGE_URL" || \
  IMG_URL='https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-01-28'

[ "$OS_VERSION" ] && \
  IMG="$OS_VERSION" || \
  IMG='2022-01-28-raspios-bullseye-arm64-lite'

[ "$RPI_BOARD" ] && BOARD="$RPI_BOARD"
[ -z "$BOARD" ] && \
  [ "$(echo "$IMG" | grep -c arm64)" -eq 1 ] && BOARD=pi3

case "$BOARD" in
  '' | 'pi1' | 'pi2' | 'pi3' ) ;;
  *)
    echo "Invalid RPi board type: '$BOARD'"
    exit 1
    ;;
esac

DISTRO=
PKG_CMD='apt install -y'
XZ_INSTALL_CMD="$PKG_CMD xz-utils"
XZ_ARGS='-vT0'

if [ -f '/etc/os-release' ]; then
  DISTRO="$(awk '/^ID=.*$/ { gsub(/"/,"",$0);
                             gsub(/[\x2D ].*$/,"",$0);
                             print(tolower(substr($0,4))) }' /etc/os-release)"
fi

case "$DISTRO" in
  'alpine' )
    PKG_CMD='apk add'
    XZ_INSTALL_CMD="$PKG_CMD xz"
    XZ_ARGS=
    ;;
  'arch' | 'manjaro' )
    PKG_CMD='pacman -Sy'
    XZ_INSTALL_CMD="$PKG_CMD xz"
    ;;
  'almalinux' | 'centos' | 'fedora' | 'rocky' )
    PKG_CMD='dnf install -y'
    XZ_INSTALL_CMD="$PKG_CMD xz"
    ;;
  'opensuse' )
    PKG_CMD='zypper install -y'
    XZ_INSTALL_CMD="$PKG_CMD xz"
    ;;
  *) ;;
esac

no_builtin_user() {
  echo
  echo '=================================================================================='
  printf '%s\n%s\n' \
       "As of the 2022-04-04 Bullseye release, there is NO DEFAULT 'pi' USER ON THE IMAGE!" \
       'You can create one with the RPi Imager: https://github.com/raspberrypi/rpi-imager'
  echo 'See https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022'
  echo '=================================================================================='
  echo
}

if ! [ -f "$IMG.img" ]; then
  HAS_BUILTIN_USER=$(echo "$IMG" \
                    | awk '{ split($0,a,"-");
                             if (a[1] > 2022 || (a[1] == 2022 && a[2] >= 4)) print "false";
                             else print "true"; }')

  echo Fetching "$IMG" . . .
  if [ "$HAS_BUILTIN_USER" = 'false' ]; then
      no_builtin_user
      test -f "$(command -v curl)" || ${PKG_CMD} curl
      test -f "$(command -v unxz)" || ${XZ_INSTALL_CMD}
      test -f "$IMG.img.xz" || curl -JLO "$IMG_URL/$IMG.img.xz"
      # shellcheck disable=SC2086
      unxz ${XZ_ARGS} "$IMG.img.xz"
  else
      test -f "$(command -v unzip)" || ${PKG_CMD} unzip
      test -f "$IMG.zip" || curl -JLO "$IMG_URL/$IMG.zip"
      unzip "$IMG.zip"
  fi
fi

echo Starting the RPi container . . .
docker run \
  --name "$IMG" \
  --rm \
  -it \
  --net=host \
  -v "$(pwd)/$IMG.img":/sdcard/filesystem.img \
  lukechilds/dockerpi:vm "$BOARD"
