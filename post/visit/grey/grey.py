from vcustom import *
from visit   import *
import sys
import os

def red():
    OpenDatabase("ply/p.visit")
    AddPlot("Subset", "PLY_mesh", 0, 0)
    AddPlot("Mesh", "PLY_mesh", 0, 0)
    repl()

def grey():
    OpenDatabase("ply/grid/g.visit")
    AddPlot("Pseudocolor", "d", 0, 0)
    atts = PseudocolorAttributes()
    atts.invertColorTable = 1
    atts.colorTableName = "gray"
    atts.opacityType = atts.Constant  # ColorTable, FullyOpaque, Constant, Ramp, VariableRange
    atts.opacity = 0.647059
    SetPlotOptions(atts)
    AddOperator("Elevate", 0)
    opAtts = ElevateAttributes()
    opAtts.zeroFlag = 1
    SetOperatorOptions(opAtts)
    repl()

def egg_small():
    OpenDatabase("~/geoms/egg/egg.vti")
    AddPlot("Pseudocolor", "wall", 0, 0)
    atts = PseudocolorAttributes()
    atts.scaling = atts.Skew  # Linear, Log, Skew    
    atts.skewFactor = 100
    atts.colorTableName = "gray"
    atts.invertColorTable = 1
    SetPlotOptions(atts)
    AddOperator("Isosurface", 0)
    repl()

def back(c = 100):
    annot = AnnotationAttributes()
    annot.backgroundColor = (c, c, c, 255)
    SetAnnotationAttributes(annot)

def egg_big():
    OpenDatabase("~/geoms/egg/egg.ext.vti")
    AddPlot("Pseudocolor", "wall", 0, 0)
    atts = PseudocolorAttributes()
    atts.scaling = atts.Skew  # Linear, Log, Skew
    atts.skewFactor = 10
    atts.colorTableName = "gray"
    SetPlotOptions(atts)
    AddOperator("Isosurface", 0)
    repl()

def wall():
    egg_small()
    egg_big()

def repl():
    AddOperator("Replicate", 0)
    opAtts = ReplicateAttributes()
    opAtts.xVector = (32, 0, 0)
    opAtts.xReplications = 3
    SetOperatorOptions(opAtts)

def view():
    view = View3DAttributes()    
    view.imageZoom = 1.77156
    SetView3D(view)

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

back()
#grey()
wall()
win()

red()

DrawPlots()
SaveWindow()
