# Collection of functions
import pdb
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import statistics as stat
import math
import getopt
import pdb #pdb.set_trace()


###### Functions
def readCMDoptionsMainAbaqusParametric(argv, CMDoptionsDict):

	short_opts = "f:v:m:o:s:r:a:c:n:" #"o:f:"
	long_opts = ["fileName=","variables=","magnitudes=","testOrder=","saveFigure=","rangeFileIDs=","additionalCals=","correctionFilter=", "multipleYaxisInSameFigure="] #["option=","fileName="]
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
			CMDoptionsDict['fileNameOfFileToLoadFiles'] = os.path.join(CMDoptionsDict['cwd'], 'fatigueInputFiles',arg)

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
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

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
				raise ValueError('ERROR: Wrong input for parameter '+opt)

		elif opt in ("-s", "--saveFigure"):

			argSaveFigure= arg.split(',')[0]
			argShowFigure= arg.split(',')[1]

			if argSaveFigure.lower() in ('true', 't'):
				CMDoptionsDict['saveFigure'] = True
			elif argSaveFigure.lower() in ('false', 'f'):
				CMDoptionsDict['saveFigure'] = False

			if argShowFigure.lower() in ('true', 't'):
				CMDoptionsDict['showFigures'] = True
			elif argShowFigure.lower() in ('false', 'f'):
				CMDoptionsDict['showFigures'] = False
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

		elif opt in ("-r", "--rangeFileIDs"):

			CMDoptionsDict['rangeFileIDs'] = [int(t) for t in arg.split(',')]

		elif opt in ("-a", "--additionalCals"):

			if arg.lower() in ('false', 'f'):
				CMDoptionsDict['additionalCalsFlag'] = False
			else:
				CMDoptionsDict['additionalCalsFlag'] = True
				CMDoptionsDict['additionalCalsOpt'] = int(arg)

		elif opt in ("-c", "--correctionFilter"):

			if arg.lower() in ('false', 'f'):
				CMDoptionsDict['correctionFilterFlag'] = False
			else:
				CMDoptionsDict['correctionFilterFlag'] = True
				CMDoptionsDict['correctionFilterNum'] = float(arg)

		elif opt in ("-n", "--multipleYaxisInSameFigure"):

			if arg.lower() in ('true', 't'):
				CMDoptionsDict['multipleYaxisInSameFigure'] = True
				CMDoptionsDict['numberMultipleYaxisInSameFigure'] = max(len(CMDoptionsDict['variables']),len(CMDoptionsDict['magnitudes']))
			elif arg.lower() in ('false', 'f'):
				CMDoptionsDict['multipleYaxisInSameFigure'] = False
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

	return CMDoptionsDict

def sortFilesInFolderByLastNumberInName(listOfFiles, CMDoptionsDict):

	a = []
	for file in listOfFiles:
		if file.endswith('.csv'):
			fileID_0 = file.split('.csv')[0]
			fileID_int = int(fileID_0.split('__')[-1])
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

class dataForVariable(object):
	"""docstring for dataForVariable"""
	def __init__(self):
		self.__name = []
		self.__xLabel = []
		self.__staticLoad = []
		self.__alternateLoad = []
		self.__maxLoad = []
		self.__minLoad = []

	def set_attr(self, attr_string, value):
		
		self.setattr('__'+attr_string, value)

	def get_attr(self, attr_string):
		
		return self.getattr('__'+attr_string)
		

