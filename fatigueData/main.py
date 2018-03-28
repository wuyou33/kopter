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
	variables = ('rs',)#('rs', 'min', 'max', 'mean')
	orderDeriv = 2	

	dataClasses = ()
	for var in CMDoptionsDict['variables']:
		dataVar = dataFromGaugesSingleMagnitudeClass(var, testFactor, orderDeriv)
		dataClasses += (dataVar, )
		# dataInnerPitchLink = dataFromGaugesSingleMagnitudeClass('InnerPitchLink', testFactor, orderDeriv)
	# dataClasses = (dataMainPitchLink, dataInnerPitchLink)
	# dataClasses = (dataMainPitchLink,)
	inputFolderAddress = loadFileAddresses(CMDoptionsDict['fileNameOfFileToLoadFiles'])

	for var in CMDoptionsDict['magnitudes']:
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

						print('\n'+'-> Reading: ' + fileName)
						dataClass.importDataForClass(fileName, var)

				#Here dataClass has collected the full data for a variable and magnitude

				dataClass.getTimeList(var)
				
				dataClass.reStartXvaluesAndLastID()

				if var == 'rs' and False:

					newPicksMax, newPicksMean, newPicksMin, timePicks = dataClass.computePicks() ###STRANGE ERROR, PYTHON BUG?
					dataClass.updatePicksData(newPicksMax, newPicksMean, newPicksMin, timePicks)

	# Plotting
	for dataClass in dataClasses: #For each class variable


		#Plotting max, min and mean from DIAdem
		# dataClass.plotMaxMinMean_fromDIAdem(plotSettings)

		#Plotting resampled total data
		dataClass.plotResampled(plotSettings)

		# dataClass.plotMinMeanMax(plotSettings)
		# pass

	os.chdir(cwd)

#Import data from actuator
if actuatorFlag:
	print('\n'+'**** Running data analysis program for calibrated strain gauges measurements'+'\n')
	inputFilesAddress = loadFileAddresses(CMDoptionsDict['fileNameOfFileToLoadFiles'])

	dataFromRuns, previousNCycles, iFile = [], 0, 1

	for file in inputFilesAddress.getTupleFiles():

		print('-> Reading: ' + file.split('\\')[-1])
		dataFromRun_temp = importDataActuator(file, iFile)

		dataFromRun_temp.setAbsoluteNCycles(previousNCycles)

		previousNCycles = dataFromRun_temp.get_absoluteNCycles()[-1]

		print('----> Last computed data point index (accumulated): ' + str(int(previousNCycles)/1000000.0) + ' millions')

		dataFromRuns += [dataFromRun_temp]

		iFile += 1

	#################################

	#Plot data
	dataFromRuns[5].plotSingleRun(plotSettings)
	plotAllRuns(dataFromRuns, plotSettings)

plt.show(block = True)