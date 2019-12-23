#!/bin/bash

chromedriver=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)

if [ $? -ne 0 ]; then
  echo "Can't download chromedriver LATEST_RELEASE from https://chromedriver.storage.googleapis.com/LATEST_RELEASE"
  exit 1
fi

unameOut=$(uname -s)
case $unameOut in
Linux*) machine=linux ;;
Darwin*) machine=mac ;;
CYGWIN*) machine=cygwin ;;
MINGW*) machine=minGw ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac

[ "${machine}" != 'linux' ] && [ "${machine}" != 'mac' ] && echo "This script only run on Mac or Linux. Current machine is ${machine}" && exit 1

function updateChromeDriver() {
  curl -O -J -L "https://chromedriver.storage.googleapis.com/${chromedriver}/chromedriver_${machine}64.zip"

  if [ $? -ne 0 ]; then
    echo "Can't download chromedriver_${machine}64.zip from https://chromedriver.storage.googleapis.com/${chromedriver}"
    exit 1
  fi

  if [ -f "chromedriver" ]; then
    rm chromedriver
    if [ $? -ne 0 ]; then
      echo "Can't delete chromedriver file"
      exit 1
    fi
  fi

  unzip -a "chromedriver_${machine}64.zip"
  if [ $? -ne 0 ]; then
    echo "Can't unzip chromedriver_${machine}64.zip"
    exit 1
  fi

  if [ ! -f "chromedriver" ]; then
    echo "Error unzip chromedriver_${machine}64.zip"
    exit 1
  fi

  rm "chromedriver_${machine}64.zip"
  if [ $? -ne 0 ]; then
    echo "Can't remove chromedriver_${machine}64.zip"
    exit 1
  fi

  chmod +x chromedriver
  if [ $? -ne 0 ]; then
    echo "Can't change permissions on file chromedriver"
    exit 1
  fi

  echo "Chromedriver updated seccesfull to version ${chromedriver}"
}

FILE=chromedriver
if [ ! -f "$FILE" ]; then
  updateChromeDriver
else
  local_chromedriver=$(./$FILE -v |awk '{print $2}')
  if [ "${chromedriver}" != "${local_chromedriver}" ]; then
    echo "Local version is ${local_chromedriver}, but latest version is ${chromedriver}"
    updateChromeDriver
  else
    echo "Chromedriver is up to date"
  fi
fi
