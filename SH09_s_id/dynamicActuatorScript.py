import os
import time
import sys
import pdb #pdb.set_trace()
import getopt

from moduleFunctions import *

CMDoptionsDict = {}
#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptions(sys.argv[1:], CMDoptionsDict)

#Import FTI variables definitions, hard code input data
CMDoptionsDict = importFTIdefFile(CMDoptionsDict['inputFile'], CMDoptionsDict)
reviewInputParameters(CMDoptionsDict)

# Plot settings
plotSettings = importPlottingOptions()

# Import data

varClassesDict = {}
for var in CMDoptionsDict['flightTestInfo']['varsToImport'].split(','):

	varClass = ClassVariableDef(var)

	varClass.importDataWithTime(CMDoptionsDict)

	varClassesDict.update({var : varClass})

for var in [b for b in CMDoptionsDict['flightTestInfo']['varsToImport'].split(',') if 'CNT_DST_BST_' in b]:

	varClass = varClassesDict[var]

	varClass.get_picks_and_travel(CMDoptionsDict)

	varClassesDict.update({var : varClass})

var = CMDoptionsDict['flightTestInfo']['varsToImport'].split(',')[0]

for pressureVar in [b for b in CMDoptionsDict['flightTestInfo']['varsToImport'].split(',') if 'sg__CopyYHYD_PRS_' in b]:
	for distanceVar in [b for b in CMDoptionsDict['flightTestInfo']['varsToImport'].split(',') if 'sg__CopyYCNT_DST_BST_' in b]:
		plot_fti_measurements_cavitation(distanceVar, pressureVar, 'dif__'+distanceVar.split('__')[1], varClassesDict, plotSettings)

plt.show(block = True)