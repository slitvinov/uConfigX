#!/bin/bash

export GITROOT=$HOME/uConfigX/5rbcs
export SUBST_FILE=DOE/subst.file.txt
export CART=DOE/cart.daint
export TRANSFORM=DOE/transform.daint

export DEPLOY_CMD=deploy/2panda.sh

sh DOE/batch0.sh
