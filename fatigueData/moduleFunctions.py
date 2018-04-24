# Collection of functions
import pdb
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import math
import getopt
import pdb #pdb.set_trace()


###### Functions
def readCMDoptionsMainAbaqusParametric(argv, CMDoptionsDict):

	short_opts = "f:v:m:o:s:r:" #"o:f:"
	long_opts = ["fileName=","variables=","magnitudes=","testOrder=","saveFigure=","rangeFileIDs="] #["option=","fileName="]
	try:
		opts, args = getopt.getopt(argv,short_opts,long_opts)
	except getopt.GetoptError:
		raise ValueError('ERROR: Not correct input to script')

	# check input
	# if len(opts) != len(long_opts):
		# raise ValueError('ERROR: Invalid number of inputs')	

	for opt, arg in opts:

		if opt in ("-f", "--fileName"):
			# postProcFolderName = arg
			CMDoptionsDict['fileNameOfFileToLoadFiles'] = arg

			if 'actuatormesswerte' in arg.lower():
				CMDoptionsDict['actuatorMesswerte'] = True
				CMDoptionsDict['actuatorFlag'] = False
				CMDoptionsDict['dmsFlag'] = False
			elif 'gauge' in arg.lower():
				CMDoptionsDict['actuatorMesswerte'] = False
				CMDoptionsDict['actuatorFlag'] = False
				CMDoptionsDict['dmsFlag'] = True
			elif 'actuator' in arg.lower():
				CMDoptionsDict['actuatorMesswerte'] = False
				CMDoptionsDict['actuatorFlag'] = True
				CMDoptionsDict['dmsFlag'] = False

		elif opt in ("-v", "--variables"):

			CMDoptionsDict['variables'] = arg.split(',')

		elif opt in ("-m", "--magnitudes"):

			CMDoptionsDict['magnitudes'] = arg.split(',')

		elif opt in ("-o", "--testOrder"):

			if arg.lower() in ('true', 't'):
				CMDoptionsDict['testOrderFlagFromCMD'] = True
			elif arg.lower() in ('false', 'f'):
				CMDoptionsDict['testOrderFlagFromCMD'] = False
			else:
				CMDoptionsDict['testOrderRange'] = [float(t) for t in arg.split(',')]
				CMDoptionsDict['testOrderFlagFromCMD'] = True

		elif opt in ("-s", "--saveFigure"):

			if arg.lower() in ('true', 't'):
				CMDoptionsDict['saveFigure'] = True
			elif arg.lower() in ('false', 'f'):
				CMDoptionsDict['saveFigure'] = False

		elif opt in ("-r", "--rangeFileIDs"):

			CMDoptionsDict['rangeFileIDs'] = [int(t) for t in arg.split(',')]

	return CMDoptionsDict

def sortFilesInFolderByLastNumberInName(listOfFiles, CMDoptionsDict):

	a = []
	for file in listOfFiles:
		if file.endswith('.csv'):
			fileID_0 = file.split('.')[0]
			fileID_int = int(fileID_0.split('_')[-1])
			if fileID_int in CMDoptionsDict['rangeFileIDs']:
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

def importDataActuator(fileName, iFile, CMDoptionsDict):

	file = open(fileName, 'r')
	lines = file.readlines()
	fileNameShort = fileName.split('\\')[-1]

	if CMDoptionsDict['actuatorFlag']:

		cycleN, maxF, meanF, minF, maxDispl, meanDispl, minDispl = [], [], [], [], [], [], []

		lineN = 0
		for line in lines:

			currentLineSplit = line.split(';')

			if lineN > 1:
				
				cycleN += [returnNumber(currentLineSplit[0])]
				maxDispl += [returnNumber(currentLineSplit[4])]
				meanDispl += [returnNumber(currentLineSplit[5])]
				minDispl += [returnNumber(currentLineSplit[6])]
				maxF += [returnNumber(currentLineSplit[20])]
				meanF += [returnNumber(currentLineSplit[21])]
				minF += [returnNumber(currentLineSplit[22])]

			lineN += 1
				

		file.close()

		print('\t'+'-> Last computed data point index (file): ' + str(int(cycleN[-1])/1000.0) + ' thousands')

		dataFromRun = dataFromRunClass(iFile)

		dataFromRun.add_data(cycleN, maxF, meanF, minF, maxDispl, meanDispl, minDispl)

	elif CMDoptionsDict['actuatorMesswerte']:

		weg, kraft = [], []

		lineN = 0
		for line in lines:

			currentLineSplit = line.split(';')

			if lineN > 1:
				
				weg += [returnNumber(currentLineSplit[6])]
				kraft += [returnNumber(currentLineSplit[9])]

			lineN += 1
				

		file.close()

		print('\t'+'-> Last computed data point index (file): ' + str(lineN/1000000.0) + ' millions')

		dataFromRun = dataFromRunClassMesswerte(iFile, fileNameShort.split('_')[0]+'_'+fileNameShort.split('_')[1], lineN)

		dataFromRun.add_data(weg, kraft)

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
	line = {'linewidth' : 2, 'markersize' : 2}
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

