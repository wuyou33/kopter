# SH09_ft analysis
import os
import sys
import pdb #pdb.set_trace()
import getopt

from moduleFunctions import *

CMDoptionsDict = {}
#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Import FTI variables definitions, hard code input data
CMDoptionsDict = importFTIdefFile('fti_variables_info.txt', CMDoptionsDict)

# Plot settings
plotSettings = importPlottingOptions()

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptionsMainAbaqusParametric(sys.argv[1:], CMDoptionsDict)

typeImport = 'segment'
varClassesDict = {}
for var in CMDoptionsDict['flightTestInfo']['variablesToImport'].split(','):

	varClass = ClassVariableDef(var)

	varClass.importData(CMDoptionsDict, typeImport)

	varClassesDict.update({var : varClass})

plotSignals(plotSettings, varClassesDict, CMDoptionsDict)

for var in ('CNT_DST_LNG', 'CNT_DST_BST_LNG'):

	tempClass = varClassesDict[var]
	tempClass.convertToIncrement()
	varClassesDict.update({var : tempClass})

plotSignals(plotSettings, varClassesDict, CMDoptionsDict)


plt.show(block = True)