#!/bin/bash

. local/panda/vars.sh

local/daint/compile.sh
local/panda/pre.sh
local/daint/run.sh