class dataFromRunClassMesswerte(object):
	"""docstring for dataFromRunClassMesswerte"""
	def __init__(self, id_in, testName_in, lastDataPointCounter_in):
		# super(dataFromRun, self).__init__()

		self.__id = id_in
		self.__name = testName_in
		self.__lastDataPointCounter = lastDataPointCounter_in

	def add_data(self, weg_in, kraft_in):
		
		self.__weg = weg_in
		self.__kraft = kraft_in

	def get_lastDataPointCounter(self):
		return self.__id
	def get_name(self):
		return self.__name
	def get_weg(self):
		return self.__weg
	def get_kraft(self):
		return self.__kraft
	def get_lastDataPointCounter(self):
		return self.__lastDataPointCounter

class dataFromRunClass(object):
	"""
	docstring for dataFromRun

	Class contaiting data from a certain run
	"""
	def __init__(self, id_in):
		# super(dataFromRun, self).__init__()

		self.__id = id_in

	def add_data(self, cycleN_in, maxF_in, meanF_in, minF_in, maxDispl_in, meanDispl_in, minDispl_in):

		self.__cycleN = cycleN_in
		self.__cycleN_mill = [d/1000000 for d in cycleN_in]
		self.__maxF = maxF_in 
		self.__meanF = meanF_in 
		self.__minF = minF_in
		self.__maxDispl = maxDispl_in 
		self.__meanDispl = meanDispl_in 
		self.__minDispl = minDispl_in

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
	def get_maxDispl(self):
		return self.__maxDispl
	def get_meanDispl(self):
		return self.__meanDispl
	def get_minDispl(self):
		return self.__minDispl


	def plotSingleRun(self, plotSettings):


		### Plot force applied by the actuator
		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.__cycleN, self.__maxF, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__meanF, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__minF, linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

		ax.legend(**plotSettings['legend'])
		ax.set_title('Results from Run #'+str(self.__id), **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()


		### Plot displacement of actuator
		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.__cycleN, self.__maxDispl, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max displacement', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__meanDispl, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean displacement', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__minDispl, linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min displacement', **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

		ax.legend(**plotSettings['legend'])
		ax.set_title('Results from Run #'+str(self.__id), **plotSettings['title'])

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

		self.__prescribedLoadsTO = []

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

	def set_prescribedLoadsTO(self, loads):
		
		self.__prescribedLoadsTO = loads

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

	def plotMaxMinMean_fromDIAdem(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.__timeMax, self.__max, linestyle = '', marker = '+', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.__timeMean, self.__mean, linestyle = '', marker = '+', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.__timeMin, self.__min, linestyle = '', marker = '+', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		#Division line for runs
		maxPlot = self.__max[-1]*1.2
		minPlot = self.__min[-1]*1.2
		ax.plot(2*[0.0], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		for div in self.__timeSecNewRunMean:
			ax.plot(2*[div], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [N]', **plotSettings['axes_y'])
		
		ax.legend(**plotSettings['legend'])
		ax.set_title(self.__description, **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

	def plotResampled(self, plotSettings, CMDoptionsDict):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.__timeRs, self.__rs, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Measured force', **plotSettings['line'])

		#Division line for runs
		maxPlot_y = max(self.__rs)*1.2
		minPlot_y = min(self.__rs)*1.2
		ax.plot(2*[0.0], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		for div in self.__timeSecNewRunRs:
			ax.plot(2*[div], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		if CMDoptionsDict['testOrderFlagFromCMD']:
			maxPlot_x = 0.0
			minPlot_x = max(self.__timeSecNewRunRs)
			for limitLoad in self.__prescribedLoadsTO:
				ax.plot([minPlot_x, maxPlot_x], 2*[limitLoad], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])

		ax.set_xlabel('Number of points [Millions]', **plotSettings['axes_x'])

		if self.__description in ('DistanceSensor'):
			ax.set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

		elif self.__description in ('DistanceSensor', 'BendingMoment', 'MyBlade', 'MyLoadcell', 'MzBlade'):
			ax.set_ylabel('Moment [Nm]', **plotSettings['axes_y'])

		else:
			ax.set_ylabel('Force [N]', **plotSettings['axes_y'])

		#Legend and title
		# ax.legend(**plotSettings['legend'])
		ax.set_title(self.__description, **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

		#Save figure
		if CMDoptionsDict['saveFigure']:

			figure.savefig(os.path.join(CMDoptionsDict['cwd'], self.__description+'.png'))

	def plotMinMeanMax(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)

		ax.plot(self.__timePicks, self.__maxPicks, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.__timePicks, self.__meanPicks, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.__timePicks, self.__minPicks, linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		#Division line for runs
		maxPlot = max(self.__maxPicks)*1.2
		minPlot = min(self.__minPicks)*1.2
		ax.plot(2*[0.0], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		for div in self.__timeSecNewRunPicks:
			ax.plot(2*[div], [minPlot, maxPlot], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [N]', **plotSettings['axes_y'])

		#Legend and title
		ax.legend(**plotSettings['legend'])
		ax.set_title(self.__description, **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

		print('\n')
		print('--> Maximum force applied in complete test (mean value):'+str(round(np.mean(self.__maxPicks), 3))+' N')
		print('--> Mean force applied in complete test (mean value):'+str(round(np.mean(self.__meanPicks), 3))+' N')
		print('--> Minimum force applied in complete test (mean value):'+str(round(np.mean(self.__minPicks), 3))+' N')

def plotAllRuns_force(dataFromRuns, plotSettings, CMDoptionsDict):

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

	#Plot prescribed loads from the T
	if CMDoptionsDict['testOrderFlagFromCMD']:
		ax.plot([0.0, dataFromRuns[-1].get_absoluteNCycles_mill()[-1]], 2*[CMDoptionsDict['testOrderRange'][0]], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])
		ax.plot([0.0, dataFromRuns[-1].get_absoluteNCycles_mill()[-1]], 2*[CMDoptionsDict['testOrderRange'][-1]], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])

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
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])

	#Tick parametersget_xticks
	# majorTicks = ax.get_xmajorticklabels()
	ax.minorticks_on()
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	####
	
	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], 'ActuatorLoads.png'))

def plotAllRuns_force_Messwerte(dataFromRuns, plotSettings, CMDoptionsDict):

	def cumputeDiffFnNotContinous(x, y):
		
		assert len(x)==len(y), 'ERROR: Not equal length for vectors'

		n = len(x)

		diff, pointsID = [], [1]
		for i in range(1,n-1):

			# delta = abs( abs(x[i+1]) - abs(x[i-1]) )
			delta = abs( x[i+1] - x[i-1] )

			f = y[i+1] - y[i-1]

			diff += [f/(2.0*delta)]

			if i > 1:
				pointsID += [pointsID[-1]+1]

		return diff, pointsID

	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	counterPlots = 0
	for data in dataFromRuns:

		ax.plot(data.get_weg(), data.get_kraft(), linestyle = '-', marker = '', c = plotSettings['colors'][counterPlots], label = data.get_name(), **plotSettings['line'])

		counterPlots += 1

	ax.set_xlabel('Displacement [mm]', **plotSettings['axes_x'])
	ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

	#Legend and title
	ax.legend(**plotSettings['legend'])
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()

	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], 'ActuatorForceDisplacement.png'))

	#Central differences plot
	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	counter, dataIdAbs, diffAbs = 0, [], []
	ax.plot(2*[0.0], [-500000, 500000], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
	for data in dataFromRuns:

		diff_temp, pointsID_temp = cumputeDiffFnNotContinous(data.get_weg(), data.get_kraft())

		if counter == 0:
			dataIdAbs += pointsID_temp
		else:
			dataIdAbs += [dataIdAbs[-1]+t for t in pointsID_temp]
		
		# Plot division line
		ax.plot(2*[dataIdAbs[-1]/1000000.0], [-500000, 500000], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		
		diffAbs += diff_temp
		counter += 1

	ax.plot([t/1000000.0 for t in dataIdAbs], diffAbs, linestyle = '-', marker = '', c = plotSettings['colors'][0], **plotSettings['line'])

	ax.set_xlabel('Number of points [Millions]', **plotSettings['axes_x'])
	ax.set_ylabel('Stiffness [mm/kN]', **plotSettings['axes_y'])

	#Legend and title
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()

	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], 'ActuatorForceDisplacement.png'))


