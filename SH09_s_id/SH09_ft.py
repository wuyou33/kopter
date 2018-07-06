# SH09_ft analysis
import os
import sys
import pdb #pdb.set_trace()
import getopt
import shutil

from moduleFunctions import *

CMDoptionsDict = {}
#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptionsMainAbaqusParametric(sys.argv[1:], CMDoptionsDict)

#Import FTI variables definitions, hard code input data
CMDoptionsDict = importFTIdefFile(CMDoptionsDict['inputFile'], CMDoptionsDict)

if os.path.isdir(CMDoptionsDict['flightTestInfo']['folderResults']):
	print('-> Folder with previous results removed')
	shutil.rmtree(CMDoptionsDict['flightTestInfo']['folderResults'], ignore_errors=True)

os.mkdir(CMDoptionsDict['flightTestInfo']['folderResults'])

# Plot settings
plotSettings = importPlottingOptions()


#Interpol segments
typeImport = 'getSegment'
varClassesGetSegmentsDict = {}
print('\n'+'* Data partioning...')
for var in CMDoptionsDict['flightTestInfo']['variablesToGetSegments'].split(','):

	varClass = ClassVariableDef(var)

	varClass.importData(CMDoptionsDict, typeImport, varClassesGetSegmentsDict)

	varClassesGetSegmentsDict.update({var : varClass})

# Import data
typeImport = 'segment'
varClassesDict = {}
for var in CMDoptionsDict['flightTestInfo']['variablesToImport'].split(','):

	varClass = ClassVariableDef(var)

	varClass.importData(CMDoptionsDict, typeImport, varClassesGetSegmentsDict)

	varClassesDict.update({var : varClass})

for dof in CMDoptionsDict['flightTestInfo']['dofs'].split(','): #('LNG', 'COL', 'LAT')

	# Inputs
	tempClassInput = varClassesDict['CNT_DST_'+dof]
	tempClassInput.convertToIncrement()
	varClassesDict.update({'CNT_DST_'+dof : tempClassInput})

	# Outputs
	tempClassOutput = varClassesDict['CNT_DST_BST_'+dof]
	tempClassOutput.convertToIncrement()
	varClassesDict.update({'CNT_DST_BST_'+dof : tempClassOutput})

# plotSignals(plotSettings, varClassesDict, CMDoptionsDict)

testClassesDict = {}
for dof in CMDoptionsDict['flightTestInfo']['dofs'].split(','): #('LNG', 'COL', 'LAT')

	print('\n\n'+'** Analysing '+dof+' degree of freedom')

	if not os.path.isdir(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], dof+'\\')):
		os.mkdir(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], dof+'\\'))

	tempClassInput = varClassesDict['CNT_DST_'+dof]
	tempClassOutput = varClassesDict['CNT_DST_BST_'+dof]
	tempClassOutputVel = varClassesDict['DIF_CNT_DST_BST_'+dof]
	
	testClass = testClassDef(dof)
	testClass.includeTimeSegmentsFreq(tempClassInput, plotSettings, CMDoptionsDict) #Any class intrucced here would be valid
	print('\n'+'* Segments info')
	testClass.getSegmentParameters(varClassesDict, dof, plotSettings, CMDoptionsDict) #Any class intrucced here would be valid
	
	testClass.identifyFirstOrder(tempClassInput, tempClassOutput, tempClassOutputVel, plotSettings, CMDoptionsDict) #standardRegressorsFlag

	testClass.showInfluenceParameters({'margin_freq': 10, 'margin_force': 15}, plotSettings, CMDoptionsDict) #10%, 5% of margin
	varClassesDict.update({dof : testClass})

# plt.show(block = False)