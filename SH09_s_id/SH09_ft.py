# SH09_ft analysis
import os
import sys
import pdb #pdb.set_trace()
import getopt

from moduleFunctions import *

CMDoptionsDict = {}

#Hard code input data
CMDoptionsDict['folderFTdata'] = 'flightTestData\\P2-J17-01-FT0038\\data'

#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Import FTI variables definitions
CMDoptionsDict = importFTIdefFile('fti_variables_info.txt', CMDoptionsDict) 

# Plot settings
plotSettings = importPlottingOptions()

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptionsMainAbaqusParametric(sys.argv[1:], CMDoptionsDict)

varClasses = ()
for var in CMDoptionsDict['variables']:

	varClass = ClassVariableDef(var)

	varClass.importData(CMDoptionsDict)

	varClasses += (varClass, )

plotSignals(plotSettings, varClasses)

plt.show(block = True)