def plotAllRuns_displacement(dataFromRuns, plotSettings, CMDoptionsDict):

	def threePlotForRun(dataFromRun, plotSettings, ax):
		
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_maxDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][0], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_meanDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][1], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_minDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][2], **plotSettings['line'])	
	
	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	#Plot first division line
	ax.plot(2*[0.0], [dataFromRuns[0].get_minDispl()[-1]*1.2, dataFromRuns[0].get_maxDispl()[-1]*1.2], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
	for data in dataFromRuns:

		threePlotForRun(data, plotSettings, ax)
		
		#Plot division lines
		ax.plot(2*[data.get_absoluteNCycles_mill()[-1]], [data.get_minDispl()[-1]*1.2, data.get_maxDispl()[-1]*1.2], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

	ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
	ax.set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

	# Legends
	legendHandles = []
	handle0 = plt.Line2D([],[], color=plotSettings['colors'][0], marker='+', linestyle='', label='Max displacement')
	handle1 = plt.Line2D([],[], color=plotSettings['colors'][1], marker='+', linestyle='', label='Mean displacement')
	handle2 = plt.Line2D([],[], color=plotSettings['colors'][2], marker='+', linestyle='', label='Min displacement')
	legendHandles = legendHandles + [handle0, handle1, handle2]
	ax.legend(handles = legendHandles, **plotSettings['legend'])

	#Title
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])

	#Tick parametersget_xticks
	# majorTicks = ax.get_xmajorticklabels()
	ax.minorticks_on()
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	####

	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], 'ActuatorDisplacement.png'))

