#!/bin/bash
CURRENTDIR=`dirname $0`

rm -rf $CURRENTDIR/Berksfile.lock $CURRENTDIR/cookbooks/ 2>/dev/null
LANG=en_US.UTF-8 berks vendor cookbooks/