def loadFileAddressesAndData(fileName, typeData):

	def addSectionsInfoActuator(rawLine, section_index, inputDataClass):
		
		cleanLine = cleanString(rawLine)
		
		if section_index == 1:
			inputDataClass.addSharedAddress(cleanLine)

		elif section_index == 2:

			inputDataClass.addDataFromTestOrder([float(t) for t in cleanLine.split(',')])

		return inputDataClass

	
	def addSectionsInfoGauge(rawLine, section_index, inputDataClass):
		
		cleanLine = cleanString(rawLine)

		if section_index == 1:
			inputDataClass.addSharedAddress(cleanString(rawLine))

		elif section_index == 2:

			variableStringKey = cleanLine.split(':')[0]
			valueLine0 = cleanLine.split(':')[1]
			valueLine = valueLine0.lstrip()

			if 'BLABLA':

				pass

			if 'name' in cleanLine:

				variableStringKey = valueLine


	file = open(fileName, 'r')

	lines = file.readlines()

	inputDataClass = inputDataClassDef()

	newSectionIdentifier = '->'

	section_index = 0

	for i in range(0, int((len(lines)))):

		rawLine = lines[i]

		if cleanString(rawLine) != '': #Filter out blank lines

			if newSectionIdentifier in rawLine: #Header detected, change to new sections

				section_index += 1
				
			elif typeData == 'actuator':

				inputDataClass = addSectionsInfoActuator(rawLine, section_index, inputDataClass)

			elif typeData == 'gauge':

				inputDataClass = addSectionsInfoGauge(rawLine, section_index, inputDataClass)

	file.close()

	return inputDataClass

