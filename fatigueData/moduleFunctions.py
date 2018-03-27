# Collection of functions
import pdb
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import getopt
import pdb #pdb.set_trace()

###### Functions
def readCMDoptionsMainAbaqusParametric(argv, CMDoptionsDict):

	short_opts = "o:f:"
	long_opts = ["option=","fileName="]
	try:
		opts, args = getopt.getopt(argv,short_opts,long_opts)
	except getopt.GetoptError:
		raise ValueError('ERROR: Not correct input to script')

	# check input
	if len(opts) != len(long_opts):
		raise ValueError('ERROR: Invalid number of inputs')	

	for opt, arg in opts:

		if opt in ("-f", "--fileName"):
			# postProcFolderName = arg
			CMDoptionsDict['fileNameOfFileToLoadFiles'] = arg

		elif opt in ("-o", "--option"):
			if arg.lower() in ('actuator', 'excel'):
				CMDoptionsDict['actuatorFlag'] = True
				CMDoptionsDict['dmsFlag'] = False
			elif arg.lower() in ('dms', 'strain', 'gauge'):
				CMDoptionsDict['actuatorFlag'] = False
				CMDoptionsDict['dmsFlag'] = True

	return CMDoptionsDict

def sortFilesInFolderByLastNumberInName(listOfFiles):

	a = []
	for file in listOfFiles:
		if file.endswith('.csv'):
			fileID_0 = file.split('.')[0]
			fileID_int = int(fileID_0.split('_')[-1])
			a += [(file, fileID_int),]

	a_sorted = sorted(a, key=lambda x: x[1])
	listOfFilesSorted = [b[0] for b in a_sorted]

	return listOfFilesSorted

def cleanString(stringIn):
	
	if stringIn[-1:] in ('\t', '\n'):

		return cleanString(stringIn[:-1])

	else:

		return stringIn

def loadFileAddresses(fileName): 

	file = open(fileName, 'r')

	lines = file.readlines()

	directoryAddressClass = inputDataClassDef()

	for i in range(1, int((len(lines)))):

		rawLine = lines[i]

		if rawLine != '':

			directoryAddressClass.addSharedAddress(cleanString(rawLine))

	file.close()

	return directoryAddressClass

class inputDataClassDef(object):
	"""docstring for inputData"""
	def __init__(self):
		"""
		Initializes the class with local address and empty directory of shared folders
		"""

		self.__setOfAddress_tuple = ()

	def addSharedAddress(self, fileAddress):

		if os.path.isfile(fileAddress) or os.path.isdir(fileAddress):

			self.__setOfAddress_tuple += (fileAddress,)

		else:

			print('WARNING: Address '+fileAddress+' does not exist or is not a directory, entry skipped')

	def getTupleFiles(self):

		return self.__setOfAddress_tuple

def importDataActuator(fileName):

	file = open(fileName, 'r')
	lines = file.readlines()

	cycleN, maxF, meanF, minF = [], [], [], []

	lineN = 0
	for line in lines:

		currentLineSplit = line.split(';')

		if lineN > 1:
			
			cycleN += [returnNumber(currentLineSplit[0])]
			maxF += [returnNumber(currentLineSplit[20])]
			meanF += [returnNumber(currentLineSplit[21])]
			minF += [returnNumber(currentLineSplit[22])]

		lineN += 1
			

	file.close()

	dataFromRun = dataFromRunClass(1)

	dataFromRun.add_data(cycleN, maxF, meanF, minF)

	return dataFromRun

def returnNumber(numStr):
	
	if numStr[-4] == '.':
		numStr_ohnePunkt = numStr.replace('.','')
		# return float(numStr[:-13]+numStr_ohnePunkt[-10:])
		return float(numStr_ohnePunkt[:-9]+'.'+numStr_ohnePunkt[-9:])
		# return float(numStr[:(numStr.index('.')+1)]+numStr[(numStr.index('.')+1):].replace('.',''))
	else:

		return float(numStr)

