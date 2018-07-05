import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import scipy.linalg as lalg
import statistics as stat
from scipy import signal
import math
import getopt
import pdb #pdb.set_trace()

def importPlottingOptions():
	#### PLOTTING OPTIONS ####

	#Plotting options
	axes_label_x  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	figure_text_title_properties = {'weight' : 'bold', 'size' : 14}
	ax_text_title_properties = {'weight' : 'regular', 'size' : 12}
	axes_ticks = {'labelsize' : 10}
	line = {'linewidth' : 1.5, 'markersize' : 2}
	scatter = {'linewidths' : 2}
	legend = {'fontsize' : 10, 'loc' : 'best'}
	grid = {'alpha' : 0.7}
	colors = ['k', 'b', 'y', 'm', 'r', 'c', 'g', 'k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c']
	markers = ['o', 'v', '^', 's', '*', '+']
	linestyles = ['-', '--', '-.', ':']
	axes_ticks_n = {'x_axis' : 3} #Number of minor labels in between 
	figure_settings = {'dpi' : 200}

	plotSettings = {'axes_x':axes_label_x,'axes_y':axes_label_y, 'figure_title':figure_text_title_properties, 'ax_title':ax_text_title_properties,
	                'axesTicks':axes_ticks, 'line':line, 'legend':legend, 'grid':grid, 'scatter':scatter,
	                'colors' : colors, 'markers' : markers, 'linestyles' : linestyles, 'axes_ticks_n' : axes_ticks_n,
	                'figure_settings' : figure_settings}

	return plotSettings

def readCMDoptionsMainAbaqusParametric(argv, CMDoptionsDict):

	short_opts = "v:" #"o:f:"
	long_opts = ["variables="] #["option=","fileName="]
	try:
		opts, args = getopt.getopt(argv,short_opts,long_opts)
	except getopt.GetoptError:
		raise ValueError('ERROR: Not correct input to script')

	# check input
	# if len(opts) != len(long_opts):
		# raise ValueError('ERROR: Invalid number of inputs')	

	for opt, arg in opts:

		if opt in ("-v", "--variables"):
			# postProcFolderName = arg

			CMDoptionsDict['variables'] = arg.split(',')

	return CMDoptionsDict

