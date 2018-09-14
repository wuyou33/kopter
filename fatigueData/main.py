import os
import sys
import pdb #pdb.set_trace()
import getopt
import shutil

from moduleFunctions import *

# CMD input
# actuator:
# python main.py -f filesToLoad_actuator_outerBearing.txt -o -2.1,2.1 -s t
# 
# gauges:
# python main.py -f filesToLoad_gauges_enduranceActuatorNewBearing.txt -v DruckHP1,DruckHP2,DurchflussHP1,DurchflussHP2,ForcePistonEyeHP1,ForcePistonEyeHP2,InputForce,LaserPiston,LaserSteuerventilhebel,OutputForce,TemperaturHP1,TemperaturHP2 -m lp -o f -s t,t -r 1,2,3,4,5,6,7,8,9 -a t
# python main.py -f filesToLoad_gauges_TRbladeholder.txt -v BendingMoment,MyBlade,MyLoadcell,MzBlade,CF -m rs -o f -s t,t -a f -r 11,12,13,14,15
# python main.py -f filesToLoad_gauges_OC.txt -v Tension,Bending -m rs -o t -s t,t -a f -r 1,2,3,4,5,6

# Dicitionary of loading options
CMDoptionsDict = {}

#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptionsMainAbaqusParametric(sys.argv[1:], CMDoptionsDict)

#Write output data
if CMDoptionsDict['writeStepResultsToFileFlag']:
	CMDoptionsDict['stepsSummaryResultsFolder'] = os.path.join(CMDoptionsDict['cwd'],'stepsSummaryResults')
	if not os.path.isdir(CMDoptionsDict['stepsSummaryResultsFolder']):
		os.mkdir(CMDoptionsDict['stepsSummaryResultsFolder'])

# What to do?
gaugesFlag = CMDoptionsDict['dmsFlag']
actuatorFlag = CMDoptionsDict['actuatorFlag']
actuatorMesswerteFlag = CMDoptionsDict['actuatorMesswerte']

