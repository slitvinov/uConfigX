#!/bin/bash

# http://stackoverflow.com/a/246128/1534218
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -eux

export GITROOT=`cd $DIR/../; pwd`
export SUBST_FILE=DOE/subst.file.txt
export CART=DOE/cart.daint
export TRANSFORM=DOE/transform.daint

export DEPLOY_CMD=deploy/2panda.sh

sh DOE/batch0.sh