class testClassDef(object):
	"""docstring for testClass"""
	def __init__(self, name_in):
		# self.arg = arg
		self.name = name_in

	def includeTimeSegmentsFreq(self, classExample):

		
		self.timeSegments = classExample.timeSegments

		freqSegments = []
		
		for timeSegment in self.timeSegments:

			freqSegments += [np.power(2*(timeSegment[-1]-timeSegment[0]), -1)]

		self.freqSegments = freqSegments

		print('-> Characteristic pilot frequencies per segment [Hz]:')
		print('--> '+','.join([str(round(t, 3)) for t in freqSegments]))

		#Weights
		freqWeightSegments = calculateSelfWeight(freqSegments)
		self.freqWeightSegments = freqWeightSegments
		print('-> Characteristic pilot frequencies weights per segment [Hz]:')
		print('--> '+','.join([str(round(t, 3)) for t in freqWeightSegments]))

		self.freqSegmentsMaxWeight = freqSegments[freqWeightSegments.index(min(freqWeightSegments))]

	def getSegmentParameters(self, varClassesDict, dof):

		forceSegments = varClassesDict['CNT_FRC_BST_'+dof].dataSegments

		characteristicForceSegments = []

		for forceSegment in forceSegments:

			characteristicForceSegments += [np.mean(forceSegment)]

		self.characteristicForceSegments = characteristicForceSegments

		print('-> Characteristic forces per segment [N]:')
		print('--> '+','.join([str(round(t, 3)) for t in characteristicForceSegments]))

		#Weights
		characteristicForceWeightSegments = calculateSelfWeight(characteristicForceSegments)
		self.characteristicForceWeightSegments = characteristicForceWeightSegments
		print('-> Characteristic forces weights per segment:')
		print('--> '+','.join([str(round(t, 3)) for t in characteristicForceWeightSegments]))

		self.characteristicForceSegmentsMaxWeight = characteristicForceSegments[characteristicForceWeightSegments.index(min(characteristicForceWeightSegments))]

	def identifyFirstOrder(self, inputClass, outputClass, outputVelClass, plotSettings, CMDoptionsDict):

		kSegments = []
		TSegments = []

		for segmentID in range(len(inputClass.dataIncrementSegments)):
		
			# Input
			delta_u = np.vstack(inputClass.dataIncrementSegments[segmentID])
			delta_u_time = np.vstack(inputClass.timeSegments[segmentID])

			# Output
			delta_x1 = np.vstack(outputClass.dataIncrementSegments[segmentID])
			delta_x1_time = np.vstack(outputClass.timeSegments[segmentID])

			# Velocity output
			dot_x1 = np.vstack(outputVelClass.dataSegments[segmentID])
			z = dot_x1 #Measurements

			################# MODEL #######################
			# theta = [theta_1  theta_2]' = [ k_l/lambda_a  k_a/lambda_a]'
			# eq: dot_x1 = delta_u * k_l/lambda_a - delta_x1 * k_a/lambda_a

			################ OPER #########################

			# Matrix X
			X = np.hstack((delta_u, -delta_x1))

			N = z.shape[0]
			n_p = X.shape[1] #Shall be equal to 2

			D = lalg.inv( np.matmul(X.T, X) )
			theta_est = np.matmul(np.matmul(D, X.T), z)

			y_est = np.matmul(X, theta_est)

			res = z - y_est

			# pdb.set_trace()

			sigmaSQRT = np.matmul(res.T, res) / (N-n_p)
			sig = np.sqrt(sigmaSQRT)

			################ RESULTS #########################
			theta_1 = theta_est[0]
			theta_2 = theta_est[1]

			k = theta_1 / theta_2
			T = np.power(theta_2, -1)

			print('k:' + str(k) +', T:'+ str(T))
			paraResultsMatPos = {'theta_1' : 1, 'theta_2' : T}

			# for paraName in ('k', 'T'):

			# 	lower = paraResults[paraName] - 2 *np.sqrt( sigmaSQRT * D[] )

			# 	print('k:' + str(k))

			kSegments += [k]
			TSegments += [T]

			################ PLOT RESULTS #########################
			figure, axs = plt.subplots(3, 1, sharex='col')
			figure.set_size_inches(10, 6, forward=True)
			figure.suptitle(str(segmentID+1)+' sub-set, '+str(inputClass.timeSegments[segmentID][0])+'s to '+str(inputClass.timeSegments[segmentID][-1])+'s', **plotSettings['figure_title'])

			axs[0].plot(delta_x1_time, dot_x1, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Measured piston velocity', **plotSettings['line'])
			axs[0].plot(delta_x1_time, y_est, linestyle = '-.', marker = '', c = plotSettings['colors'][1], label = 'Estimated piston velocity', **plotSettings['line'])

			axs[0].legend(**plotSettings['legend'])

			axs[0].set_ylabel('Velocity [mm/s]', **plotSettings['axes_y'])

			usualSettingsAX(axs[0], plotSettings)

			################ PLOT RESULTS DISPLACEMENT #########################
			############ Simulation of TF, throws error
			# instantaneusTF = signal.TransferFunction([k], [T, 1])
			# simInput = np.hstack(delta_u)
			# simInputTime = np.hstack(delta_u_time)
			# tout, yout, xout = signal.lsim(instantaneusTF, simInput.astype(object), simInputTime.astype(object))

			yout = (k *delta_u) - (T*dot_x1)

			axs[1].plot(delta_x1_time, delta_x1, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Measured displacement', **plotSettings['line'])
			axs[1].plot(delta_x1_time, yout, linestyle = '-.', marker = '', c = plotSettings['colors'][1], label = 'Estimated displacement', **plotSettings['line'])

			axs[1].set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

			axs[1].legend(**plotSettings['legend'])

			usualSettingsAX(axs[1], plotSettings)

			axs[2].plot(delta_u_time, delta_u, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Measured input', **plotSettings['line'])

			axs[2].set_xlabel('Time [seconds]', **plotSettings['axes_x'])
			axs[2].set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

			axs[2].legend(**plotSettings['legend'])

			usualSettingsAX(axs[2], plotSettings)

			# Ax titles
			axs[0].set_title(outputClass.name, **plotSettings['ax_title'])
			axs[2].set_title(inputClass.name, **plotSettings['ax_title'])

			#Save figures
			figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), str(segmentID+1)+'_identificationResult.png'), dpi = plotSettings['figure_settings']['dpi'])


		self.kSegments = kSegments
		self.TSegments = TSegments


	def showInfluenceParameters(self, margin, plotSettings, CMDoptionsDict):

		figure, axs = plt.subplots(2, 2, sharex='col')
		figure.set_size_inches(10, 6, forward=True)

		ax_k_freq = axs[0,0]
		ax_T_freq = axs[1,0]
		
		# Show influence of input freq, find "constant" force
		indexSegmentsChosen, indexCurrentSegment, characteristicForceSegmentChosen = [], 0, []
		for characteristicForceSegment in self.characteristicForceSegments:

			if abs(characteristicForceSegment-self.characteristicForceSegmentsMaxWeight) < ((margin/100)*self.characteristicForceSegmentsMaxWeight):
				indexSegmentsChosen += [indexCurrentSegment]
				characteristicForceSegmentChosen += [characteristicForceSegment]

			indexCurrentSegment += 1

		# Plot results
		k_plot, T_plot, freq_plot = [], [], []

		for i in indexSegmentsChosen:
			k_plot += [self.kSegments[i]]
			T_plot += [self.TSegments[i]]
			freq_plot += [self.freqSegments[i]]

		ax_T_freq.plot( freq_plot, T_plot, linestyle = '', marker = 'o', c = plotSettings['colors'][1], **plotSettings['line'])
		ax_k_freq.plot( freq_plot, k_plot, linestyle = '', marker = 'o', c = plotSettings['colors'][1], **plotSettings['line'])

		ax_T_freq.set_ylabel('Time constant, $T$ [s]', **plotSettings['axes_y'])
		ax_k_freq.set_ylabel('Gain, $k$', **plotSettings['axes_y'])
		ax_T_freq.set_xlabel('Pilot input freq. [Hz]', **plotSettings['axes_x'])
		ax_k_freq.set_title('Force measured in range '+str(round(min(characteristicForceSegmentChosen), 2))+'N to '+str(round(max(characteristicForceSegmentChosen), 2))+'N', **plotSettings['axes_y'])


		# Final axis adjustments
		for ax in np.hstack(axs):
			usualSettingsAX(ax, plotSettings)

		figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), 'influenceParameters.png'), dpi = plotSettings['figure_settings']['dpi'])


