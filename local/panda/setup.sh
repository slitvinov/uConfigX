#!/bin/bash

. local/panda/vars.sh

local/panda/patch.sh
local/panda/compile.sh
local/panda/unpatch.sh
local/panda/pre.sh
local/panda/run.sh
