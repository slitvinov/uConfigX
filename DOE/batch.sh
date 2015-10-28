#!/bin/bash

export GITROOT=$HOME/uConfigX/gerris
export SUBST_FILE=DOE/subst.file.txt
export CART=DOE/cart.daint
export TRANSFORM=DOE/transform.daint

#export DEPLOY_CMD=deploy/2panda.sh
export DEPLOY_CMD=deploy/2daint.sh

sh DOE/batch0.sh