class inputDataClassDef(object):
	"""docstring for inputData"""
	def __init__(self):
		"""
		Initializes the class with local address and empty directory of shared folders
		"""

		self.__setOfAddress_tuple = ()
		self.__testOrderRange = []
		self.__variablesInfoDict= {}

	def addSharedAddress(self, fileAddress):

		if os.path.isfile(fileAddress) or os.path.isdir(fileAddress):

			self.__setOfAddress_tuple += (fileAddress,)

		else:

			print('WARNING: Address '+fileAddress+' does not exist or is not a directory, entry skipped')

	def addDataFromTestOrder(self, testOrderRange_in):
		self.__testOrderRange = testOrderRange_in

	def getTupleFiles(self):

		return self.__setOfAddress_tuple

	def get_testOrderRange(self):
		return self.__testOrderRange

	def addVariablesInfoDict(self, variableStringKey, variableClass):

		if not 'variableStringKey' in self.__variablesInfoDict.keys():
			self.__variablesInfoDict['variableStringKey'] = variableClass
		else:
			self.__variablesInfoDict.update({'variableStringKey': variableClass})

	def get_variablesInfoDict(self):
		return self.__variablesInfoDict


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

		dataFromRun.add_data(cycleN, maxF, meanF, minF, maxDispl, meanDispl, minDispl, int(fileNameShort.split('_')[1]))

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
	colors = ['k', 'b', 'y', 'm', 'r', 'c', 'g', 'k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c']
	markers = ['o', 'v', '^', 's', '*', '+']
	linestyles = ['-', '--', '-.', ':']
	axes_ticks_n = {'x_axis' : 3} #Number of minor labels in between 

	plotSettings = {'axes_x':axes_label_x,'axes_y':axes_label_y, 'title':text_title_properties,
	                'axesTicks':axes_ticks, 'line':line, 'legend':legend, 'grid':grid, 'scatter':scatter,
	                'colors' : colors, 'markers' : markers, 'linestyles' : linestyles, 'axes_ticks_n' : axes_ticks_n}

	# Additional computing data
	plotSettings['currentAxis'] = [None, -1] #[Axis object, index]
	plotSettings['listMultipleAxes'] = None
	plotSettings['currentFigureMultipleAxes'] = None


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

	def add_data(self, cycleN_in, maxF_in, meanF_in, minF_in, maxDispl_in, meanDispl_in, minDispl_in, stepID_in):

		self.__cycleN = cycleN_in
		self.__cycleN_mill = [d/1000000 for d in cycleN_in]
		self.__maxF = maxF_in 
		self.__meanF = meanF_in 
		self.__minF = minF_in
		self.__maxDispl = maxDispl_in 
		self.__meanDispl = meanDispl_in 
		self.__minDispl = minDispl_in
		self.__stepID = stepID_in 

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
	def get_stepID(self):
		return self.__stepID


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

		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.set_ylim(ax.get_ylim())


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

		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.set_ylim(ax.get_ylim())

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
		self.__prescribedLoadsTOLimits = []

		self.__max = []
		self.__mean = []
		self.__min = []
		self.__rs = []

		self.__MinMax = []

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
		self.__freqData = []
		self.__filterData = []
		self.__xValues = []
		self.__xValuesNewRun = []
		self.__stepID = []

	def set_prescribedLoadsTO(self, loads_in):
		
		self.__prescribedLoadsTO = loads_in

	def set_prescribedLoadsTOLimits(self, loads_in):
		
		self.__prescribedLoadsTOLimits = loads_in

	def reStartXvaluesAndLastID(self):
		self.__lastID = 0
		self.__xValues = []
		self.__xValuesNewRun = []

	def set_magData(self, nameField, data):

		if nameField in ('rs','lp','hp'):
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

		print('\n'+'----> Last computed time point for test: ' + str(timeSec[-1]/1000000) + ' millions / '+calculateDaysHoursMinutes_string(timeSec[-1], self.__freqData[-1]))

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

	def importDataForClass(self, fileName, fieldOfFile, CMDoptionsDict):

		file = open(fileName, 'r')
		lines = file.readlines()

		skipLines, dataID, data, counter = 0, [], [], 0

		for line in lines[(skipLines+1):]:

			if CMDoptionsDict['correctionFilterFlag'] and fieldOfFile in ('lp', 'hp'):
				data += [float(cleanString(line)) + CMDoptionsDict['correctionFilterNum']]
			else:
				data += [float(cleanString(line))]

			if counter == 0: #First iteration
				dataID += [self.__lastID+1]
			else:
				dataID += [dataID[-1]+1]

			counter += 1
		
		file.close()

		if CMDoptionsDict['correctionFilterFlag'] and fieldOfFile in ('lp', 'hp'):
			print('\t'+'-> Correction applied to each imported data point, value: '+str(CMDoptionsDict['correctionFilterNum']))

		self.set_magData(fieldOfFile, data)

		# Remove outliers and calculate max and min
		flagOutliers = True
		if flagOutliers and fieldOfFile in ('lp', 'hp'):

			# split in ranges
			range_spacing = 10000
			size_vector = len(data)
			intervals = int(np.floor(size_vector/range_spacing))
			x_range_interest, y_range_interest, x_range_interest_2, y_range_interest_2 = [], [], [], []

			for i in range(intervals):

				x_range = data[int(i*range_spacing):int((i+1)*range_spacing)]

				x_range_interest += [max(x_range)]
				y_range_interest += [x_range.index(max(x_range)) + 1] #Index of the vector starts with 0, the first y value is 1
				
				x_range_interest_2 += [min(x_range)]
				y_range_interest_2 += [x_range.index(min(x_range)) + 1] #Index of the vector starts with 0, the first y value is 1
				# print(str(i))


			x_range_woOutliers, y_range_woOutliers = getNewVectorWithoutOutliers(x_range_interest, y_range_interest)
			x_range_woOutliers_2, y_range_woOutliers_2 = getNewVectorWithoutOutliers(x_range_interest_2, y_range_interest_2)

			if fieldOfFile in ('hp'):
				self.__MinMax += [[max(min(x_range_woOutliers), abs(max(x_range_woOutliers_2))), min(max(x_range_woOutliers), abs(min(x_range_woOutliers_2)))]]
			elif fieldOfFile in ('lp'):
				self.__MinMax += [[min(x_range_woOutliers), max(x_range_woOutliers)]] #This is not the way this should work, SOMETHING IS WRONG- Removal of outliers does not work

		else:
			# Min and max
			self.__MinMax += [[min(data), max(data)]]
		
		self.__lastID = dataID[-1]

		self.__xValuesNewRun += [dataID[-1],]

		self.__xValues += dataID
		
		# Obtain step index
		fileName_0 = fileName.split('.csv')[0]
		self.__stepID += [int(fileName_0.split('__')[-1])]

		#Obtain frequency for recorded data
		if fieldOfFile in ('lp', 'hp'):
			self.__filterData += [float(fileName_0.split('__')[-2][:-2])]
			self.__freqData += [float(fileName_0.split('__')[-3][:-2])]
		else:
			self.__freqData += [float(fileName_0.split('__')[-2][:-2])]

		# Last computed point stats
		print('\t'+'-> Last computed data point index (file): ' + str(counter/1000000.0) + ' millions / '+calculateDaysHoursMinutes_string(counter, self.__freqData[-1]))
		print('\t'+'-> Max and min values read (file), max: ' + str(max(data)) + ', min: '+str(min(data)))

		if flagOutliers and fieldOfFile in ('lp', 'hp'):
			print('\t'+'-> Max and min values without outliers (file), max: ' + str(round(self.__MinMax[-1][1], 2)) + ', min: '+str(round(self.__MinMax[-1][0], 2)))
		
		if fieldOfFile in ('rs', 'lp', 'hp'):
			print('\t'+'-> Last computed data point index (accumulated): ' + str(dataID[-1]/1000000.0) + ' millions / '+calculateDaysHoursMinutes_string(dataID[-1], self.__freqData[-1]))

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
	def get_freqData(self):
		return self.__freqData
	def get_timeRs(self):
		return self.__timeRs
	def get_rs(self):
		return self.__rs
	def get_timeSecNewRunRs(self):
		return self.__timeSecNewRunRs
	def get_stepID(self):
		return self.__stepID

	def addDataManual1(self, dataClasses):
		"""
		Customized function to calculate the fighting force
		"""
		forceHP1 = []
		forceHP2 = []
		result = []

		for dataClass in dataClasses:

			if dataClass.get_description() in ('ForcePistonEyeHP1'):
				forceHP1 = dataClass.get_rs()
				oneClass = dataClass

			elif dataClass.get_description() in ('ForcePistonEyeHP2'):
				forceHP2 = dataClass.get_rs()

		for f1, f2 in zip(forceHP1, forceHP2):

			result += [f1-f2]

		self.__rs = result
		self.__freqData = oneClass.get_freqData()
		self.__timeRs = oneClass.get_timeRs()
		self.__timeSecNewRunRs = oneClass.get_timeSecNewRunRs()
		self.__stepID = oneClass.get_stepID()

	def addDataManual2(self, dataClasses):
		"""
		Customized function to calculate the fighting force
		"""
		forceHP1 = []
		forceHP2 = []
		result = []

		for dataClass in dataClasses:

			if dataClass.get_description() in ('ForcePistonEyeHP1'):
				forceHP1 = dataClass.get_rs()
				oneClass = dataClass

			elif dataClass.get_description() in ('ForcePistonEyeHP2'):
				forceHP2 = dataClass.get_rs()

		for f1, f2 in zip(forceHP1, forceHP2):

			result += [f1+f2]

		self.__rs = result
		self.__freqData = oneClass.get_freqData()
		self.__timeRs = oneClass.get_timeRs()
		self.__timeSecNewRunRs = oneClass.get_timeSecNewRunRs()
		self.__stepID = oneClass.get_stepID()

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

		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.set_ylim(ax.get_ylim())

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

	def plotResampled(self, plotSettings, CMDoptionsDict, magnitude, additionalInput, inputDataClass):

		if CMDoptionsDict['multipleYaxisInSameFigure'] and plotSettings['currentAxis'][1] == -1:
			figure, axesList = plt.subplots(CMDoptionsDict['numberMultipleYaxisInSameFigure'], 1, sharex='col')
			figure.set_size_inches(12, 8, forward=True)
			plotSettings.update({'listMultipleAxes': axesList})
			plotSettings.update({'currentFigureMultipleAxes': figure})

			ax = axesList[0]
			plotSettings.update({'currentAxis': [ax, 0]})

		elif CMDoptionsDict['multipleYaxisInSameFigure'] and plotSettings['currentAxis'][1] != -1:
			
			new_ax_id = plotSettings['currentAxis'][1]+1
			ax = plotSettings['listMultipleAxes'][new_ax_id]
			plotSettings.update({'currentAxis': [ax, new_ax_id]})
		else:
			# Normal operation, one single plot
			figure, ax = plt.subplots(1, 1)
			figure.set_size_inches(10, 6, forward=True)

		ax.plot( [t/self.__freqData[0] for t in self.__timeRs], self.__rs, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = self.__description, **plotSettings['line'])

		# Mean based on max and min
		mean_min = np.mean([setOne[0] for setOne in self.__MinMax])
		mean_max = np.mean([setOne[1] for setOne in self.__MinMax])

		mean_fromMinMax = ((mean_max - mean_min)/2) + mean_min

		print('mean record data :'+str(mean_fromMinMax))

		if additionalInput[0]:
			dataClasses = additionalInput[1]
			for dataClass in dataClasses:
				if dataClass.get_description() in (additionalInput[2]):
					oneClass = dataClass
		
			ax.plot( [t/oneClass.get_freqData()[0] for t in oneClass.get_timeRs()], oneClass.get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][1], label = oneClass.get_description(), **plotSettings['line'])
		
		#Division line for runs
		valuesMaxRs = ax.get_ylim()[1]
		valuesMinRs = ax.get_ylim()[0]
		maxPlot_y = valuesMaxRs*1.2 if valuesMaxRs > 0.0 else valuesMaxRs*0.8
		minPlot_y = valuesMinRs*0.8 if valuesMinRs > 0.0 else valuesMinRs*1.2
		previousDiv = 0.0
		i = 0
		ax.plot(2*[0.0], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
		for div in [t/self.__freqData[0] for t in self.__timeSecNewRunRs]:
			ax.plot(2*[div], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

			#Add text with step number
			ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, 'Step '+str(self.__stepID[i]), bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')
			# ax.text(previousDiv + ((div - previousDiv)/2), 500, 'Step '+str(self.__stepID[i]), bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')
			
			previousDiv = div
			i += 1

		if CMDoptionsDict['testOrderFlagFromCMD']:
			maxPlot_x = 0.0
			minPlot_x = max(self.__timeSecNewRunRs)/self.__freqData[0]
			for limitLoad in self.__prescribedLoadsTO:
				ax.plot([minPlot_x, maxPlot_x], 2*[limitLoad], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])
				if self.__prescribedLoadsTOLimits:
					for limitLoadBoundary in self.__prescribedLoadsTOLimits:
						ax.plot([minPlot_x, maxPlot_x], 2*[limitLoad*limitLoadBoundary], linestyle = '-.', marker = '', c = plotSettings['colors'][6], **plotSettings['line'])

		# ax.set_xlabel('Number of points [Millions]', **plotSettings['axes_x'])
		# ax.set_xlabel('Time elapsed [Million seconds]', **plotSettings['axes_x'])
		if not CMDoptionsDict['multipleYaxisInSameFigure']:
			ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])
		elif CMDoptionsDict['numberMultipleYaxisInSameFigure']==(plotSettings['currentAxis'][1]+1):
			ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

		if True:
			ax.set_ylabel(inputDataClass.get_variablesInfoDict()[self.__description].get_attr('xLabel'), **plotSettings['axes_y'])
		elif self.__description in ('DistanceSensor'):
			ax.set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

		elif self.__description in ('DistanceSensor', 'BendingMoment', 'MyBlade', 'MyLoadcell', 'MzBlade'):
			ax.set_ylabel('Moment [Nm]', **plotSettings['axes_y'])

		elif self.__description in ('STG1', 'STG2', 'SpiderStrain'):
			ax.set_ylabel('Strain [mm\m]', **plotSettings['axes_y'])

		# Magnitudes from the performance test
		elif self.__description in ('DruckHP1', 'DruckHP2'):
			ax.set_ylabel('Pressure [bar]', **plotSettings['axes_y'])

		elif self.__description in ('DurchflussHP1', 'DurchflussHP2'):
			ax.set_ylabel('Volume flow [l/min]', **plotSettings['axes_y'])

		elif self.__description in ('LaserPiston', 'LaserSteuerventilhebel'):
			ax.set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

		elif self.__description in ('TemperaturHP1', 'TemperaturHP2'):
			ax.set_ylabel('Temperature [°C]', **plotSettings['axes_y'])

		else:
			ax.set_ylabel('Force [N]', **plotSettings['axes_y'])

		#Legend and title
		if additionalInput[0]:
			ax.legend(**plotSettings['legend'])
		else:
			if magnitude == 'rs':
				ax.set_title(self.__description+', re-sampled data to '+str(int(self.__freqData[0]))+' Hz', **plotSettings['title'])
			elif magnitude == 'lp':
				a = self.__filterData[0]
				ax.set_title(self.__description+', low-pass filtered with '+str(float(self.__filterData[0]))+' Hz cut-off freq.', **plotSettings['title'])
			elif magnitude == 'hp':
				ax.set_title(self.__description+', high-pass filtered with '+str(float(self.__filterData[0]))+' Hz cut-off freq.', **plotSettings['title'])
			else:
				ax.set_title(self.__description, **plotSettings['title'])

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.set_ylim(ax.get_ylim())

		#Save figure
		if CMDoptionsDict['saveFigure'] and not CMDoptionsDict['multipleYaxisInSameFigure']:

			if additionalInput[0]:
				figure.savefig(os.path.join(CMDoptionsDict['cwd'], magnitude+'_'+','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+'_'+self.__description+'&'+additionalInput[2]+'.png'))
			else: 
				figure.savefig(os.path.join(CMDoptionsDict['cwd'], magnitude+'_'+','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+'_'+self.__description+'.png'))
		elif CMDoptionsDict['saveFigure'] and CMDoptionsDict['numberMultipleYaxisInSameFigure']==(plotSettings['currentAxis'][1]+1): #CMDoptionsDict['multipleYaxisInSameFigure'] is True

			figure = plotSettings['currentFigureMultipleAxes']
			figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['magnitudes']])+'_'+','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+'_'+','.join([str(i) for i in CMDoptionsDict['variables']])+'.png'))

		return plotSettings

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

		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.set_ylim(ax.get_ylim())

		print('\n')
		print('--> Maximum force applied in complete test (mean value):'+str(round(np.mean(self.__maxPicks), 3))+' N')
		print('--> Mean force applied in complete test (mean value):'+str(round(np.mean(self.__meanPicks), 3))+' N')
		print('--> Minimum force applied in complete test (mean value):'+str(round(np.mean(self.__minPicks), 3))+' N')

