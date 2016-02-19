#!/bin/bash
# A wrapper script to run visit as python library

PYTHON=/Users/lisergey/prefix-pkgsrc-master64/bin/ipython
export VISIT_LIB_PATH=/Applications/VisIt.app/Contents/Resources/2.9.2/darwin-x86_64/lib

export LD_LIBRARY_PATH="$VISIT_LIB_PATH":$LD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH:$VISIT_LIB_PATH/site-packages:$HOME/.vpython
"$PYTHON" "$@"