class ClassVariableDef(object):
	"""docstring for ClassVariableDef"""
	def __init__(self, name_in):
		self.name = name_in

	def get_attr(self, attr_string):
		
		return getattr(self, attr_string)

	def importData(self, CMDoptionsDict, typeImport, varClassesGetSegmentsDict):

		def dofImporting(name):
			
			if 'LNG' in name:
				return 'LNG'
			elif 'COL' in name:
				return 'COL'
			elif 'LAT' in name:
				return 'LAT'
			else:
				raise ValueError('ERROR: Variable is not linked to any degree of freedom')

		fileName = os.path.join(CMDoptionsDict['flightTestInfo']['folderFTdata'], self.name+'.csv')

		file = open(fileName, 'r')
		lines = file.readlines()

		skipLines, time_proc, data_proc, counter = 1, [], [], 0

		for line in lines[skipLines:]:

			cleanLine = cleanString(line)

			data_proc += [float(cleanLine.split('\t')[0])]

			if counter == 0: #First iteration is already counted
				time_proc += [0.0]
				firstTimeAbsolute = float(cleanLine.split('\t')[1])
			else:
				time_proc += [float(cleanLine.split('\t')[1]) - firstTimeAbsolute]

			counter += 1

		#Raw data is imported until here

		if typeImport == 'segment':

			timeSegments = []
			dataSegments = []

			for timeSegmentList in varClassesGetSegmentsDict['DIF_CNT_DST_'+dofImporting(self.name)].timeSegmentsLimits: #CMDoptionsDict['flightTestInfo']['segment_'+dofImporting(self.name)].split(';'):

				indexStartTime = time_proc.index(timeSegmentList[0])
				indexEndTime = time_proc.index(timeSegmentList[1])

				timeSegments += [time_proc[indexStartTime:indexEndTime]]
				dataSegments += [data_proc[indexStartTime:indexEndTime]]

			self.timeSegments = timeSegments
			self.dataSegments = dataSegments

		elif typeImport == 'getSegment':

			# range to import 
			timeSegmentList = [float(t) for t in CMDoptionsDict['flightTestInfo']['rangeCalculationSegments'].split(',')]

			indexStartTime = time_proc.index(timeSegmentList[0])
			indexEndTime = time_proc.index(timeSegmentList[1])

			timeChosen = time_proc[indexStartTime:indexEndTime]
			dataChosen = data_proc[indexStartTime:indexEndTime]

			timeSegmentsLimits, firstPointFlag, nPoint, nPreviousPoint = [], False, 0, 0
			delta_t = 0.2 #seconds
			freq = 500 #Hz
			threashole = 1E-2
			delta_t_forward = 0.1
			vel_forward = 2
			pilotFreqThreadshole = 2.0 #Hz
			for data in dataChosen:

				if abs(data) < threashole:

					if not firstPointFlag and abs(dataChosen[int(nPoint + delta_t_forward*freq)]) > vel_forward and ((nPoint-nPreviousPoint) > (delta_t*freq)):
						firstPoint = timeChosen[dataChosen.index(data)]
						firstPointFlag = True
					elif firstPointFlag:
						secondPoint = timeChosen[dataChosen.index(data)]
						if (secondPoint - firstPoint) > (np.power(pilotFreqThreadshole, -1)/2):
							timeSegmentsLimits += [[firstPoint, secondPoint]]
						firstPointFlag = False
						nPreviousPoint = nPoint

				nPoint += 1

			self.timeSegmentsLimits = timeSegmentsLimits

		else:

			self.time = time_proc
			self.data = data_proc

	def convertToIncrement(self):

		newDataSegments = []
		
		for dataSegment in self.dataSegments:

			initialValue = dataSegment[0]

			updatedDataSegment = [t - initialValue for t in dataSegment]

			newDataSegments += [updatedDataSegment]

		self.dataIncrementSegments = newDataSegments


