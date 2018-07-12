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
reviewInputParameters(CMDoptionsDict)

if os.path.isdir(CMDoptionsDict['flightTestInfo']['folderResults']):
	print('\n'+'* Folder with previous results removed')
	shutil.rmtree(CMDoptionsDict['flightTestInfo']['folderResults'], ignore_errors=True)

os.mkdir(CMDoptionsDict['flightTestInfo']['folderResults'])

# Plot settings
plotSettings = importPlottingOptions()


#Interpol segments
varClassesDict = {}
varClassesGetSegmentsDict = {}
for dof in CMDoptionsDict['flightTestInfo']['dofs'].split(','):
	
	if CMDoptionsDict['flightTestInfo']['segment_calculationMode'].lower() == 'auto':
		typeImport = 'getSegment'
		print('\n'+'* Data partioning...')

		varClass = ClassVariableDef('DIF_CNT_DST_'+dof)

		varClass.importData(CMDoptionsDict, typeImport, varClassesGetSegmentsDict)

		varClassesGetSegmentsDict.update({'DIF_CNT_DST_'+dof : varClass})

	# Import data, all the variables
	typeImport = 'segment'
	for var in [prefix + dof for prefix in ['CNT_DST_','DIF_CNT_DST_','CNT_DST_BST_','DIF_CNT_DST_BST_','CNT_FRC_BST_']]:

		varClass = ClassVariableDef(var)

		varClass.importData(CMDoptionsDict, typeImport, varClassesGetSegmentsDict)

		varClassesDict.update({var : varClass})

# Convert variables, 
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
	
	testClass = testClassDef(dof)
	testClass.includeTimeSegmentsFreq(varClassesDict, dof, plotSettings, CMDoptionsDict) #Any class intrucced here would be valid
	print('\n'+'* Segments info')
	testClass.getSegmentParameters(varClassesDict, dof, plotSettings, CMDoptionsDict) #Any class intrucced here would be valid
	
	testClass.identifyFirstOrder(varClassesDict, dof, plotSettings, CMDoptionsDict, varClassesGetSegmentsDict) #standardRegressorsFlag

	testClass.showInfluenceParameters(plotSettings, CMDoptionsDict) #standardRegressorsFlag
	# testClass.showInfluenceForceAndPilotFreq(plotSettings, CMDoptionsDict) #10%, 5% of margin
	testClassesDict.update({dof : testClass})

# plt.show(block = False)