#!/bin/bash

. local/panda/vars.sh

local/panda/patch.sh
local/daint/compile.sh
local/panda/pre.sh
local/daint/run.sh
