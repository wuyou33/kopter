import os
import time
import sys
import pdb #pdb.set_trace()
import getopt
import numpy as np
import matplotlib.pyplot as plt

from moduleFunctions import *

# Script description

# The purpose is to get the frequency response of the actuator.
# Input: Pilot stick 
# Output: Measured Piston displacement

# The measured values have their mean removed.

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

#Cavitation analysis
if CMDoptionsDict['cavitationFlag']:
	# Get picks and travel
	for var in [b for b in CMDoptionsDict['flightTestInfo']['varsToImport'].split(',') if 'sg__CopyYCNT_DST' in b]:

		varClass = varClassesDict[var]

		varClass.get_picks_and_travel(CMDoptionsDict)

		varClassesDict.update({var : varClass})

	for pressureVar in [b for b in CMDoptionsDict['flightTestInfo']['varsToImport'].split(',') if 'sg__CopyYHYD_PRS_' in b]:
		for distanceVar in [b for b in CMDoptionsDict['flightTestInfo']['varsToImport'].split(',') if 'sg__CopyYCNT_DST_BST_' in b]:
			inputVar = distanceVar.replace('CNT_DST_BST','CNT_DST')
			plot_fti_measurements_cavitation(inputVar, distanceVar, pressureVar, 'dif__'+distanceVar.split('__')[1], varClassesDict, plotSettings)

if CMDoptionsDict['FRF']:

	# CMD: dynamicActuatorScript.py -p frf -o t -f input_files_flightTestAnalysis\analysisActuatorCavitation_freq.txt

	for distanceVar in [b for b in CMDoptionsDict['flightTestInfo']['varsToImport'].split(',') if 'sg__CopyYCNT_DST_BST_' in b]:
		inputVar = distanceVar.replace('CNT_DST_BST','CNT_DST')

		input_in = np.hstack([np.vstack(varClassesDict[inputVar].data), np.vstack(varClassesDict[inputVar].time)]) #[%]
		output_in = np.hstack([np.vstack(varClassesDict[distanceVar].data), np.vstack(varClassesDict[distanceVar].time)]) #[mm]

		rangesDict = {	'x_frac' : [0.2, 0.3, 0.4, 0.5, 0.6, 0.7],
						'K': [21, 51, 81, 111, 141, 181],
						'window' : ['bartlett', 'hanning', 'hamming', 'blackman']}

		labelsDict = {'x_frac':'$x_{frac}$', 'K':'$N_{windows}$', 'window':'$type_{window}$'}

		for key in rangesDict.keys():

			# Nominal settings FRF function
			settingsDict_FRF ={'x_frac' : 0.5, 'K' : 111, 'window' : 'bartlett', 'correlationPlotsFlag' : False, 'additionalPlots' : False}
			
			figure, axs = plt.subplots(2, 1, sharex='col')
			figure.set_size_inches(14, 10, forward=True)
			figure.suptitle('Frequency response, effect of '+key, **plotSettings['figure_title'])

			n_plot = 0
			for currentValue in rangesDict[key]:
				settingsDict_FRF.update({key : currentValue})
				outputDict = FRF(input_in, output_in, settingsDict_FRF, plotSettings, CMDoptionsDict)

				axs[0].semilogx(outputDict['f'], outputDict['mod'], linestyle = '-', marker = '', c = plotSettings['colors'][n_plot], label = labelsDict[key]+'='+str(settingsDict_FRF[key]), **plotSettings['line'])
				axs[1].semilogx(outputDict['f'], outputDict['phi'], linestyle = '-', marker = '', c = plotSettings['colors'][n_plot], label = labelsDict[key]+'='+str(settingsDict_FRF[key]), **plotSettings['line'])

				n_plot+=1
			# Final settings plot:
			for lim in [float(p) for p in CMDoptionsDict['flightTestInfo']['inputFreqsMinMax'].split(',')]:
				axs[0].semilogx(2*[lim], [max(outputDict['mod']), min(outputDict['mod'])], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
				axs[1].semilogx(2*[lim], [max(outputDict['phi']), min(outputDict['phi'])], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

			axs[0].legend(**plotSettings['legend'])
			axs[1].legend(**plotSettings['legend'])

			axs[0].set_ylabel('|H| [dB]', **plotSettings['axes_y'])
			axs[1].set_ylabel('$\\varphi$ [deg]', **plotSettings['axes_y'])
			
			axs[-1].set_xlabel('Frequency [Hz]', **plotSettings['axes_x'])

			for ax in axs:
				usualSettingsAX(ax, plotSettings)

plt.show(block = True)