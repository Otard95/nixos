#!/usr/bin/env bash

cp $1 $1.bak
unlink $1
mv $1.bak $1
chmod 644 $1
