#!/bin/bash
CURRENTDIR=`dirname $0`

cd $CURRENTDIR/chef-repo

echo "-- Execute berks vendor --"
rm -rf Berksfile.lock cookbooks/ 2>/dev/null
LANG=en_US.UTF-8 berks vendor cookbooks/

echo "-- Execute knife zero --"
knife zero converge 'name:*' -x root
if [ $? -ne 0 ] ; then
  echo "-- Failure --"
  exit 1
fi

echo "-- Success --"