def plotAllRuns_force(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass):

	def threePlotForRun(dataFromRun, plotSettings, ax):
		
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_maxF(), linestyle = '-', marker = '', c = plotSettings['colors'][0], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_meanF(), linestyle = '-', marker = '', c = plotSettings['colors'][1], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_minF(), linestyle = '-', marker = '', c = plotSettings['colors'][2], **plotSettings['line'])	
	
	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	# Plot all the data
	for data in dataFromRuns:

		threePlotForRun(data, plotSettings, ax)

	#Plot first division line
	valuesMaxRs = ax.get_ylim()[1]
	valuesMinRs = ax.get_ylim()[0]
	maxPlot_y = valuesMaxRs*1.2 if valuesMaxRs > 0.0 else valuesMaxRs*0.8
	minPlot_y = valuesMinRs*0.8 if valuesMinRs > 0.0 else valuesMinRs*1.2
	previousDiv = 0.0
	ax.plot(2*[0.0], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
	for data in dataFromRuns:
		
		div = data.get_absoluteNCycles_mill()[-1]
		#Plot division lines
		ax.plot(2*[div], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		# Plot text with step index
		ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, 'Step '+str(data.get_stepID()), bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')

		previousDiv = div
	
	#Plot prescribed loads from the T
	if CMDoptionsDict['testOrderFlagFromCMD']:
		ax.plot([0.0, dataFromRuns[-1].get_absoluteNCycles_mill()[-1]], 2*[inputDataClass.get_testOrderRange()[0]], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])
		ax.plot([0.0, dataFromRuns[-1].get_absoluteNCycles_mill()[-1]], 2*[inputDataClass.get_testOrderRange()[-1]], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])

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

	#Figure plotSettings
	ax.grid(which='both', **plotSettings['grid'])

	#Tick parameters
	ax.minorticks_on()
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	####

	#Double y-axis 
	axdouble_in_y = ax.twinx()
	axdouble_in_y.minorticks_on()
	axdouble_in_y.set_ylim(ax.get_ylim())
	
	#Tick parametersget_xticks
	# majorTicks = ax.get_xmajorticklabels()
	# ax.minorticks_on()
	# ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	####
	
	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], 'ActuatorLoads.png'))


