#!/bin/sh

prefix=~/magicnote
BIN=$prefix/bin
DATA=$prefix/var
ETC=$prefix/etc

# install binrary
mkdir -p $BIN
cp ./magicnote $BIN
cp core/action.lua $BIN/magicnote_action.lua
cp core/util.lua $BIN/magicnote_util.lua

# install data
mkdir -p $DATA

# install configuration
mkdir -p $ETC

# prepare a default magicnoterc
echo "prefix="$prefix
echo "## this configuration for magic note, will be included by source command" > ./magicnoterc
echo "MAGICTOP=$prefix" >> ./magicnoterc
echo "CURRENT=main" >> ./magicnoterc

cp ./magicnoterc $ETC
cp ./magicnoterc ~/.magicnoterc
