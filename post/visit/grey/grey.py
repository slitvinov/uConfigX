from vcustom import *
from visit   import *
import sys
import os

def grey():
    OpenDatabase("ply/grid/g.visit")
    AddPlot("Pseudocolor", "d", 0, 0)
    atts = PseudocolorAttributes()
    atts.invertColorTable = 1
    atts.colorTableName = "gray"
    atts.opacityType = atts.Constant  # ColorTable, FullyOpaque, Constant, Ramp, VariableRange
    atts.opacity = 0.1
    SetPlotOptions(atts)
    AddOperator("Elevate", 0)
    opAtts = ElevateAttributes()
    opAtts.zeroFlag = 1
    SetOperatorOptions(opAtts)
    repl()

def egg_small():
    OpenDatabase("~/geoms/egg/egg.vti")
    AddPlot("Pseudocolor", "wall", 0, 0)
    AddOperator("Slice", 0)
    opAtts = SliceAttributes()
    opAtts.project2d = 0
    opAtts.meshName = "mesh"
    SetOperatorOptions(opAtts)
    AddOperator("Isosurface", 0)
    repl()

def egg_big():
    OpenDatabase("~/geoms/egg/egg.ext.vti")
    AddPlot("Pseudocolor", "wall", 0, 0)
    AddOperator("Slice", 0)
    opAtts = SliceAttributes()
    opAtts.project2d = 0
    opAtts.meshName = "mesh"
    SetOperatorOptions(opAtts)
    AddOperator("Isosurface", 0)
    repl()

def wall():
    egg_small()
    egg_big()

def repl():
    AddOperator("Replicate", 0)
    opAtts = ReplicateAttributes()
    opAtts.xVector = (32, 0, 0)
    opAtts.xReplications = 2
    SetOperatorOptions(opAtts)

def win():
    s = GetSaveWindowAttributes()
    s.family = 0
    s.outputToCurrentDirectory = 0
    s.outputDirectory = "."
    s.fileName = "out"
    s.width = 3024
    s.height = 3024
    SetSaveWindowAttributes(s)

nt = TimeSliderGetNStates()
SetTimeSliderState(nt/2)

grey()
wall()
win()

DrawPlots()
SaveWindow()
