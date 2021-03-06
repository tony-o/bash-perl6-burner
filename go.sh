#!/usr/bin/env bash

PKGS=""
COMMAND=""
POST=""

clean ()
{
  git clean -fxd
  echo 'Removing nqp/'
  rm -Rf nqp 
  echo 'Removing parrot/'
  rm -Rf parrot
}

if [[ "`which pkg`" != "" ]]; then
  if [[ "`which java`" == "" ]]; then
    PKGS="$PKGS openjdk-7.71.14_1,1" 
  fi
  if [[ "`which gcc`" == "" ]]; then
    PKGS="$PKGS gcc48"
  fi
  COMMAND="sudo pkg update ; sudo pkg install -y"
  if [[ "`which g++`" == "" ]]; then
    POST="$POST; sudo ln -s /usr/local/bin/g++ /usr/local/bin/g++48"
  fi
fi
if [[ "`which aptitude`" != "" ]]; then
  if [[ "`which git`" == "" ]]; then
    PKGS="$PKGS git"
  fi
  if [[ "`which cc`" == "" ]]; then
    PKGS="$PKGS build-essential"
  fi
  if [[ "`which java`" == "" ]]; then
    PKGS="$PKGS openjdk-7-jdk"
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
for TAG in 2014.12 2015.01
do
  echo "==> Resetting repo to tags/$TAG"
  clean  
  git reset --hard "origin/nom"
  git fetch origin "tags/$TAG"
  git reset --hard "tags/$TAG"
  git checkout "tags/$TAG"
  RC=$?
  if [[ $RC == 0 ]]; then
    if [ ! -f "../sixes/$TAG/bin/perl6-m" ]; then
      clean
      git reset --hard "tags/$TAG"
      perl Configure.pl --prefix="../sixes/$TAG" --gen-moar --gen-nqp --backends=moar && make && make install
    fi
    if [ ! -f "../sixes/$TAG/bin/perl6-j" ]; then
      clean
      git reset --hard "tags/$TAG"
      perl Configure.pl --prefix="../sixes/$TAG" --gen-nqp --backends=jvm && make && make install
    fi
    if [ ! -f "../sixes/$TAG/bin/perl6-p" ]; then
      clean
      git reset --hard "tags/$TAG"
      perl Configure.pl --prefix="../sixes/$TAG" --gen-parrot --backends=parrot && make && make install
    fi
  fi
done

clean 
git checkout "origin/nom"
git reset --hard HEAD
TAG=`date +'%Y.%m.%d'`
if [ ! -f "../sixes/$TAG/bin/perl6-m" ]; then
  echo 'building moar recent';
  clean
  git reset --hard HEAD
  perl Configure.pl --prefix="../sixes/$TAG" --gen-moar --gen-nqp --backends=moar && make && make install
fi
if [ ! -f "../sixes/$TAG/bin/perl6-j" ]; then
  echo 'building java recent'
  clean
  git reset --hard HEAD
  perl Configure.pl --prefix="../sixes/$TAG" --gen-nqp --backends=jvm && make && make install
fi
if [ ! -f "../sixes/$TAG/bin/perl6-p" ]; then
  echo 'building parrot recent'
  clean
  git reset --hard HEAD
  perl Configure.pl --prefix="../sixes/$TAG" --gen-parrot --backends=parrot && make && make install
fi
