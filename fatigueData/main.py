import os
import sys
import pdb #pdb.set_trace()
import getopt

from moduleFunctions import *

#Read postProc folder name from CMD
CMDoptionsDict = {}
CMDoptionsDict = readCMDoptionsMainAbaqusParametric(sys.argv[1:], CMDoptionsDict)

# Import settings
plotSettings = importPlottingOptions()
cwd = os.getcwd() #Get working directory

# What to do?
gaugesFlag = CMDoptionsDict['dmsFlag']
actuatorFlag = CMDoptionsDict['actuatorFlag']

# Gauges data analysis
if gaugesFlag:
	print('\n'+'**** Running data analysis program for calibrated strain gauges measurements'+'\n')

	testFactor = 1000000.0 #HZ
	variables = ('rs', 'min', 'max', 'mean')

	dataMainPitchLink = dataFromGaugesSingleMagnitudeClass('PitchLinkMain', testFactor)
	dataInnerPitchLink = dataFromGaugesSingleMagnitudeClass('InnerPitchLink', testFactor)
	dataClasses = (dataMainPitchLink, dataInnerPitchLink)
	inputFolderAddress = loadFileAddresses(CMDoptionsDict['fileNameOfFileToLoadFiles'])

	for var in variables:
		for folderName in inputFolderAddress.getTupleFiles(): #For each folder with min, max or mean values
			os.chdir(folderName)
			listOfFilesInFolderMathingVar = []
			for fileName2 in os.listdir(folderName):
				if fileName2.startswith(var):

					listOfFilesInFolderMathingVar += [fileName2]

			listOfFilesSortedInFolder = sortFilesInFolderByLastNumberInName(listOfFilesInFolderMathingVar)

			for dataClass in dataClasses: #For each class variable
				print('---> Importing data for variable: ' + dataClass.get_description() + ', '+var+ ' values')
					
				for fileName in listOfFilesSortedInFolder: #For each file matching the criteria

					if dataClass.get_description() in fileName: #Restring to only file matching type of variable of class

						print('-> Reading: ' + fileName)
						dataClass.importDataForClass(fileName, var)
						# dataClass.reStartXvalues()

				dataClass.getTimeList(var)
				
				dataClass.reStartXvaluesAndLastID()

	# Plotting
	for dataClass in dataClasses: #For each class variable
		# dataClass.plotMaxMinMean(plotSettings)
		dataClass.plotResampled(plotSettings)

	os.chdir(cwd)

#Import data from actuator
if actuatorFlag:
	print('\n'+'**** Running data analysis program for calibrated strain gauges measurements'+'\n')
	inputFilesAddress = loadFileAddresses(CMDoptionsDict['fileNameOfFileToLoadFiles'])

	dataFromRuns, previousNCycles = [], 0

	for file in inputFilesAddress.getTupleFiles():

		print('-> Reading: ' + file.split('\\')[-1])
		dataFromRun_temp = importDataActuator(file)

		dataFromRun_temp.setAbsoluteNCycles(previousNCycles)

		previousNCycles = dataFromRun_temp.get_absoluteNCycles()[-1]

		print('----> Last computed data point index: ' + str(int(previousNCycles)/1000000.0) + ' millions')

		dataFromRuns += [dataFromRun_temp]

	#################################

	#Plot data
	plotSingleRun(dataFromRuns[0], plotSettings)
	plotAllRuns(dataFromRuns, plotSettings)

plt.show(block = True)