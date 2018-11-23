##################################################
## Python&DIAdem Kopter Data Analysis Tool
##################################################
## This script is a python script used t
##################################################
## Author: Alejandro Valverde Lopez
## Copyright: Kopter Groupd AG
## License: GNU
## Version: 1
## Maintainer: Alejandro Valverde Lopez
## Email: Alejandro.Valverde@koptergroup.com
## Status: Under develop
##################################################

import os
import sys
# import pdb #pdb.set_trace()
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
# python main.py -f filesToLoad_actuator_outerBeearing.txt -o -2.1,2.1 -s t
# 
# gauges:
# python main.py -f filesToLoad_general_enduranceActuatorNewBearing.txt -v DruckHP1,DruckHP2,DurchflussHP1,DurchflussHP2,ForcePistonEyeHP1,ForcePistonEyeHP2,InputForce,LaserPiston,LaserSteuerventilhebel,OutputForce,TemperaturHP1,TemperaturHP2 -m lp -o f -s t,t -r 1,2,3,4,5,6,7,8,9 -a t
# python main.py -f filesToLoad_general_TRbladeholder.txt -v BendingMoment,MyBlade,MyLoadcell,MzBlade,CF -m rs -o f -s t,t -a f -r 11,12,13,14,15
# python main.py -f filesToLoad_general_OC.txt -v Tension,Bending -m rs -o t -s t,t -a f -r 1,2,3,4,5,6

# Dicitionary of loading options
CMDoptionsDict = {}

#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptionsMainAbaqusParametric(sys.argv[1:], CMDoptionsDict)

showInputOptions(CMDoptionsDict)

