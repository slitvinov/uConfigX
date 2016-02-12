#!/bin/bash

set -eux

. local/panda/vars.sh

local/daint/compile_libs.sh
local/daint/compile.sh
local/panda/pre.sh
local/daint/run.sh
