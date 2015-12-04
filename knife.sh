#!/bin/bash

CURRENTDIR=$(dirname $0)
. $CURRENTDIR/server.conf

KNIFE_USER=root
CHEF_REPO_DIR="${CURRENTDIR}/chef-repo"
SSH_DIR="${HOME}/.ssh"
SSH_KEY_FILE_NAME="id_rsa_${NODE_NAME}"
SSH_KEY="${SSH_DIR}/${SSH_KEY_FILE_NAME}"
SSH_PUB_KEY="${SSH_KEY}.pub"

# Create SSH key file
echo "-- Create SSH keys --"
if [ -e $SSH_KEY ] ; then
  echo "Key file '${SSH_KEY}' exists, passed."
else
  if [ ! -d $SSH_DIR ] ; then
    mkdir $SSH_DIR
    chmod 700 $SSH_DIR
  fi
  ssh-keygen -t rsa -b 4096 -f $SSH_KEY -N ""
  if [ $? -ne 0 ] ; then
    echo "Failed!"
    exit 1
  fi

  touch ${SSH_DIR}/config
  egrep "^Host ${NODE_NAME}" ${SSH_DIR}/config > /dev/null
  if [ $? -ne 0 ] ; then
    cat << EOH >> ${SSH_DIR}/config
Host ${NODE_NAME}
  HostName     ${HOST_NAME}
  user         ${USER_NAME}
  IdentityFile ${SSH_KEY}
  Port         22
EOH
  fi
fi
echo

ssh ${NODE_NAME} "exit" >/dev/null 2>&1
if [ $? -eq 0 ] ; then KNIFE_USER=${USER_NAME} ; fi

# Create user data file (in data_bags)
echo "-- Create user data file --"
json_file="${CHEF_REPO_DIR}/data_bags/users/${USER_NAME}.json"
if [ -e $json_file ] ; then
  echo "User file '${json_file}' exists, passed."
else
  if [ "a${USER_GROUP}" == "a" ] ; then USER_GROUP=$USER_NAME ; fi
  crypted_password=$(openssl passwd -1 "${USER_PASSWORD}")
  ssh_key_content=$(cat ${SSH_PUB_KEY})
  cat << EOH > $json_file
{
  "id": "${USER_NAME}",
  "name": "${USER_NAME}",
  "password": "${crypted_password}",
  "ssh_public_key": "${ssh_key_content}",
  "group": "${USER_GROUP}",
  "comment": "Administrator",
  "wheel": true
}
EOH
  echo "User file '${json_file}' created."
fi
echo

cd $CHEF_REPO_DIR

# knife bootstrap
echo "-- Initialize server chef environment --"
if [ -e nodes/${NODE_NAME}.json ] ; then
  echo -n "Node '${NODE_NAME}' exists, passed."
else
  if [ "$KNIFE_USER" == "$USER_NAME" ] ; then
    cmd="knife zero bootstrap ${HOST_NAME} -x ${KNIFE_USER} -i ${SSH_KEY} --sudo -N ${NODE_NAME} -E sakuravps"
  else
    cmd="knife zero bootstrap ${HOST_NAME} -x ${KNIFE_USER} -N ${NODE_NAME} -E sakuravps"
  fi
  $cmd
  if [ $? -ne 0 ] ; then
    echo "Failure!"
    exit 1
  fi

  knife node run_list add ${NODE_NAME} 'recipe[sakuravps]'
  knife node run_list add ${NODE_NAME} 'role[eccube3]'
  echo "Node ${NODE_NAME} created."
fi
echo

# Execute berkshelf
echo "-- Execute berks vendor --"
rm -rf Berksfile.lock cookbooks/ 2>/dev/null
LANG=en_US.UTF-8 berks vendor cookbooks/
echo

# Execute knife zero
echo "-- Execute knife zero --"
if [ "$KNIFE_USER" == "$USER_NAME" ] ; then
  knife zero converge "name:${NODE_NAME}" -x ${KNIFE_USER} -i ${SSH_KEY} --sudo
else
  knife zero converge "name:${NODE_NAME}" -x ${KNIFE_USER}
fi
if [ $? -ne 0 ] ; then
  echo "Failed!"
  exit 1
fi
echo

echo "-- Success --"