def importFTIdefFile(fileName_in, CMDoptionsDict):

	fileName = os.path.join(CMDoptionsDict['cwd'], fileName_in)

	file = open(fileName, 'r')

	lines = file.readlines()

	newSectionIdentifier = '->'

	currentVariable, dict_proc, dict_fti_info, sectionIndex = None, {}, {}, 0

	for i in range(0, int((len(lines)))):

		rawLine = lines[i]

		cleanLine = cleanString(rawLine)

		if cleanLine != '': #Filter out blank lines

			if newSectionIdentifier in rawLine: #Header detected, change to new section

				if 'Signal' in rawLine:

					currentVariable2 = cleanLine.split(':')[1]
					currentVariable1 = currentVariable2.lstrip()
					currentVariable = currentVariable1.rstrip()
					sectionIndex = 1

				elif 'flightTestInfo' in rawLine:

					sectionIndex = 2

			else: #For lines with information

				variableStringKey = cleanLine.split('::')[0]
				valueLine2 = cleanLine.split('::')[1]
				valueLine1 = valueLine2.lstrip()
				valueLine = valueLine1.rstrip()

				if sectionIndex == 2:

					dict_fti_info.update( {variableStringKey : valueLine})

				elif sectionIndex == 1: # for info of the variables

					if currentVariable in dict_proc.keys(): #If the variable is already in dict_proc
						temp_dict = dict_proc[currentVariable] #get temp dict in dict_proc for variable
						temp_dict[variableStringKey] = valueLine #add key/value pair to temp dict 
					else: #there is no key for 
						temp_dict = {variableStringKey : valueLine}
					dict_proc[currentVariable] = temp_dict


	CMDoptionsDict['variablesInfo'] = dict_proc
	CMDoptionsDict['flightTestInfo'] = dict_fti_info

	return CMDoptionsDict

