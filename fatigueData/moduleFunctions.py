# Collection of functions
import pdb
import os
import sys
import numpy as np
import matplotlib.pyplot as plt

###### Functions
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

	plotSettings = {'axes_x':axes_label_x,'axes_y':axes_label_y, 'title':text_title_properties,
	                'axesTicks':axes_ticks, 'line':line, 'legend':legend, 'grid':grid, 'scatter':scatter,
	                'colors' : colors, 'markers' : markers, 'linestyles' : linestyles}

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
	def __init__(self, description_in, freq_in):
		# super(dataFromGaugesSingleMagnitudeClass, self).__init__()

		self.__description = description_in
		self.__freq = freq_in

		self.__max = []
		self.__mean = []
		self.__min = []

		self.__timeMax = []
		self.__timeMean = []
		self.__timeMin = []
		self.__timeSecNewRunMax = []
		self.__timeSecNewRunMean = []
		self.__timeSecNewRunMin = []

		self.__xValues = []
		self.__xValuesNewRun = []
		self.__lastID = 0

	def reStartXvalues(self):
		self.__xValues = []
		self.__xValuesNewRun = []

	def set_magData(self, nameField, data):

		if nameField == 'mean':
			self.__mean += data
		elif nameField == 'max':
			self.__max += data
		elif nameField == 'min':
			self.__min += data

		else:
			raise ValueError('Error in identifying data field: ' + nameField)

	def getTimeList(self, nameField):
		
		timeSec = np.linspace(0, int(len(self.__xValues)/self.__freq), len(self.__xValues), endpoint=True)
		timeSecNewRun = [float(t/self.__freq) for t in self.__xValuesNewRun]
		a = self.__xValuesNewRun
		f = self.__freq
		pdb.set_trace()

		if nameField == 'mean':
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

		skipLines, dataID, data = 0, [], []

		for line in lines[(skipLines+1):]:

			data += [float(cleanString(line))]

			dataID = dataID + [self.__lastID+1]
				
		file.close()

		self.set_magData(fieldOfFile, data)

		self.__lastID = dataID[-1]

		self.__xValuesNewRun += [dataID[-1]]

		self.__xValues += dataID
	
	def get_description(self):
		return self.__description

	def get_max(self):
		return self.__max
	def get_mean(self):
		return self.__mean
	def get_min(self):
		return self.__min

	def get_timeMax(self):
		return self.__timeMax
	def get_timeMean(self):
		return self.__timeMean
	def get_timeMin(self):
		return self.__timeMin

	def get_timeSecNewRunMax(self):
		return self.__timeSecNewRunMax
	def get_timeSecNewRunMean(self):
		return self.__timeSecNewRunMean
	def get_timeSecNewRunMin(self):
		return self.__timeSecNewRunMin

	def plot(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		ax.grid(which='both', **plotSettings['grid'])
		figure.set_size_inches(10, 6, forward=True)
		ax.tick_params(axis='both', **plotSettings['axesTicks'])

		ax.plot(self.get_timeMax(), self.get_max(), linestyle = '', marker = '+', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.get_timeMean(), self.get_mean(), linestyle = '', marker = '+', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.get_timeMin(), self.get_min(), linestyle = '', marker = '+', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		#Division line for runs
		for div in self.get_timeSecNewRunMean():
			ax.plot(2*[div], [self.get_min()[-1]*1.2, self.get_max()[-1]*1.2], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		ax.set_xlabel('Time uninterrupted test [seconds]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])
		ax.legend(**plotSettings['legend'])
		ax.set_title(self.get_description(), **plotSettings['title'])

def plotSingleRun(dataFromRun, plotSettings):

	figure, ax = plt.subplots(1, 1)
	ax.grid(which='both', **plotSettings['grid'])
	figure.set_size_inches(10, 6, forward=True)
	ax.tick_params(axis='both', **plotSettings['axesTicks'])

	ax.plot(dataFromRun.get_cycleN(), dataFromRun.get_maxF(), linestyle = '', marker = '+', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
	ax.plot(dataFromRun.get_cycleN(), dataFromRun.get_meanF(), linestyle = '', marker = '+', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
	ax.plot(dataFromRun.get_cycleN(), dataFromRun.get_minF(), linestyle = '', marker = '+', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

	ax.set_xlabel('Number of cycles', **plotSettings['axes_x'])
	ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])
	ax.legend(**plotSettings['legend'])

def plotAllRuns(dataFromRuns, plotSettings):

	def threePlotForRun(dataFromRun, plotSettings, ax):
		
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_maxF(), linestyle = '', marker = '+', c = plotSettings['colors'][0], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_meanF(), linestyle = '', marker = '+', c = plotSettings['colors'][1], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_minF(), linestyle = '', marker = '+', c = plotSettings['colors'][2], **plotSettings['line'])	
	
	def plotDivisionLine(dataFromLastRun, ax, plotSettings):

		ax.plot(2*[dataFromLastRun.get_absoluteNCycles_mill()[-1]], [dataFromLastRun.get_minF()[-1]*1.2, dataFromLastRun.get_maxF()[-1]*1.2], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	for data in dataFromRuns:

		threePlotForRun(data, plotSettings, ax)
		plotDivisionLine(data, ax, plotSettings)

	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', **plotSettings['axesTicks'])
	ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
	ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

	# Legends
	legendHandles = []
	handle0 = plt.Line2D([],[], color=plotSettings['colors'][0], marker='+', linestyle='', label='Max force')
	handle1 = plt.Line2D([],[], color=plotSettings['colors'][1], marker='+', linestyle='', label='Mean force')
	handle2 = plt.Line2D([],[], color=plotSettings['colors'][2], marker='+', linestyle='', label='Min force')
	legendHandles = legendHandles + [handle0, handle1, handle2]
	ax.legend(handles = legendHandles, **plotSettings['legend'])

