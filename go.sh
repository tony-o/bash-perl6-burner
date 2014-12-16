#!/bin/bash

PKGS=""
if [[ "`which aptitude`" != "" ]]; then
  if [[ "`which git`" == "" ]]; then
    PKGS="$PKGS git"
  fi
  if [[ "`which cc`" == "" ]]; then
    PKGS="$PKGS build-essential"
  fi
  if [[ "$PKGS" != "" ]]; then
    echo "==> Using aptitude"
    sudo aptitude install git build-essential
  fi
fi

if [ ! -d "wa" ]; then
  echo "==> Creating work area and directories"
  mkdir -p "wa/sixes"
  mkdir -p "wa/logs"
fi

cd "wa"

if [ ! -d "p6" ]; then
  echo "==> Cloning perl6"
  git clone https://github.com/rakudo/rakudo.git p6
fi

cd "p6"

YEAR="2014"
MONTH="06"
echo "==> Resetting repo to tags/$YEAR.$MONTH"
git clean -f
git reset --hard "tags/$YEAR.$MONTH"
echo "==> Configuring..."
perl Configure.pl --gen-moar --gen-nqp --gen-parrot --backends=moar,jvm,parrot
RC=$?
if [[ $RC != 0 ]]; then
  echo "==> Dying, 'config' failed"
fi
make
RC=$?
if [[ $RC != 0 ]]; then
  echo "==> Dying, 'make' failed"
fi
make install
if [ ! -d "../sixes/$YEAR.$MONTH" ]; then
  mkdir -p "../sixes/$YEAR.$MONTH"
fi
cp install/* "../sixes/$YEAR.$MONTH"