# Gauges data analysis
if gaugesFlag:
	print('\n'+'**** Running data analysis program for calibrated strain gauges measurements'+'\n')

	testFactor = 1.0 #HZ
	orderDeriv = 2	
	# Import settings
	plotSettings = importPlottingOptions()
	for magComplex in CMDoptionsDict['magnitudes']:

		dataClasses = ()
		for var in CMDoptionsDict['variables']:
			dataVar = dataFromGaugesSingleMagnitudeClass(var, testFactor, orderDeriv)
			dataClasses += (dataVar, )
			# dataInnerPitchLink = dataFromGaugesSingleMagnitudeClass('InnerPitchLink', testFactor, orderDeriv)
		# dataClasses = (dataMainPitchLink, dataInnerPitchLink)
		# dataClasses = (dataMainPitchLink,)
		inputDataClass = loadFileAddressesAndData(CMDoptionsDict['fileNameOfFileToLoadFiles'], 'gauges')
		mag = magComplex[:2]

		if magComplex[2:]:
			additionalMag = magComplex[2:]

		for folderName in inputDataClass.getTupleFiles(): #For each folder with min, max or mean values
			os.chdir(folderName)
			listOfFilesInFolderMathingVar = []

			for fileName2 in os.listdir(folderName):
				if fileName2.endswith('.csv'): #Take only .csv files
					if magComplex[2:]:
						if fileName2.startswith(mag) and fileName2.split('.csv')[0].split('__')[-1] in CMDoptionsDict['rangeFileIDs'] and fileName2.split('__')[-2][:-2] == additionalMag:
							listOfFilesInFolderMathingVar += [fileName2]
					else:
						if fileName2.startswith(mag) and fileName2.split('.csv')[0].split('__')[-1] in CMDoptionsDict['rangeFileIDs']:
							listOfFilesInFolderMathingVar += [fileName2]

			listOfFilesSortedInFolder = sortFilesInFolderByLastNumberInName(listOfFilesInFolderMathingVar, CMDoptionsDict)

			for dataClass in dataClasses: #For each class variable

				#Create summmary file
				if CMDoptionsDict['writeStepResultsToFileFlag']:
					# pdb.set_trace()
					fileOutComeSummaryForVarAndMag = open(os.path.join(CMDoptionsDict['stepsSummaryResultsFolder'], mag+'__'+var+'.csv'), 'w')
				else:
					fileOutComeSummaryForVarAndMag = []

				#Main inner loop
				print('\n'+'---> Importing data for variable: ' + dataClass.get_description() + ', '+mag+ ' values')
					
				for fileName in listOfFilesSortedInFolder: #For each file matching the criteria

					if dataClass.get_description() in fileName.split('__')[1] and fileName.split('__')[1] in dataClass.get_description(): #Restring to only file matching type of variable of class

						print('\n'+'-> Reading: ' + fileName)
						dataClass.importDataForClass(fileName, mag, CMDoptionsDict, fileOutComeSummaryForVarAndMag)

				#Here dataClass has collected the full data for a variable and magnitude
				
				#Clsoe  data summary to file
				if CMDoptionsDict['writeStepResultsToFileFlag']:
					fileOutComeSummaryForVarAndMag.close()
				
				#Time operations				
				if mag in ('hp', 'lp'):
					dataClass.getTimeList('rs')
				else:
					dataClass.getTimeList(mag)
				
				dataClass.reStartXvaluesAndLastID()

				if mag == 'rs' and False:

					newPicksMax, newPicksMean, newPicksMin, timePicks = dataClass.computePicks() ###STRANGE ERROR, PYTHON BUG?
					dataClass.updatePicksData(newPicksMax, newPicksMean, newPicksMin, timePicks)
		
		# Up to here all the data for a single variable has bee imported 

		# Plotting
		for dataClass in dataClasses: #For each class variable

			#Plotting max, min and mean from DIAdem
			# dataClass.plotMaxMinMean_fromDIAdem(plotSettings)

			#Plotting resampled total data
			if (CMDoptionsDict['showFigures'] or CMDoptionsDict['saveFigure']) and not CMDoptionsDict['additionalCalsFlag']:
				dataClass.plotResampled(plotSettings, CMDoptionsDict, mag, (False, [], []), inputDataClass)

			# dataClass.plotMinMeanMax(plotSettings)
			# pass

	# Additional calculations
	if CMDoptionsDict['additionalCalsFlag']:

		print('\n\n'+'-> Additional calculations in progress...')

		# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFighting', testFactor, orderDeriv)
		if CMDoptionsDict['additionalCalsOpt'] == 1:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFightingEyes(HP1-HP2)', testFactor, orderDeriv)
			dataAdditional.addDataManual1(dataClasses)
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, mag, (False, [], []))
		elif CMDoptionsDict['additionalCalsOpt'] == 2:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', testFactor, orderDeriv)
			dataAdditional.addDataManual2(dataClasses)
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, mag, (True, dataClasses, 'OutputForce'))
		elif CMDoptionsDict['additionalCalsOpt'] == 3:
			# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', testFactor, orderDeriv)
			# dataAdditional.addDataManual2(dataClasses)
			dataClass.plotResampled(plotSettings, CMDoptionsDict, mag, (True, dataClasses, ('BoosterLinklong','BoosterLinklat','BoosterLinkcol')), inputDataClass)

		elif CMDoptionsDict['additionalCalsOpt'] == 4:

			dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
			dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
			dataVolFlow1 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow1'][0]
			dataVolFlow2 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow2'][0]

			figure, axs = plt.subplots(2, 1)
			figure.set_size_inches(16, 10, forward=True)
			linestyleDict = {'3-SN002-1.3':'-',	'8-SN002-2.4':'-',	'10-SN0012-1.3':'-.',	'13-SN0012-2.4':'-.'}
			colorsDict = {'3-SN002-1.3':plotSettings['colors'][0],	'8-SN002-2.4':plotSettings['colors'][1],	'10-SN0012-1.3':plotSettings['colors'][2],	'13-SN0012-2.4':plotSettings['colors'][3]}
			labelsDict = {'3-SN002-1.3':'Old housing/Counterforce ON',	'8-SN002-2.4':'Old housing/Counterforce OFF',	'10-SN0012-1.3':'New housing/Counterforce ON',	'13-SN0012-2.4':'New housing/Counterforce OFF'}
			titlesDict = {0 : 'System 1', 1: 'System 2'}
			i=0
			for dataTemp,dataVolFlow in zip([dataTemp1,dataTemp2],[dataVolFlow1,dataVolFlow2]):
				assert dataVolFlow.get_stepID() == dataTemp.get_stepID(), 'Error'
				for j in range(len(dataVolFlow.get_stepID())):
					axs[i].plot( dataTemp.get_rs_split()[j], dataVolFlow.get_rs_split()[j], linestyle = linestyleDict[dataVolFlow.get_stepID()[j]], marker = '', c = colorsDict[dataVolFlow.get_stepID()[j]], label = labelsDict[dataVolFlow.get_stepID()[j]], **plotSettings['line'])
				axs[i].set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow.get_description()]['y-label'], **plotSettings['axes_y'])
				axs[i].set_title(titlesDict[i], **plotSettings['title'])
				axs[i].legend(**plotSettings['legend'])
				usualSettingsAX(axs[i], plotSettings)
				i+=1
			axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[dataTemp.get_description()]['y-label'], **plotSettings['axes_x'])

	os.chdir(cwd)

