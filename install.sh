#!/bin/sh

prefix=~/magicnote
BIN=$prefix/bin
DATA=$prefix/var
ETC=$prefix/etc

# install binrary
mkdir -p $BIN
cp ./magicnote ./magicnote_git $BIN
cp core/action.lua $BIN/magicnote_action.lua
cp core/util.lua $BIN/magicnote_util.lua

# install data
mkdir -p $DATA

# install configuration
mkdir -p $ETC
version=`cat RELEASE | grep -P "^\d\.\d\.\d" | head -1`
sed -e "s/VERSION=.*/VERSION=\"$version\"/" magicnote_base > /tmp/magicnote_base
cp /tmp/magicnote_base $ETC
cp ./magicnote_complete.bash ~/.magicnote_complete.bash
cp ./magicnote_complete_git.bash ~/.magicnote_complete_git.bash
rm -f /tmp/magicnote_base

# prepare a default magicnoterc
echo "Installed at $prefix --> completed, have a fun"
sed -e "s:MAGICTOP=.*:MAGICTOP=$prefix:" magicnoterc > /tmp/magicnoterc

cp /tmp/magicnoterc $ETC
cp /tmp/magicnoterc ~/.magicnoterc
rm -f /tmp/magicnoterc