def calculate_stats(dataFromRuns):

	def roundToOneSignificant(x):

		return round(x, -int(math.floor(math.log10(abs(x)))))

	def truncateToSignificantOfOtherNum(num, numRef):

		i, i_out, flagPositive = 0, 0, True

		if num < 0.0:
			flagPositive = False
			num = num *-1.0

		for n in str(float(abs(numRef))):

			if not n in ('.','0'):

				i_out = i
				break

			i += 1

		if i == 0: #Number bigger than 0
			if flagPositive:
				return float(str(num)[:-(len(str(abs(numRef)))-2)]+((len(str(abs(numRef)))-2)*'0'))
			else:
				print('hole')
				return -1.0*float(str(num)[:-(len(str(abs(numRef)))-2)]+((len(str(abs(numRef)))-2)*'0'))

		else:

			if flagPositive:
				return float(str(num)[:i_out+1])
			else:
				return -1.0*float(str(num)[:i_out+1])


	maxs = []
	mins = []
	means = []

	normalDistributionFlag = True
	confidenceIntervalForTstudent = 95 #in %

	for dataFromRun in dataFromRuns:

		maxs += dataFromRun.get_maxF()
		means += dataFromRun.get_meanF()
		mins += dataFromRun.get_minF()
		
	
	#Calculate stats using t-Student distribution
	mean_max = np.mean(maxs)
	mean_mean = np.mean(means)
	mean_min = np.mean(mins)

	std_max = np.std(maxs)
	std_mean = np.std(means)
	std_min = np.std(mins)

	intervals_max = st.t.interval(confidenceIntervalForTstudent/100.0, len(maxs)-1, loc=mean_max, scale=st.sem(maxs))
	intervals_mean = st.t.interval(confidenceIntervalForTstudent/100.0, len(means)-1, loc=mean_mean, scale=st.sem(means))
	intervals_min = st.t.interval(confidenceIntervalForTstudent/100.0, len(mins)-1, loc=mean_min, scale=st.sem(mins))

	#Intervals
	if normalDistributionFlag:
		interval_max = roundToOneSignificant(1.96 * std_max)
		interval_mean = roundToOneSignificant(1.96 * std_mean)
		interval_min = roundToOneSignificant(1.96 * std_min)
	else:
		interval_max = roundToOneSignificant(abs(intervals_max[1] - intervals_max[0]))
		interval_mean = roundToOneSignificant(abs(intervals_mean[1] - intervals_mean[0]))
		interval_min = roundToOneSignificant(abs(intervals_min[1] - intervals_min[0]))

	# pdb.set_trace()

	print('\n'+'-> Range for max values: '+str(truncateToSignificantOfOtherNum(mean_max, interval_max)) + '+-'+ str(interval_max)+' KN (for 95% confidence interval)')
	print('-> Range for mean values: '+str(truncateToSignificantOfOtherNum(mean_mean, interval_mean)) + '+-'+ str(interval_mean)+' KN (for 95% confidence interval)')
	print('-> Range for min values: '+str(truncateToSignificantOfOtherNum(mean_min, interval_min)) + '+-'+ str(interval_min)+' KN (for 95% confidence interval)')
