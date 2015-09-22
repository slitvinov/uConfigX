#!/bin/bash

export GITROOT=$HOME/uConfigX/bigcyl_MORErbcs
export SUBST_FILE=DOE/subst.file.txt
export CART=DOE/cart.daint
export DEPLOY_CMD=deploy/2daint.sh

sh DOE/batch0.sh