#Write output data
if CMDoptionsDict['writeStepResultsToFileFlag'] or CMDoptionsDict['additionalCalsOpt'] == 15:
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
	print()

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

	# Errors check
	# Analyse results until here and raise exceptions, if any
	checkErrors(dataClasses, CMDoptionsDict, inputDataClass)

	# Plotting
	if not CMDoptionsDict['additionalCalsFlag']:

		
		# Check if 
		exampleClasse = dataClasses[0]
		exampleLabel = inputDataClass.get_variablesInfoDict()[exampleClasse.get_mag()+'__'+exampleClasse.get_description()]['y-label']
		flagAllTheVariablesTheSameLabel = all([inputDataClass.get_variablesInfoDict()[t.get_mag()+'__'+t.get_description()]['y-label'] == exampleLabel for t in dataClasses])
		
		if CMDoptionsDict['multipleYaxisInSameFigure']:

			
			if not flagAllTheVariablesTheSameLabel or CMDoptionsDict['axisArrangementOption'] == '2':
				for dataClass in dataClasses: #For each class variable
					#Plotting resampled total data
					if (CMDoptionsDict['showFigures'] or CMDoptionsDict['saveFigure']):
						dataClass.plotResampled(plotSettings, CMDoptionsDict, dataClass.get_mag(), (False, [], []), inputDataClass)
			else:

				CMDoptionsDict['multipleYaxisInSameFigure'] = False

				exampleClasse = dataClasses[0]
				exampleClasse.plotResampled(plotSettings, CMDoptionsDict, exampleClasse.get_mag(), (True, dataClasses, CMDoptionsDict['variables']), inputDataClass)

		elif CMDoptionsDict['oneVariableInEachAxis']:

			exampleClasse = dataClasses[0]

			exampleClasse.plotOneVariableAgainstOther(plotSettings, CMDoptionsDict, inputDataClass, dataClasses)

		else:

			for dataClass in dataClasses: #For each class variable
				#Plotting resampled total data
				if (CMDoptionsDict['showFigures'] or CMDoptionsDict['saveFigure']):
					dataClass.plotResampled(plotSettings, CMDoptionsDict, dataClass.get_mag(), (False, [], []), inputDataClass)

	# Additional calculations
	if CMDoptionsDict['additionalCalsFlag']:

		print('\n\n'+'-> Additional calculations in progress...')

		# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFighting', testFactor, orderDeriv)
		if CMDoptionsDict['additionalCalsOpt'] == 1:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFightingEyes(HP1-HP2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual1(dataClasses, 'ForceEye1', 'ForceEye2', inputDataClass)
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (False, [], []), inputDataClass)

		elif CMDoptionsDict['additionalCalsOpt'] == 1.5:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFightingEyes(HP1-HP2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual1(dataClasses, 'ForceEye1', 'ForceEye2', inputDataClass)
			dataClasses += (dataAdditional, )
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, ('forceFightingEyes(HP1-HP2)','ForceEye1','ForceEye2','PistonDispl')), inputDataClass)
		elif CMDoptionsDict['additionalCalsOpt'] == 2:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual2(dataClasses)
			dataClasses += (dataAdditional, )
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, ('forceSumEyes(HP1+HP2)', 'OutputForce')), inputDataClass)
		elif CMDoptionsDict['additionalCalsOpt'] == 3:
			# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', 'rs', testFactor, orderDeriv)
			# dataAdditional.addDataManual2(dataClasses)
			dataClass.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, ('BoosterLinklong','BoosterLinklat','BoosterLinkcol')), inputDataClass)

		elif CMDoptionsDict['additionalCalsOpt'] == 4:

			# Show relationship between internal leakage and tempertature

			# python main.py -f filesToLoad_general_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 4 -c f -n t -r 3-SN002-1.3,8-SN002-2.4,10-SN0012-1.3,13-SN0012-2.4,3-Step-1.3,7-Step-2.4 -w t -l f
			# python main.py -f filesToLoad_general_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 4 -c f -n t -r 7-Step-2.4 -w t -l f

			internalLeakageVSTemp_regression(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 5:
			# Plot flow rate versus force
			# Test 2.4 contains the relationship between temperature and volume flow for zero force
			# Remove contribution from the temperature to the volume flow shown in test 1.3

			# python main.py -f filesToLoad_general_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2,OutputForce -m rs -o f -s f,t -a 5 -c f -n t -r 3-SN002-1.3,8-SN002-2.4,10-SN0012-1.3,13-SN0012-2.4,7-Step-2.4,1-Step-1.1,3-Step-1.3 -w f

			internalLeakageVSForce_regression(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 6:
			# Plot flow rate versus temperature for various operating pressures
			# Include P2 flight test summary information information

			# python main.py -f filesToLoad_general_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 6 -c f -n t -w f -l t -r 6-Step-1.6,4-SN002-1.6,8-SN002-2.4,7-Step-2.4,3-Step-1.3,3-SN002-1.3

			internalLeakageVSTempVSPress_withP2ref(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 7:
			# Plot flow rate versus temperature using segments of data
			# python main.py -f filesToLoad_general_actuatorPerformance.txt -v VolFlow1,VolFlow2,Temp1,Temp2 -m rs -o f -s f,t -c f -n t -w f -l t -r 3-SN002-1.3,10-SN0012-1.3,8-SN002-2.4,13-SN0012-2.4 -a 7

			internalLeakageVSTemp_segments(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 8:

			# Estimate the volume flow considering the piston demand 
			# For this, piston velocities are extracted from P2 flights recorded data
			# python main.py -f filesToLoad_general_P2_FTI_100Hz.txt -v CNT_DST_BST_COL,CNT_DST_BST_LNG,CNT_DST_BST_LAT -m di -o f -s f,t -a 8 -c f -n f -w f -l t -r 192-FT0106

			internalLeakageDueToPistonDemand_P2flights(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 9:

			# Big code to estimate the internal leakage for an instrumented flight. The internal leakege is calculated as:

			# q_total = q_v + q_T,P + q_F
			# 	q_v = v * A -> Contribution of the piston demand
			# 	q_T,P -> Contribution of the fluid temperature
			#		--> Data is interpolated used component testing data for a given pressure
			#	q_F -> Contribution of the force
			#		--> Data is interpolated from component testing data

			# python main.py -f filesToLoad_general_P2_FTI_100Hz.txt -v CNT_DST_BST_COL,CNT_FRC_BST_COL,CNT_DST_BST_LNG,CNT_FRC_BST_LNG,CNT_DST_BST_LAT,CNT_FRC_BST_LAT,HYD_ARI_MFD_TMP_1,HYD_ARI_MFD_TMP_2 -m rs,di -o f -s t,t -a 9 -c f -n t -l f -w f -r 192-FT0106

			calculateFlowFlight(dataClasses, inputDataClass, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 10:

			# Get information for HYD test during FT04, relevant for test report
			# python main.py -f filesToLoad_general_P3_FTI.txt -m rs,di -o f -s t,f -a 10 -c f -w f -l f -r 13-FT04 -v HYD_TMP_TANK_1,HYD_TMP_TANK_2,HYD_PRS_1,HYD_PRS_2,IND_PRS_1,IND_PRS_2,CNT_DST_COL,CNT_DST_LAT,CNT_DST_LNG,CNT_DST_BST_COL,CNT_DST_BST_LAT,CNT_DST_BST_LNG -n t 

			calculateSegmentsForHYDtestFT04(dataClasses, plotSettings, CMDoptionsDict)

		elif CMDoptionsDict['additionalCalsOpt'] == 11:
			"""
			Apply corrections to measured distances

			CMD: python main.py -f filesToLoad_general_P3_FTI.txt -m rs -o f -s f,t -a 11 -c f -w f -l t -r 1-RC,2-RC,...,96-FT24,97-FT24 -v CNT_DST_COL,CNT_DST_LAT,CNT_DST_LNG,CNT_DST_BST_COL,CNT_DST_BST_LAT,CNT_DST_BST_LNG -n t
			"""
			# Header operations
			# Range files
			if len(CMDoptionsDict['rangeFileIDs']) < 8:
				rangeIDstring = ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])
			else:
				rangeIDstring = str(CMDoptionsDict['rangeFileIDs'][0])+'...'+str(CMDoptionsDict['rangeFileIDs'][-1])

			colorDict = {'COL' : plotSettings['colors'][0], 'LNG' : plotSettings['colors'][1], 'LAT' : plotSettings['colors'][2]}
			# ###################

			# Corrections
			for dof in ('COL', 'LNG', 'LAT'):

				data_temp = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_BST_'+dof][0]
				data_temp.addDataManual6(float(inputDataClass.get_variablesInfoDict()['testData']['corr_'+dof]))
				data_temp.addDataManual7() #Calculate increment vector

				data_temp = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_'+dof][0]
				data_temp.addDataManual7() #Calculate increment vector
				
			# Display normal data
			for dataClass in dataClasses: #For each class variable
				dataClass.plotResampled(plotSettings, CMDoptionsDict, dataClass.get_mag(), (False, [], []), inputDataClass)
			# ###################

			figure, ax = plt.subplots(1, 1, sharex='col')
			figure.set_size_inches(16, 10, forward=True)
			figure.suptitle('Ratio $\\phi_{\\mathrm{out}/\\mathrm{in}}$ between change in pilot input $\\theta_{\\mathrm{in}}$ and increment in booster displacement $\\theta_{\\mathrm{out}}$\n$\\phi_{\\mathrm{out}/\\mathrm{in}}$ = $\\Delta \\theta_{\\mathrm{out}}$ / $\\Delta \\theta_{\\mathrm{in}}$\nDataset: '+rangeIDstring, **plotSettings['figure_title'])

			for dof in ('COL', 'LNG', 'LAT'):

				data_input_temp = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_'+dof][0]
				data_boost_temp = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_BST_'+dof][0]

				input_temp, ratio_temp = [], []
				for out,inp in zip(data_boost_temp.rs_increments, data_input_temp.rs_increments):
					if abs(inp) > 1:
						input_temp += [inp]
						ratio_temp += [out / inp] 
				ax.plot( input_temp, ratio_temp, linestyle = '', marker = 'o', c = colorDict[dof], label = dof, **plotSettings['line'])

			ax.set_ylabel('Ratio $\\phi_{\\mathrm{out}/\\mathrm{in}}$ [mm/%]', **plotSettings['axes_y'])
			ax.set_xlabel('$\\Delta \\theta_{\mathrm{in}}$ [%]', **plotSettings['axes_x'])

			ax.legend(**plotSettings['legend'])
			usualSettingsAX(ax, plotSettings)

		elif CMDoptionsDict['additionalCalsOpt'] in (12, 13, 14):

			# Extract di
			segsDict = {}
			for stepID in CMDoptionsDict['rangeFileIDs']:

				segsDict[stepID] = [float(t) for t in inputDataClass.get_variablesInfoDict()['testData']['segment__'+stepID].split(',')]

			if CMDoptionsDict['additionalCalsOpt'] == 12:
				"""
				Plot the relation between the internal leakage and the temperature, considering a segmented data set

				python main.py -f filesToLoad_general_actuatorPerformance.txt -m rs -o f -s f,t -a 12 -c f -w f -l t -r 15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,39-Step-3.1-50FH-col,40-Step-3.1-50FH-hot -v Temp1,Temp2,VolFlow1,VolFlow2 -n f
				python main.py -f filesToLoad_general_actuatorPerformance.txt -m rs -o f -s t,t -a 12 -c f -w f -l t -r 27-Step-3.2-hot,28-Step-3.2-cold,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot -v Temp1,Temp2,VolFlow1,VolFlow2 -n f
				"""
				# Data Classes
				dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
				dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
				dataVolFlow1 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow1'][0]
				dataVolFlow2 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow2'][0]			

				#Vector of steps
				indexDictForSteps, stepStrs = get_indexDictForSteps(dataTemp1)

				# Figure initialization 
				figure, axs = plt.subplots(2, 1, sharex='col')
				figure.set_size_inches(16, 10, forward=True)
				figure.suptitle('Temp ', **plotSettings['figure_title'])

				plotsDone = 0
				for stepName in stepStrs:
					# axs[0].plot( dataTemp1.get_rs_split()[indexDictForSteps[stepName]], dataVolFlow1.get_rs_split()[indexDictForSteps[stepName]], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					# axs[1].plot( dataTemp2.get_rs_split()[indexDictForSteps[stepName]], dataVolFlow2.get_rs_split()[indexDictForSteps[stepName]], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					axs[0].plot( createSegmentsOf_rs_FromVariableClass(dataTemp1, segsDict[stepName], indexDictForSteps[stepName])[0], createSegmentsOf_rs_FromVariableClass(dataVolFlow1, segsDict[stepName], indexDictForSteps[stepName])[0], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					axs[1].plot( createSegmentsOf_rs_FromVariableClass(dataTemp2, segsDict[stepName], indexDictForSteps[stepName])[0], createSegmentsOf_rs_FromVariableClass(dataVolFlow2, segsDict[stepName], indexDictForSteps[stepName])[0], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					plotsDone += 1

				axs[0].set_title('SYS 1', **plotSettings['ax_title'])
				axs[1].set_title('SYS 2', **plotSettings['ax_title'])
				axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[dataTemp1.get_mag()+'__'+dataTemp1.get_description()]['y-label'], **plotSettings['axes_x'])
				for ax in axs:
					ax.set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow1.get_mag()+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
					ax.legend(**plotSettings['legend'])
					usualSettingsAX(ax, plotSettings)

			elif CMDoptionsDict['additionalCalsOpt'] == 13:
				"""
				Plot the relation 
				python main.py -f filesToLoad_general_actuatorPerformance.txt -m rs -o f -s t,t -a 13 -c f -w f -l t -r 27-Step-3.2-hot,28-Step-3.2-cold,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot-1 -v Temp1,Temp2,Pres1,Pres2 -n f
				"""
				# Data Classes
				dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
				dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
				dataPres1 = [temp for temp in dataClasses if temp.get_description() == 'Pres1'][0]
				dataPres2 = [temp for temp in dataClasses if temp.get_description() == 'Pres2'][0]			

				#Vector of steps
				indexDictForSteps, stepStrs = get_indexDictForSteps(dataTemp1)
				
				# Figure initialization 
				figure, axs = plt.subplots(2, 1, sharex='col', sharey='col')
				figure.set_size_inches(16, 10, forward=True)
				figure.suptitle('Temp ', **plotSettings['figure_title'])

				plotsDone = 0
				for stepName in stepStrs:
					# axs[0].plot( dataTemp1.get_rs_split()[indexDictForSteps[stepName]], dataPistonDispl.get_rs_split()[indexDictForSteps[stepName]], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					axs[0].plot( createSegmentsOf_rs_FromVariableClass(dataTemp1, segsDict[stepName], indexDictForSteps[stepName])[0], createSegmentsOf_rs_FromVariableClass(dataPres1, segsDict[stepName], indexDictForSteps[stepName])[0], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					axs[1].plot( createSegmentsOf_rs_FromVariableClass(dataTemp2, segsDict[stepName], indexDictForSteps[stepName])[0], createSegmentsOf_rs_FromVariableClass(dataPres2, segsDict[stepName], indexDictForSteps[stepName])[0], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					plotsDone += 1

				axs[0].set_title('SYS 1', **plotSettings['ax_title'])
				axs[1].set_title('SYS 2', **plotSettings['ax_title'])
				axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[dataTemp1.get_mag()+'__'+dataTemp1.get_description()]['y-label'], **plotSettings['axes_x'])
				for ax in axs:
					ax.set_ylabel(inputDataClass.get_variablesInfoDict()[dataPres1.get_mag()+'__'+dataPres1.get_description()]['y-label'], **plotSettings['axes_y'])
					ax.legend(**plotSettings['legend'])
					usualSettingsAX(ax, plotSettings)

			elif CMDoptionsDict['additionalCalsOpt'] == 14:
				"""
				Plot the relation 
				python main.py -f filesToLoad_general_actuatorPerformance.txt -m rs -o f -s t,t -a 14 -c f -w f -l t -r 27-Step-3.2-hot,28-Step-3.2-cold,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot-1 -v Temp1,Temp2,PistonDispl -n f
				"""
				# Data Classes
				dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
				dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
				dataPistonDispl = [temp for temp in dataClasses if temp.get_description() == 'PistonDispl'][0]
				# dataPres2 = [temp for temp in dataClasses if temp.get_description() == 'Pres2'][0]			

				#Vector of steps
				indexDictForSteps, stepStrs = get_indexDictForSteps(dataTemp1)

				# Figure initialization 
				figure, axs = plt.subplots(2, 1, sharex='col', sharey='col')
				figure.set_size_inches(16, 10, forward=True)
				figure.suptitle('Temp ', **plotSettings['figure_title'])

				plotsDone = 0
				for stepName in stepStrs:
					axs[0].plot( createSegmentsOf_rs_FromVariableClass(dataTemp1, segsDict[stepName], indexDictForSteps[stepName])[0], createSegmentsOf_rs_FromVariableClass(dataPistonDispl, segsDict[stepName], indexDictForSteps[stepName])[0], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					axs[1].plot( createSegmentsOf_rs_FromVariableClass(dataTemp2, segsDict[stepName], indexDictForSteps[stepName])[0], createSegmentsOf_rs_FromVariableClass(dataPistonDispl, segsDict[stepName], indexDictForSteps[stepName])[0], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
					plotsDone += 1

				axs[0].set_title('SYS 1', **plotSettings['ax_title'])
				axs[1].set_title('SYS 2', **plotSettings['ax_title'])
				axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[dataTemp1.get_mag()+'__'+dataTemp1.get_description()]['y-label'], **plotSettings['axes_x'])
				for ax in axs:
					ax.set_ylabel(inputDataClass.get_variablesInfoDict()[dataPistonDispl.get_mag()+'__'+dataPistonDispl.get_description()]['y-label'], **plotSettings['axes_y'])
					ax.legend(**plotSettings['legend'])
					usualSettingsAX(ax, plotSettings)

		elif CMDoptionsDict['additionalCalsOpt'] == 15:
			"""
			Calculations for Christian, obtain temperatures
			CMD: python main.py -f filesToLoad_general_P3_FTI.txt -m rs -s f,t -a 15 -v HYD_PRS_1,HYD_PRS_2,HYD_TMP_TANK_1,HYD_TMP_TANK_2,DIU_ARI_IND_HYD_PRS_1_C,DIU_ARI_IND_HYD_PRS_2_C,PFD_ARI_TMP_OAT -r 100-FT01
			"""

			# Write header row to file
			#I/O with files
			file = open(os.path.join(CMDoptionsDict['stepsSummaryResultsFolder'], 'HYD_analysis.csv'), 'w')

			indexDictForSteps, stepStrs = get_indexDictForSteps(dataClasses[0])

			OAT_Class = [temp for temp in dataClasses if temp.get_description() == 'PFD_ARI_TMP_OAT'][0]
			
			header = ['SYS', 'Time[s]', 'Type', 'HYD_TMP_TANK[degC]', 'HYD_PRS[bar]', 'OAT[degC]', 'TimeToDown[s]']
			file.write(';'.join(header)+'\n')
			for stepStr in stepStrs:
				file.write(stepStr+'\n')

				for sysID in ('1', '2'):

					figure, axs = plt.subplots(4, 1, sharex='col')
					figure.set_size_inches(16, 10, forward=True)
					figure.suptitle(stepStr + ' / SYS '+sysID, **plotSettings['figure_title'])


					HYD_IND_Class = [temp for temp in dataClasses if temp.get_description() == 'DIU_ARI_IND_HYD_PRS_'+sysID+'_C'][0]
					HYD_TMP_Class = [temp for temp in dataClasses if temp.get_description() == 'HYD_TMP_TANK_'+sysID][0]
					HYD_PRS_Class = [temp for temp in dataClasses if temp.get_description() == 'HYD_PRS_'+sysID][0]

					for ax, class_current in zip(axs, [OAT_Class, HYD_TMP_Class, HYD_PRS_Class, HYD_IND_Class]):
						ax.plot( get_timeVectorClass(class_current, indexDictForSteps[stepStr]), class_current.get_rs_split()[indexDictForSteps[stepStr]], linestyle = '-', marker = 'o', c = 'k', label = class_current.get_description(), **plotSettings['line'])
						ax.set_ylabel(inputDataClass.get_variablesInfoDict()[class_current.get_mag()+'__'+class_current.get_description()]['y-label'], **plotSettings['axes_y'])

					timeSegment = get_timeVectorClass(HYD_IND_Class, indexDictForSteps[stepStr])
					dataSegment = HYD_IND_Class.get_rs_split()[indexDictForSteps[stepStr]]

					assert len(timeSegment) == len(dataSegment)

					i = 1
					timesOff = []
					for point in dataSegment[1:]:

						incrementBinary = point - dataSegment[i-1]

						if incrementBinary != 0:
							temp_sys_singlePoint = createSegmentsOf_rs_FromVariableClass(HYD_TMP_Class, timeSegment[i-1], indexDictForSteps[stepStr])[0]
							prs_sys_singlePoint = createSegmentsOf_rs_FromVariableClass(HYD_PRS_Class, timeSegment[i-1], indexDictForSteps[stepStr])[0]
							oat_sys_singlePoint = createSegmentsOf_rs_FromVariableClass(OAT_Class, timeSegment[i-1], indexDictForSteps[stepStr])[0]
							
							if incrementBinary == 1:
								# Switch went from 0 to 1
								type_detected = 'Switch-ON'
								for ax in axs:
									ax.plot(2*[timeSegment[i-1]], [ax.get_ylim()[0], ax.get_ylim()[1]], linestyle = '--', marker = '', c = 'g', scalex = False, scaley = False, **plotSettings['line'])

								pressureRangeUp, timeRangeUp = createSegmentsOf_rs_FromVariableClass(HYD_PRS_Class, [timeSegment[i-1]-1, timeSegment[i-1]+2], indexDictForSteps[stepStr])
								pressureRangeDown, timeRangeDown = createSegmentsOf_rs_FromVariableClass(HYD_PRS_Class, [timeSegment[i-1], timeSegment[-2]], indexDictForSteps[stepStr])
								time_up = None
								for press, time_current in zip(pressureRangeUp, timeRangeUp):
									if press < float(inputDataClass.get_variablesInfoDict()['testData']['threshold_press_up']):
										time_up = time_current
										break
								time_down = None
								for press, time_current in zip(pressureRangeDown, timeRangeDown):
									if press < float(inputDataClass.get_variablesInfoDict()['testData']['threshold_press_down']):
										time_down = time_current
										break
								try:
									time_to_down = time_down - time_up
								except TypeError as e:
									raise ValueError('Error for calculating point at '+str(timeSegment[i-1])+' seconds / SYS '+sysID)

							elif incrementBinary == -1:
								# Switch from 1 to 0
								type_detected = 'Switch-OFF'
								for ax in axs:
									ax.plot(2*[timeSegment[i-1]], [ax.get_ylim()[0], ax.get_ylim()[1]], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])
								time_to_down = ''

							# Output data
							output = [p if isinstance(p, str) else str(p) for p in [sysID, timeSegment[i-1], type_detected, temp_sys_singlePoint, prs_sys_singlePoint, oat_sys_singlePoint, time_to_down]]
							file.write(';'.join(output)+'\n')
						i+=1

					for ax in axs:
						ax.set_xlabel('Time elapsed', **plotSettings['axes_x'])
						ax.legend(**plotSettings['legend'])
						usualSettingsAX(ax, plotSettings)

					if CMDoptionsDict['saveFigure']:

						# Range files
						if len(CMDoptionsDict['rangeFileIDs']) < 8:
							rangeIDstring = ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])
						else:
							rangeIDstring = str(CMDoptionsDict['rangeFileIDs'][0])+'...'+str(CMDoptionsDict['rangeFileIDs'][-1])

						figure.savefig(os.path.join(CMDoptionsDict['cwd'], 'hyd_analysis__sys'+sysID+'__'+stepStr+'.png'), dpi = plotSettings['figure_settings']['dpi'])
			file.close()
		
		elif CMDoptionsDict['additionalCalsOpt'] == 16:
			"""
			Show force fighting for flight test.
			"""
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFighting_abs(1-2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual1(dataClasses, 'CNT_FRC_BST_TR_1', 'CNT_FRC_BST_TR_2', inputDataClass)
			dataClasses += (dataAdditional, )
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, CMDoptionsDict['variables']+['forceFighting_abs(1-2)']), inputDataClass)


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