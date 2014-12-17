#!/usr/bin/env bash

PKGS=""
COMMAND=""
POST=""

if [[ "`which pkg`" != "" ]]; then
  if [[ "`which java`" == "" ]]; then
    PKGS="$PKGS openjdk-7.71.14_1,1" 
  fi
  if [[ "`which gcc`" == "" ]]; then
    PKGS="$PKGS gcc48"
  fi
  COMMAND="sudo pkg update ; sudo pkg install -y"
  POST="sudo ln -s /usr/local/bin/g++ /usr/local/bin/g++48"
fi
if [[ "`which aptitude`" != "" ]]; then
  if [[ "`which git`" == "" ]]; then
    PKGS="$PKGS git"
  fi
  if [[ "`which cc`" == "" ]]; then
    PKGS="$PKGS build-essential"
  fi
  COMMAND="sudo aptitude update ; sudo aptitude install"
fi

if [[ "$PKGS" != "" ]]; then
  echo "==> Installing depends"
  eval "$COMMAND $PKGS"
fi
if [[ "$POST" != "" ]]; then
  echo "==> Post commands"
  eval "$POST"
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
or year in `seq 2014 2016`;
do
  for month in `seq -f '%02g' 6 12`;
  do
    if [ ! -d "$HOME/build/perl6s/$year.$month" ]; then
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
    fi
  done
done