def plotAllRuns_force_Messwerte(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass):

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

	#Double y-axis 
	axdouble_in_y = ax.twinx()
	axdouble_in_y.set_ylim(ax.get_ylim())

	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], 'ActuatorForceDisplacement.png'))


def plotAllRuns_displacement(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass):

	def threePlotForRun(dataFromRun, plotSettings, ax):
		
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_maxDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][0], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_meanDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][1], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_minDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][2], **plotSettings['line'])	
	
	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(10, 6, forward=True)

	# Plot all the data
	for data in dataFromRuns:

		threePlotForRun(data, plotSettings, ax)

	#Plot first division line
	valuesMaxRs = ax.get_ylim()[1]
	valuesMinRs = ax.get_ylim()[0]
	maxPlot_y = valuesMaxRs*1.2 if valuesMaxRs > 0.0 else valuesMaxRs*0.8
	minPlot_y = valuesMinRs*0.8 if valuesMinRs > 0.0 else valuesMinRs*1.2
	previousDiv = 0.0
	ax.plot(2*[0.0], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
	for data in dataFromRuns:

		# threePlotForRun(data, plotSettings, ax)
		
		div = data.get_absoluteNCycles_mill()[-1]
		#Plot division lines
		ax.plot(2*[div], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		# Plot text with step index
		ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, 'Step '+str(data.get_stepID()), bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')

		previousDiv = div
	
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

	#Tick parameters
	ax.minorticks_on()
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	####

	#Double y-axis 
	axdouble_in_y = ax.twinx()
	axdouble_in_y.minorticks_on()
	axdouble_in_y.set_ylim(ax.get_ylim())

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

def calculateDaysHoursMinutes_string(N, freq):
	
	seconds = N/freq

	n_days = int(np.floor(seconds/(24*3600)))
	remainingSeconds = seconds - (24*3600*n_days)
	n_hours = int(np.floor(remainingSeconds/(3600)))
	remainingSeconds = remainingSeconds - (3600*n_hours)
	n_minutes = int(np.floor(remainingSeconds/(60)))
	remainingSeconds = remainingSeconds - (60*n_minutes)

	totalTimeString = str(n_days)+' days, '+str(n_hours)+' hours, '+str(n_minutes)+' minutes, '+str(round(remainingSeconds, 2))+' seconds ('+str(freq)+' Hz)'

	return totalTimeString

def getNewVectorWithoutOutliers(x_list, y_list):
	######### Enter, x_list and y_list values

	# Error vector
	def errorVectorFunction(x_list, y_list, regre):

		# Error vector
		e = []
		for x,y in zip(x_list, y_list):
			e += [y - ( regre[1] + (regre[0]*x) )] 
		vari = stat.variance(e)

		return e, vari

	# Remove outliers
	def removeOutliers(x_list, y_list, e_list, vari_error, lim):
		
		# New vectors
		x_out, y_out, outliers = [], [], []
		for x,y,e in zip(x_list, y_list, e_list):

			factor = abs(e) / np.sqrt(vari_error)

			if factor > lim:
				outliers += [[x, y],]

			else:
				x_out += [x]
				y_out += [y]

		return x_out, y_out, outliers

	assert len(x_list) == len(y_list), 'ERROR: Mismatch between the sizes of x, y'

	# Linear fit
	# f(x) = regre[0]*x_list + regre[1]

	regre = np.polyfit(x_list, y_list, 1)

	error_list, vari = errorVectorFunction(x_list, y_list, regre)

	x_list_woOutliers, y_list_woOutliers, outliers = removeOutliers(x_list, y_list, error_list, vari, 1.960) #2.576

	return x_list_woOutliers, y_list_woOutliers