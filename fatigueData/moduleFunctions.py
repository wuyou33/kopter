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

	short_opts = "f:v:m:" #"o:f:"
	long_opts = ["fileName=","variables=","magnitudes="] #["option=","fileName="]
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

			if 'actuator' in arg.lower():
				CMDoptionsDict['actuatorFlag'] = True
				CMDoptionsDict['dmsFlag'] = False
			elif 'gauge' in arg.lower():
				CMDoptionsDict['actuatorFlag'] = False
				CMDoptionsDict['dmsFlag'] = True

		elif opt in ("-v", "--variables"):

			CMDoptionsDict['variables'] = arg.split(',')

		elif opt in ("-m", "--magnitudes"):

			CMDoptionsDict['magnitudes'] = arg.split(',')

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

def importDataActuator(fileName, iFile):

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

	print('----> Last computed data point index (file): ' + str(int(cycleN[-1])/1000.0) + ' thousands')

	dataFromRun = dataFromRunClass(iFile)

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
	legend = {'fontsize' : 14, 'loc' : 'best'}
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

	def plotSingleRun(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.get_cycleN(), self.get_maxF(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.get_cycleN(), self.get_meanF(), linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.get_cycleN(), self.get_minF(), linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

		ax.legend(**plotSettings['legend'])
		ax.set_title('Results from Run #'+str(self.get_id()), **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

class dataFromGaugesSingleMagnitudeClass(object):
	"""
	docstring for dataFromGaugesSingleMagnitudeClass

	Class contaiting data from a certain run
	"""
	def __init__(self, description_in, testFactor_in, orderDeriv_in):
		# super(dataFromGaugesSingleMagnitudeClass, self).__init__()

		self.__description = description_in
		self.__testFactor = testFactor_in
		self.__orderDeriv = orderDeriv_in

		self.__max = []
		self.__mean = []
		self.__min = []
		self.__rs = []
		self.__maxPicks = []
		self.__meanPicks = []
		self.__minPicks = []

		self.__timeMax = []
		self.__timeMean = []
		self.__timeMin = []
		self.__timeRs = []
		self.__timePicks = []

		self.__timeSecNewRunMax = []
		self.__timeSecNewRunMean = []
		self.__timeSecNewRunMin = []
		self.__timeSecNewRunRs = []
		self.__timeSecNewRunPicks = []

		self.__lastID = 0
		self.__lastIDPick = 0
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

		print('\n'+'----> Last computed time point for test: ' + str(timeSec[-1]) + ' millions')

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

		print('\t'+'-> Last computed data point index (file): ' + str(counter/1000000.0) + ' millions')
		if fieldOfFile == 'rs':
			print('\t'+'-> Last computed data point index (accumulated): ' + str(dataID[-1]/1000000.0) + ' millions')

		self.__xValues += dataID

	def computePicks(self):
		"""
		Inputs: 
		self.__rs -> All the data points
		self.__timeRs -> List of data indexes
		self.__orderDeriv -> order of points to be taken into account, min: 1, max: infty  
		"""
		iPickMax = 0
		iPickMin = 0
		picksMax = []
		picksMin = []
		dataIDmax = []
		dataIDmin = []
		iPoint = self.__orderDeriv
		for point in self.__rs[self.__orderDeriv:(len(self.__rs)+1-self.__orderDeriv)]:

			assert self.__rs[iPoint] == point

			#Check if point is max, min

			resultID = self.chechMinMaxFn(self.__orderDeriv, self.__rs[iPoint - self.__orderDeriv : iPoint + self.__orderDeriv + 1])
			#Result is return like this: result = resultID

			if resultID == 2:

				#Max function
				if iPickMax == 0: #To do only in the first time the loop is entered
					dataIDmax += [self.__lastIDPick+1]
				else:
					dataIDmax += [dataIDmax[-1]+1]

				picksMax += [point]
				iPickMax += 1

			elif resultID == 1:

				#Min function
				if iPickMin == 0: #To do only in the first time the loop is entered
					dataIDmin += [self.__lastIDPick+1]
				else:
					dataIDmin += [dataIDmin[-1]+1]

				picksMin += [point]
				iPickMin += 1

			iPoint += 1


		#Now all the points in the series have been analysed
		print('\t'+'-> Number of max picks found :'+str(iPickMax))
		print('\t'+'-> Number of min picks found :'+str(iPickMin))

		diff = iPickMax - iPickMin

		assert iPickMax == len(picksMax), str(iPickMax)+', '+str(len(picksMax))
		assert iPickMax == len(dataIDmax), str(iPickMax)+', '+str(len(dataIDmax))
		assert iPickMin == len(picksMin), str(iPickMin)+', '+str(len(picksMin))
		assert iPickMin == len(dataIDmin), str(iPickMin)+', '+str(len(dataIDmin))

		if diff > 100:
			raise ValueError('Too much difference between number of picked max picks and min picks: ' + str(diff))

		minIndex = int(min(iPickMin, iPickMax))


		assert dataIDmax[minIndex-1] == dataIDmin[minIndex-1]


		# self.__maxPicks += newPicksMax
		# self.__minPicks += newPicksMin
		newPicksMax = picksMax[:minIndex]
		newPicksMin = picksMin[:minIndex]

		# self.__timeMaxPicks += timeMaxPicks
		timeMaxPicks = [float(t/self.__testFactor) for t in dataIDmax[:minIndex]]
		timeMinPicks = [float(t/self.__testFactor) for t in dataIDmin[:minIndex]]

		#Get mean values
		newPicksMean = []
		timeMeanPicks = []
		for maxValue, minValue in zip(newPicksMax, newPicksMin):

			newPicksMean += [np.mean([maxValue, minValue]),]

		for maxValueTime, minValueTime in zip(timeMaxPicks, timeMinPicks):

			timeMeanPicks += [np.mean([maxValueTime, minValueTime]),]

		#Final
		self.__timeSecNewRunPicks += [dataIDmin[minIndex]/self.__testFactor,]

		self.__lastIDPick = dataIDmin[minIndex]

		return newPicksMax, newPicksMean, newPicksMin, timeMaxPicks

	def chechMinMaxFn(self, order, vect):
		
		offsetMax = min(vect)
		offsetMin = max(vect)


		newVectMax = [t - offsetMax for t in vect]
		newVectMin = [t - offsetMin for t in vect]

		actualPointMax = newVectMax[order]
		actualPointMin = newVectMin[order]

		if max(newVectMax) == actualPointMax:

			return 2 #Max

		elif min(newVectMin) == actualPointMin:

			return 1

		else:

			return -1

	def updatePicksData(self, newPicksMax_in, newPicksMean_in, newPicksMin_in, timePicks_in):
		
		self.__maxPicks += newPicksMax_in
		self.__meanPicks += newPicksMean_in
		self.__minPicks += newPicksMin_in
		self.__timePicks += timePicks_in


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
	def get_maxPicks(self):
		return self.__maxPicks
	def get_meanPicks(self):
		return self.__meanPicks
	def get_minPicks(self):
		return self.__minPicks
	def get_rs(self):
		return self.__rs

	def get_timeMax(self):
		return self.__timeMax
	def get_timeMean(self):
		return self.__timeMean
	def get_timeMin(self):
		return self.__timeMin
	def get_timePicks(self):
		return self.__timePicks
	def get_timeRs(self):
		return self.__timeRs

	def get_timeSecNewRunMax(self):
		return self.__timeSecNewRunMax
	def get_timeSecNewRunMean(self):
		return self.__timeSecNewRunMean
	def get_timeSecNewRunMin(self):
		return self.__timeSecNewRunMin
	def get_timeSecNewRunPicks(self):
		return self.__timeSecNewRunPicks
	def get_timeSecNewRunRs(self):
		return self.__timeSecNewRunRs

	def plotMaxMinMean_fromDIAdem(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.get_timeMax(), self.get_max(), linestyle = '', marker = '+', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.get_timeMean(), self.get_mean(), linestyle = '', marker = '+', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.get_timeMin(), self.get_min(), linestyle = '', marker = '+', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		#Division line for runs
		maxPlot = self.get_max()[-1]*1.2
		minPlot = self.get_min()[-1]*1.2
		ax.plot(2*[0.0], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		for div in self.get_timeSecNewRunMean():
			ax.plot(2*[div], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

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

		ax.plot(self.get_timeRs(), self.get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Measured force', **plotSettings['line'])

		#Division line for runs
		maxPlot = max(self.get_rs())*1.2
		minPlot = min(self.get_rs())*1.2
		ax.plot(2*[0.0], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		for div in self.get_timeSecNewRunRs():
			ax.plot(2*[div], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		ax.set_xlabel('Number of points [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

		#Legend and title
		# ax.legend(**plotSettings['legend'])
		ax.set_title(self.get_description(), **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

	def plotMinMeanMax(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.get_timePicks(), self.get_maxPicks(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.get_timePicks(), self.get_meanPicks(), linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.get_timePicks(), self.get_minPicks(), linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		#Division line for runs
		maxPlot = max(self.get_maxPicks())*1.2
		minPlot = min(self.get_minPicks())*1.2
		ax.plot(2*[0.0], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		for div in self.get_timeSecNewRunPicks():
			ax.plot(2*[div], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

		#Legend and title
		ax.legend(**plotSettings['legend'])
		ax.set_title(self.get_description(), **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

		print('\n')
		print('--> Maximum force applied in complete test (mean value):'+str(round(np.mean(self.get_maxPicks()), 2))+' N')
		print('--> Mean force applied in complete test (mean value):'+str(round(np.mean(self.get_meanPicks()), 2))+' N')
		print('--> Minimum force applied in complete test (mean value):'+str(round(np.mean(self.get_minPicks()), 2))+' N')

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
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	####

	
