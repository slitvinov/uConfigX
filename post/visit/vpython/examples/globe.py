from visit import *
from vcustom import *

OpenDatabase("/Applications/VisIt.app/Contents/Resources/data/globe.silo")
AddPlot("Pseudocolor", "u", 0, 0)
DrawPlots()

