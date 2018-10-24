import os
import sys
import pdb #pdb.set_trace()
import getopt
import shutil
from scipy import interpolate
import numpy as np #pdb.set_trace()

from moduleFunctions import *
from moduleAdditionalFunctions import *

print('\n\tKOPTER PYTHON DATA ANALYSIS TOOL')
print('\n\t\t-> developed by Alejandro Valverde Lopez')

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
	print('\n'+'**** Running general data script'+'\n')

	testFactor = 1.0 #HZ
	orderDeriv = 2	
	# Import settings
	plotSettings = importPlottingOptions()
	dataClasses = ()
	for magComplex in CMDoptionsDict['magnitudes']:

		# Mag operations
		mag = magComplex[:2]
		if magComplex[2:]:
			additionalMag = magComplex[2:]
		inputDataClass = loadFileAddressesAndData(CMDoptionsDict['fileNameOfFileToLoadFiles'], 'gauges')

		listOfFilesSortedInFolder = []
		for folderName in inputDataClass.getTupleFiles(): #For each folder with min, max or mean values
			listOfFilesInFolderMathingVar = []

			for fileName2 in os.listdir(folderName):
				if fileName2.endswith('.csv'): #Take only .csv files
					if magComplex[2:]:
						if fileName2.startswith(mag) and fileName2.split('.csv')[0].split('__')[-1] in CMDoptionsDict['rangeFileIDs'] and fileName2.split('__')[-2][:-2] == additionalMag:
							listOfFilesInFolderMathingVar += [fileName2]
					else:
						if fileName2.startswith(mag) and fileName2.split('.csv')[0].split('__')[-1] in CMDoptionsDict['rangeFileIDs']:
							listOfFilesInFolderMathingVar += [fileName2]

			listOfFilesSortedInFolder += sortFilesInFolderByLastNumberInName(listOfFilesInFolderMathingVar, folderName, CMDoptionsDict)

		# Create dataClasses
		listOfFilesMatchingMag = [t[1] for t in listOfFilesSortedInFolder]
		listOfMagVarPairs = [t.split('__')[0]+'__'+t.split('__')[1] for t in listOfFilesMatchingMag]
		for var in CMDoptionsDict['variables']:
			if mag+'__'+var in listOfMagVarPairs:
				dataVar = dataFromGaugesSingleMagnitudeClass(var, mag, testFactor, orderDeriv)
				dataClasses += (dataVar, )
		
		# pdb.set_trace()
		for dataClass in dataClasses: #For each class variable

			if dataClass.get_mag() == mag: #Only to dataClass with the current mag


				# mag = dataClass.get_mag()

				#Create summmary file
				if CMDoptionsDict['writeStepResultsToFileFlag']:
					# pdb.set_trace()
					fileOutComeSummaryForVarAndMag = open(os.path.join(CMDoptionsDict['stepsSummaryResultsFolder'], dataClass.get_mag()+'__'+dataClass.get_description()+'.csv'), 'w')
					fileOutComeSummaryForVarAndMag.write(','.join(['step ID', 'max', 'min', 'mean']) + '\n') 
				else:
					fileOutComeSummaryForVarAndMag = []

				#Main inner loop
				print('\n'+'---> Importing data for variable: ' + dataClass.get_description() + ', '+dataClass.get_mag()+ ' values')
					
				for fileNameList in listOfFilesSortedInFolder: #For each file matching the criteria

					shortFileName = fileNameList[1]
					longFileName = os.path.join(fileNameList[0], fileNameList[1])
					if dataClass.get_description() in shortFileName.split('__')[1] and shortFileName.split('__')[1] in dataClass.get_description(): #Restring to only file matching type of variable of class
						print('\n'+'-> Reading: ' + shortFileName)
						dataClass.importDataForClass(shortFileName, longFileName, dataClass.get_mag(), CMDoptionsDict, fileOutComeSummaryForVarAndMag)

				#Here dataClass has collected the full data for a variable and magnitude

				#Close data summary to file
				if CMDoptionsDict['writeStepResultsToFileFlag']:
					fileOutComeSummaryForVarAndMag.close()
				
				#Time operations				
				if dataClass.get_mag() in ('hp', 'lp', 'di'):
					dataClass.getTimeList('rs')
				else:
					dataClass.getTimeList(dataClass.get_mag())
				
				dataClass.reStartXvaluesAndLastID()

				if dataClass.get_mag() == 'rs' and False:

					newPicksMax, newPicksMean, newPicksMin, timePicks = dataClass.computePicks() ###STRANGE ERROR, PYTHON BUG?
					dataClass.updatePicksData(newPicksMax, newPicksMean, newPicksMin, timePicks)
		
		# Up to here all the data for a single variable has bee imported 

	# Plotting
	for dataClass in dataClasses: #For each class variable

		#Plotting max, min and mean from DIAdem
		# dataClass.plotMaxMinMean_fromDIAdem(plotSettings)

		#Plotting resampled total data
		if (CMDoptionsDict['showFigures'] or CMDoptionsDict['saveFigure']) and not CMDoptionsDict['additionalCalsFlag']:
			dataClass.plotResampled(plotSettings, CMDoptionsDict, dataClass.get_mag(), (False, [], []), inputDataClass)

	# Additional calculations
	if CMDoptionsDict['additionalCalsFlag']:

		print('\n\n'+'-> Additional calculations in progress...')

		# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFighting', testFactor, orderDeriv)
		if CMDoptionsDict['additionalCalsOpt'] == 1:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFightingEyes(HP1-HP2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual1(dataClasses)
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (False, [], []), inputDataClass)
		elif CMDoptionsDict['additionalCalsOpt'] == 2:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual2(dataClasses)
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, 'OutputForce'), inputDataClass)
		elif CMDoptionsDict['additionalCalsOpt'] == 3:
			# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', 'rs', testFactor, orderDeriv)
			# dataAdditional.addDataManual2(dataClasses)
			dataClass.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, ('BoosterLinklong','BoosterLinklat','BoosterLinkcol')), inputDataClass)

		elif CMDoptionsDict['additionalCalsOpt'] == 4:

			# Show relationship between internal leakage and tempertature

			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 4 -c f -n t -r 3-SN002-1.3,8-SN002-2.4,10-SN0012-1.3,13-SN0012-2.4,3-Step-1.3,7-Step-2.4 -w t -l f
			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 4 -c f -n t -r 7-Step-2.4 -w t -l f

			internalLeakageVSTemp_regression(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 5:
			# Plot flow rate versus force
			# Test 2.4 contains the relationship between temperature and volume flow for zero force
			# Remove contribution from the temperature to the volume flow shown in test 1.3

			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2,OutputForce -m rs -o f -s f,t -a 5 -c f -n t -r 3-SN002-1.3,8-SN002-2.4,10-SN0012-1.3,13-SN0012-2.4,7-Step-2.4,1-Step-1.1,3-Step-1.3 -w f

			internalLeakageVSForce_regression(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 6:
			# Plot flow rate versus temperature for various operating pressures
			# Include P2 flight test summary information information

			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 6 -c f -n t -w f -l t -r 6-Step-1.6,4-SN002-1.6,8-SN002-2.4,7-Step-2.4,3-Step-1.3,3-SN002-1.3

			internalLeakageVSTempVSPress_withP2ref(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 7:
			# Plot flow rate versus temperature using segments of data
			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v VolFlow1,VolFlow2,Temp1,Temp2 -m rs -o f -s f,t -c f -n t -w f -l t -r 3-SN002-1.3,10-SN0012-1.3,8-SN002-2.4,13-SN0012-2.4 -a 7

			internalLeakageVSTemp_segments(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 8:

			# Estimate the volume flow considering the piston demand 
			# For this, piston velocities are extracted from P2 flights recorded data
			# python main.py -f filesToLoad_gauges_P2_FTI_100Hz.txt -v CNT_DST_BST_COL,CNT_DST_BST_LNG,CNT_DST_BST_LAT -m di -o f -s f,t -a 8 -c f -n f -w f -l t -r 192-FT0106

			internalLeakageDueToPistonDemand_P2flights(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 9:

			# Big code to estimate the internal leakage for an instrumented flight. The internal leakege is calculated as:

			# q_total = q_v + q_T,P + q_F
			# 	q_v = v * A -> Contribution of the piston demand
			# 	q_T,P -> Contribution of the fluid temperature
			#		--> Data is interpolated used component testing data for a given pressure
			#	q_F -> Contribution of the force
			#		--> Data is interpolated from component testing data

			# python main.py -f filesToLoad_gauges_P2_FTI_100Hz.txt -v CNT_DST_BST_COL,CNT_FRC_BST_COL,CNT_DST_BST_LNG,CNT_FRC_BST_LNG,CNT_DST_BST_LAT,CNT_FRC_BST_LAT,HYD_ARI_MFD_TMP_1,HYD_ARI_MFD_TMP_2 -m rs,di -o f -s t,t -a 9 -c f -n t -l f -w f -r 192-FT0106

			calculateFlowFlight(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

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

		if int(file.split('\\')[-1].split('_')[1]) in [int(o) for o in CMDoptionsDict['rangeFileIDs']]: #Filter out test steps that are not specified 

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
	# plotAllRuns_filtered_Messwerte(dataFromRuns, timesDict, plotSettings, CMDoptionsDict, inputDataClass)
	plotStiffnessForChoosenSteps_Messwerte(dataFromRuns, timesDict, plotSettings, CMDoptionsDict, inputDataClass)


plt.show(block = CMDoptionsDict['showFigures'])