#Import data from actuator
elif actuatorFlag:

	# Import plot settings
	plotSettings = importPlottingOptions()

	print('\n'+'**** Running data analysis program for actuator measurements'+'\n')
	inputDataClass = loadFileAddressesAndData(CMDoptionsDict['fileNameOfFileToLoadFiles'], 'actuator')

	dataFromRuns, previousNCycles, iFile = [], 0, 1

	for file in inputDataClass.getTupleFiles():

		if float(file.split('\\')[-1].split('_')[1]) in CMDoptionsDict['rangeFileIDs']:

			print('-> Reading: ' + file.split('\\')[-1])
			dataFromRun_temp = importDataActuator(file, iFile, CMDoptionsDict, inputDataClass)

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
	# dataFromRuns[0].plotSingleRun(plotSettings)
	# dataFromRuns[-1].plotSingleRun(plotSettings)

	plotAllRuns_force(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass)
	plotAllRuns_displacement(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass)

elif actuatorMesswerteFlag:

	# Import plot settings
	plotSettings = importPlottingOptions()

	print('\n'+'**** Running data analysis program for actuator measurements, all data'+'\n')
	inputDataClass = loadFileAddressesAndData(CMDoptionsDict['fileNameOfFileToLoadFiles'], 'actuatorMesswerte')

	dataFromRuns, iFile, lastDataPointCounter, lastTimeList, totalTime = [], 1, 0, [], []

	for file in inputDataClass.getTupleFiles():

		if float(file.split('\\')[-1].split('_')[1]) in CMDoptionsDict['rangeFileIDs']: #Filter out test steps that are not specified 

			print('-> Reading: ' + file.split('\\')[-1])
			dataFromRun_temp = importDataActuator(file, iFile, CMDoptionsDict, inputDataClass)

			lastDataPointCounter += dataFromRun_temp.get_lastDataPointCounter()
			
			if not lastTimeList: #If list is empty
				lastTimeList += [dataFromRun_temp.get_time()[-1]]
			else:
				lastTimeList += [lastTimeList[-1]+dataFromRun_temp.get_time()[-1]]

			print('\t'+'-> Last computed data point index (accumulated): ' + str(int(lastDataPointCounter)/1000000.0) + ' millions')

			dataFromRuns += [dataFromRun_temp]

			iFile += 1

	timesDict = {'lastTimeList': lastTimeList}

	# plotAllRuns_force_Messwerte(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass)
	plotAllRuns_filtered_Messwerte(dataFromRuns, timesDict, plotSettings, CMDoptionsDict, inputDataClass)


plt.show(block = CMDoptionsDict['showFigures'])