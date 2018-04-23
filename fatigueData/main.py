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
CMDoptionsDict['cwd'] = cwd

# What to do?
gaugesFlag = CMDoptionsDict['dmsFlag']
actuatorFlag = CMDoptionsDict['actuatorFlag']
actuatorMesswerteFlag = CMDoptionsDict['actuatorMesswerte']

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

	for mag in CMDoptionsDict['magnitudes']:
		for folderName in inputFolderAddress.getTupleFiles(): #For each folder with min, max or mean values
			os.chdir(folderName)
			listOfFilesInFolderMathingVar = []
			for fileName2 in os.listdir(folderName):
				if fileName2.startswith(mag):

					listOfFilesInFolderMathingVar += [fileName2]

			listOfFilesSortedInFolder = sortFilesInFolderByLastNumberInName(listOfFilesInFolderMathingVar, CMDoptionsDict)
			for dataClass in dataClasses: #For each class variable
				print('---> Importing data for variable: ' + dataClass.get_description() + ', '+mag+ ' values')
					
				for fileName in listOfFilesSortedInFolder: #For each file matching the criteria

					if dataClass.get_description() in fileName: #Restring to only file matching type of variable of class

						print('\n'+'-> Reading: ' + fileName)
						if mag in ('hp', 'lp'):
							dataClass.importDataForClass(fileName, 'rs')
						else:
							dataClass.importDataForClass(fileName, mag)

				#Here dataClass has collected the full data for a variable and magnitude

				if mag in ('hp', 'lp'):
					dataClass.getTimeList('rs')
				else:
					dataClass.getTimeList(mag)
				
				dataClass.reStartXvaluesAndLastID()

				if mag == 'rs' and False:

					newPicksMax, newPicksMean, newPicksMin, timePicks = dataClass.computePicks() ###STRANGE ERROR, PYTHON BUG?
					dataClass.updatePicksData(newPicksMax, newPicksMean, newPicksMin, timePicks)

	# Plotting
	for dataClass in dataClasses: #For each class variable

		#################################

		# Insert data from prescribed loading from the test order
		if CMDoptionsDict['testOrderFlagFromCMD']:

			CMDoptionsDict['testOrderFlag'] = True

			if dataClass.get_description() in ('PitchLinkMain'):
				dataClass.set_prescribedLoadsTO([3600, -1600])

			elif dataClass.get_description() in ('InnerPitchLink'):
				dataClass.set_prescribedLoadsTO([3600*1.15, -1600*1.15])

			elif dataClass.get_description() in ('Tension'):
				dataClass.set_prescribedLoadsTO([4992, -3058]) #first phase
				# dataClass.set_prescribedLoadsTO([5998, -4064]) #second phase

			elif dataClass.get_description() in ('Bending'):
				dataClass.set_prescribedLoadsTO([960, -588]) #first phase
				# dataClass.set_prescribedLoadsTO([1153, -781]) #second phase

			elif dataClass.get_description() in ('Force-SN27', 'Force-SN28'):
				dataClass.set_prescribedLoadsTO([4080/10, -820/10])

			elif dataClass.get_description() in ('DistanceSensor', 'CF', 'BendingMoment', 'MyBlade', 'MyLoadcell', 'MzBlade'):

				if dataClass.get_description() in ('CF'):
					dataClass.set_prescribedLoadsTO([11446, 0.0])
					CMDoptionsDict['testOrderFlag'] = True

				elif dataClass.get_description() in ('BendingMoment'):
					dataClass.set_prescribedLoadsTO([-48, 36]) #Reversed sign, it seems the recording is recording data with opposite sign
					CMDoptionsDict['testOrderFlag'] = True

				else:
					CMDoptionsDict['testOrderFlag'] = False

			else:
				raise ValueError('ERROR: Incorrect handeling of the test order flag loop')


		#Plotting max, min and mean from DIAdem
		# dataClass.plotMaxMinMean_fromDIAdem(plotSettings)

		#Plotting resampled total data
		dataClass.plotResampled(plotSettings, CMDoptionsDict)

		# dataClass.plotMinMeanMax(plotSettings)
		# pass

	os.chdir(cwd)

#Import data from actuator
elif actuatorFlag:
	print('\n'+'**** Running data analysis program for actuator measurements'+'\n')
	inputFilesAddress = loadFileAddresses(CMDoptionsDict['fileNameOfFileToLoadFiles'])

	dataFromRuns, previousNCycles, iFile = [], 0, 1

	for file in inputFilesAddress.getTupleFiles():

		print('-> Reading: ' + file.split('\\')[-1])
		dataFromRun_temp = importDataActuator(file, iFile, CMDoptionsDict)

		dataFromRun_temp.setAbsoluteNCycles(previousNCycles)

		previousNCycles = dataFromRun_temp.get_absoluteNCycles()[-1]

		print('\t'+'-> Last computed data point index (accumulated): ' + str(int(previousNCycles)/1000000.0) + ' millions')

		dataFromRuns += [dataFromRun_temp]

		iFile += 1


	#################################
	#Calculate std and mean of recorded values
	if 'OC' in CMDoptionsDict['fileNameOfFileToLoadFiles']:
		calculate_stats(dataFromRuns[:-2]) #Only the first loading phase
	else:
		calculate_stats(dataFromRuns)

	#################################
	#Plot data
	dataFromRuns[0].plotSingleRun(plotSettings)
	# dataFromRuns[-1].plotSingleRun(plotSettings)

	plotAllRuns_force(dataFromRuns, plotSettings, CMDoptionsDict)
	plotAllRuns_displacement(dataFromRuns, plotSettings, CMDoptionsDict)

elif actuatorMesswerteFlag:

	print('\n'+'**** Running data analysis program for actuator measurements, all data'+'\n')
	inputFilesAddress = loadFileAddresses(CMDoptionsDict['fileNameOfFileToLoadFiles'])

	dataFromRuns, iFile, lastDataPointCounter = [], 1, 0

	for file in inputFilesAddress.getTupleFiles():

		print('-> Reading: ' + file.split('\\')[-1])
		dataFromRun_temp = importDataActuator(file, iFile, CMDoptionsDict)

		lastDataPointCounter += dataFromRun_temp.get_lastDataPointCounter()

		print('\t'+'-> Last computed data point index (accumulated): ' + str(int(lastDataPointCounter)/1000000.0) + ' millions')

		dataFromRuns += [dataFromRun_temp]

		iFile += 1

	plotAllRuns_force_Messwerte(dataFromRuns, plotSettings, CMDoptionsDict)


plt.show(block = True)