def plotSignals(plotSettings, varClassesDict, CMDoptionsDict):

	for segmentID in range(len(varClassesDict[list(varClassesDict.keys())[0]].get_attr('timeSegments'))):

		figure, axesList = plt.subplots(len(list(varClassesDict.keys())), 1, sharex='col')
		figure.set_size_inches(12, 6, forward=True)

		for ax, var in zip(axesList, varClassesDict.keys()):

			if not 'DIF' in var:
				ax.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], varClassesDict[var].get_attr('dataIncrementSegments')[segmentID], linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varClassesDict[var].get_attr('name'), **plotSettings['line'])		
			else:
				ax.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], varClassesDict[var].get_attr('dataSegments')[segmentID], linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varClassesDict[var].get_attr('name'), **plotSettings['line'])		

			if ax == axesList[-1]:
				ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

			ax.set_ylabel(CMDoptionsDict['variablesInfo'][varClassesDict[var].get_attr('name')]['units'], **plotSettings['axes_y'])

			ax.set_title(varClassesDict[var].get_attr('name'), **plotSettings['axes_y'])

			ax.grid(which='both', **plotSettings['grid'])
			ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			ax.minorticks_on()

			figure.suptitle(str(segmentID+1)+' sub-set, '+str(varClassesDict[var].get_attr('timeSegments')[segmentID][0])+'s to '+str(varClassesDict[var].get_attr('timeSegments')[segmentID][-1])+'s', **plotSettings['figure_title'])

			#Double y-axis
			axdouble_in_y = ax.twinx()
			axdouble_in_y.minorticks_on()
			if not varClassesDict[var].get_attr('name') == 'CNT_DST_BST_LNG':
				axdouble_in_y.set_ylim(ax.get_ylim())
			else:
				diffData0 = np.diff(varClassesDict[var].get_attr('dataIncrementSegments')[segmentID])
				diffData = [diffData0.tolist()[0]]+diffData0.tolist() #Correct reduction in the dimension
				axdouble_in_y.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], diffData, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = varClassesDict[var].get_attr('name')+'_diff', **plotSettings['line'])
				ax.legend(**plotSettings['legend'])
				axdouble_in_y.legend(**plotSettings['legend'])


	



def cleanString(stringIn):
	
	if stringIn[-1:] in ('\t', '\n'):

		return cleanString(stringIn[:-1])

	else:

		return stringIn

def usualSettingsAX(ax, plotSettings):
	
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()
	#Double y-axis 
	axdouble_in_y = ax.twinx()
	axdouble_in_y.minorticks_on()
	axdouble_in_y.set_ylim(ax.get_ylim())

def calculateSelfWeight(v):

	def f_back(v, i):

		sum = 0
		for j in range(i):

			sum += abs(v[i]-v[j])

		return sum

	def f_forward(v, i):

		sum = 0
		for j in range(i+1,len(v)):

			sum += abs(v[i]-v[j])

		return sum

	N = len(v)

	weightVector = []

	for i in range(N):

		weightVector += [f_back(v, i)+f_forward(v, i)]

	return weightVector