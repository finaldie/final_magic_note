#!/bin/sh

prefix=~/magicnote
BIN=$prefix/bin
DATA=$prefix/var
ETC=$prefix/etc

# install binrary
mkdir -p $BIN
mkdir -p /usr/local/share/magicnote
cp ./magicnote $BIN
cp core/* /usr/local/share/magicnote

# install data
mkdir -p $DATA

# install configuration
mkdir -p $ETC
echo "prefix="$prefix
echo "## this configuration for magic note, will be included by source command" > ./magicnoterc
echo "MAGICTOP=$prefix" >> ./magicnoterc
cp ./magicnoterc $ETC
cp ./magicnoterc ~/.magicnoterc
