#!/bin/bash

set -uex

. local/panda/vars.sh

local/panda/compile.sh
local/panda/pre.sh
local/panda/run.sh
