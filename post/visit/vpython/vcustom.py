from visit import *

def sf(fn = "script.py" ):
    ''' save visit state to a python file '''
    f = open(fn, "wt")
    WriteScript(f)
    f.close()

def v():
    ''' run visit gui '''
    OpenGUI("-nosplash", "-noconfig")

def sw(fn = "visit"):
    ''' save png file '''
    import os
    fn = os.path.splitext(fn)[0] # get rid of the suffix
    # save png image
    atts = GetSaveWindowAttributes()
    atts.family = 0
    atts.outputToCurrentDirectory = 1
    h = 1024; w = int(1.2*h)
    atts.width  = w
    atts.height = h
    atts.quality = 100
    atts.fileName = fn
    atts.format = atts.PNG
    SetSaveWindowAttributes(atts)
    fn = SaveWindow()
    print "(pmesh.py) saving %s\n" % fn    

def go_last():
    lst = TimeSliderGetNStates()-1
    SetTimeSliderState(lst)
    