def importPlottingOptions():
	#### PLOTTING OPTIONS ####

	#Plotting options
	axes_label_x  = {'size' : 14, 'weight' : 'bold', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 14, 'weight' : 'bold', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	text_title_properties = {'weight' : 'bold', 'size' : 16}
	axes_ticks = {'labelsize' : 10}
	line = {'linewidth' : 1.5, 'markersize' : 2}
	scatter = {'linewidths' : 2}
	legend = {'fontsize' : 16, 'loc' : 'best'}
	grid = {'alpha' : 0.7}
	colors = ['k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c']
	markers = ['o', 'v', '^', 's', '*', '+']
	linestyles = ['-', '--', '-.', ':']
	axes_ticks_n = {'x_axis' : 3} #Number of minor labels in between 

	plotSettings = {'axes_x':axes_label_x,'axes_y':axes_label_y, 'title':text_title_properties,
	                'axesTicks':axes_ticks, 'line':line, 'legend':legend, 'grid':grid, 'scatter':scatter,
	                'colors' : colors, 'markers' : markers, 'linestyles' : linestyles, 'axes_ticks_n' : axes_ticks_n}

	return plotSettings

class dataFromRunClass(object):
	"""
	docstring for dataFromRun

	Class contaiting data from a certain run
	"""
	def __init__(self, id_in):
		# super(dataFromRun, self).__init__()

		self.__id = id_in

	def add_data(self, cycleN_in, maxF_in, meanF_in, minF_in):

		self.__cycleN = cycleN_in
		self.__cycleN_mill = [d/1000000 for d in cycleN_in]
		self.__maxF = maxF_in 
		self.__meanF = meanF_in 
		self.__minF = minF_in

	def setAbsoluteNCycles(self, previousNCycles_in):
		
		self.__absoluteNCycles = [d + previousNCycles_in for d in self.__cycleN]
		self.__absoluteNCycles_mill = [(d + previousNCycles_in)/1000000 for d in self.__cycleN]

	def get_id(self):
		return self.__id
	def get_absoluteNCycles(self):
		return self.__absoluteNCycles
	def get_absoluteNCycles_mill(self):
		return self.__absoluteNCycles_mill
	def get_cycleN(self):
		return self.__cycleN
	def get_cycleN_mill(self):
		return self.__cycleN_mill
	def get_maxF(self):
		return self.__maxF
	def get_meanF(self):
		return self.__meanF
	def get_minF(self):
		return self.__minF

class dataFromGaugesSingleMagnitudeClass(object):
	"""
	docstring for dataFromGaugesSingleMagnitudeClass

	Class contaiting data from a certain run
	"""
	def __init__(self, description_in, testFactor_in):
		# super(dataFromGaugesSingleMagnitudeClass, self).__init__()

		self.__description = description_in
		self.__testFactor = testFactor_in

		self.__max = []
		self.__mean = []
		self.__min = []
		self.__rs = []

		self.__timeMax = []
		self.__timeMean = []
		self.__timeMin = []
		self.__timeRs = []
		self.__timeSecNewRunMax = []
		self.__timeSecNewRunMean = []
		self.__timeSecNewRunMin = []
		self.__timeSecNewRunRs = []

		self.__lastID = 0
		self.__xValues = []
		self.__xValuesNewRun = []

	def reStartXvaluesAndLastID(self):
		self.__lastID = 0
		self.__xValues = []
		self.__xValuesNewRun = []

	def set_magData(self, nameField, data):

		if nameField == 'rs':
			self.__rs += data
		elif nameField == 'mean':
			self.__mean += data
		elif nameField == 'max':
			self.__max += data
		elif nameField == 'min':
			self.__min += data
		else:
			raise ValueError('Error in identifying data field: ' + nameField)
	def getTimeList(self, nameField):
		
		timeSec = np.linspace(0, float(len(self.__xValues)/self.__testFactor), len(self.__xValues), endpoint=True)
		timeSecNewRun = [float(t/self.__testFactor) for t in self.__xValuesNewRun]

		print('----> Last computed time point: ' + str(timeSec[-1]) + ' millions')

		if nameField == 'rs':
			self.__timeRs = timeSec
			self.__timeSecNewRunRs = timeSecNewRun
		elif nameField == 'mean':
			self.__timeMean = timeSec
			self.__timeSecNewRunMean = timeSecNewRun
		elif nameField == 'max':
			self.__timeMax = timeSec
			self.__timeSecNewRunMax = timeSecNewRun
		elif nameField == 'min':
			self.__timeMin = timeSec
			self.__timeSecNewRunMin = timeSecNewRun

		else:
			raise ValueError('Error in identifying data field: ' + nameField)

	def importDataForClass(self, fileName, fieldOfFile):

		file = open(fileName, 'r')
		lines = file.readlines()

		skipLines, dataID, data, counter = 0, [], [], 0

		for line in lines[(skipLines+1):]:

			data += [float(cleanString(line))]

			if counter == 0: #First iteration
				dataID += [self.__lastID+1]
			else:
				dataID += [dataID[-1]+1]

			counter += 1
		
		file.close()

		self.set_magData(fieldOfFile, data)

		self.__lastID = dataID[-1]

		self.__xValuesNewRun += [dataID[-1],]

		print('\t'+'-> Last computed data point absolute index: ' + str(dataID[-1]/1000000.0) + ' millions')

		self.__xValues += dataID
	
	def get_description(self):
		return self.__description

	def get_xValues(self):
		return self.__xValues
	def get_xValuesNewRun(self):
		return self.__xValuesNewRun

	def get_max(self):
		return self.__max
	def get_mean(self):
		return self.__mean
	def get_min(self):
		return self.__min
	def get_rs(self):
		return self.__rs

	def get_timeMax(self):
		return self.__timeMax
	def get_timeMean(self):
		return self.__timeMean
	def get_timeMin(self):
		return self.__timeMin
	def get_timeRs(self):
		return self.__timeRs

	def get_timeSecNewRunMax(self):
		return self.__timeSecNewRunMax
	def get_timeSecNewRunMean(self):
		return self.__timeSecNewRunMean
	def get_timeSecNewRunMin(self):
		return self.__timeSecNewRunMin
	def get_timeSecNewRunRs(self):
		return self.__timeSecNewRunRs

	def plotMaxMinMean(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.get_timeMax(), self.get_max(), linestyle = '', marker = '+', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.get_timeMean(), self.get_mean(), linestyle = '', marker = '+', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.get_timeMin(), self.get_min(), linestyle = '', marker = '+', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		#Division line for runs
		for div in self.get_timeSecNewRunMean():
			ax.plot(2*[div], [self.get_min()[-1]*1.2, self.get_max()[-1]*1.2], linestyle = '-', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])
		
		ax.legend(**plotSettings['legend'])
		ax.set_title(self.get_description(), **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

	def plotResampled(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.get_timeRs(), self.get_rs(), linestyle = '', marker = '+', c = plotSettings['colors'][0], label = 'Measured force, re-sampled 100Hz', **plotSettings['line'])

		#Division line for runs
		for div in self.get_timeSecNewRunRs():
			ax.plot(2*[div], [min(self.get_rs())*1.2, max(self.get_rs())*1.2], linestyle = '-', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

		#Legend and title
		ax.legend(**plotSettings['legend'])
		ax.set_title(self.get_description(), **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

def plotSingleRun(dataFromRun, plotSettings):

	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	ax.plot(dataFromRun.get_cycleN(), dataFromRun.get_maxF(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
	ax.plot(dataFromRun.get_cycleN(), dataFromRun.get_meanF(), linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
	ax.plot(dataFromRun.get_cycleN(), dataFromRun.get_minF(), linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

	ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
	ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

	ax.legend(**plotSettings['legend'])
	ax.set_title('Results from Run #'+str(dataFromRun.get_id()), **plotSettings['title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()

def plotAllRuns(dataFromRuns, plotSettings):

	def threePlotForRun(dataFromRun, plotSettings, ax):
		
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_maxF(), linestyle = '-', marker = '', c = plotSettings['colors'][0], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_meanF(), linestyle = '-', marker = '', c = plotSettings['colors'][1], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_minF(), linestyle = '-', marker = '', c = plotSettings['colors'][2], **plotSettings['line'])	
	
	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	#Plot first division line
	ax.plot(2*[0.0], [dataFromRuns[0].get_minF()[-1]*1.2, dataFromRuns[0].get_maxF()[-1]*1.2], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
	for data in dataFromRuns:

		threePlotForRun(data, plotSettings, ax)
		
		#Plot division lines
		ax.plot(2*[data.get_absoluteNCycles_mill()[-1]], [data.get_minF()[-1]*1.2, data.get_maxF()[-1]*1.2], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

	ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
	ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

	# Legends
	legendHandles = []
	handle0 = plt.Line2D([],[], color=plotSettings['colors'][0], marker='+', linestyle='', label='Max force')
	handle1 = plt.Line2D([],[], color=plotSettings['colors'][1], marker='+', linestyle='', label='Mean force')
	handle2 = plt.Line2D([],[], color=plotSettings['colors'][2], marker='+', linestyle='', label='Min force')
	legendHandles = legendHandles + [handle0, handle1, handle2]
	ax.legend(handles = legendHandles, **plotSettings['legend'])

	#Title
	ax.set_title('Results fatigue test', **plotSettings['title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])

	#Tick parametersget_xticks
	# majorTicks = ax.get_xmajorticklabels()
	ax.minorticks_on()
	xticksMajor = ax.get_xticks(minor = False)
	xticksMinor = ax.get_xticks(minor = True)
	yticksMinor = ax.get_yticks(minor = True)
	[print(m) for m in xticksMajor]
	print('-')
	[print(m) for m in xticksMinor]
	print('-')
	# majorTicksNum = [float(m.get_text()) for m in majorTicks]

	xticksMinorUser = []
	counter = 0
	for tick in xticksMajor[: len(xticksMajor)-2]:
		xticksMinorUserInBetween = np.linspace(tick, xticksMajor[counter+1], plotSettings['axes_ticks_n']['x_axis']+1, endpoint=False)
		[print(m) for m in xticksMinorUserInBetween]
		print('-')
		xticksMinorUser += xticksMinorUserInBetween
		counter += 1

	[print(m) for m in xticksMinorUser]
	xlistOfLabelsMinor = [str(m) for m in xticksMinor]
	ylistOfLabelsMinor = [str(m) for m in yticksMinor]

	ax.set_xticklabels(xlistOfLabelsMinor, minor=True)
	ax.set_yticklabels(ylistOfLabelsMinor, minor=True)

	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	####

	
