#!/bin/bash

cat << EOS
**************************************
* EC-CUBE 3 on Sakura Internet VPS   *
**************************************

EOS

# Host
echo "(1)Input host name."
echo "-------------------------------"
host=""
while [ "a$host" == "a" ] ; do
  echo -n "Input host domain or IP address:"
  read host
done
echo

# User
echo "(2)Input user name for login(not root)."
echo "-------------------------------"
user=""
while [ "a$user" == "a" ] ; do
  echo -n "Input user name:"
  read user
  if [ "a$user" == "aroot" ] ; then
    echo "Invalid user name '$user'"
    user=""
  fi
done

host=ik1-330-25021.vs.sakura.ne.jp

echo "(3)Login to $host as root."
echo "-------------------------------"

# SSH login and run scripts on remote host
ssh root@$host bash << EOS
echo "Login success."
echo
echo "(4)Change root password."
echo "-------------------------------"
passwd
echo
echo "(5)Create normal user."
echo "-------------------------------"
grep $user /etc/passwd > /dev/null
if [ $? -eq 0 ] ; then
  echo "User '$user' already exists."
else
  useradd $user
  echo "User '$user' created."
  echo
  echo "(6)Set user '$user''s password."
  echo "-------------------------------"
  passwd $user
  echo "User '$user''s password set."
fi
echo "(7)Create authentication key"
echo "-------------------------------"
su - $user -c "ssh-keygen -t rsa -b 4096"
echo "User key file created."

exit
EOS

#cat $tempfile | ssh root@$host bash

rm -f $tempfile
