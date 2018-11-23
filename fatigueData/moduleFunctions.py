# Collection of functions
import pdb
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import scipy.linalg as lalg
from scipy import interpolate
import statistics as stat
import math
import getopt
import pdb #pdb.set_trace()


###### Functions
def readCMDoptionsMainAbaqusParametric(argv, CMDoptionsDict):

	short_opts = "f:v:m:o:s:r:a:c:n:w:l:" #"o:f:"
	long_opts = ["fileName=","variables=","magnitudes=","testOrder=","saveFigure=","rangeFileIDs=","additionalCals=","correctionFilter=", "multipleYaxisInSameFigure=", "writeStepResultsToFileFlag=", "divisionLineForPlotsFlag="] #["option=","fileName="]
	try:
		opts, args = getopt.getopt(argv,short_opts,long_opts)
	except getopt.GetoptError:
		raise ValueError('ERROR: Not correct input to script')

	# check input
	# if len(opts) != len(long_opts):
		# raise ValueError('ERROR: Invalid number of inputs')
	# Initial values, to be overwrited
	for optionToInitiate in ['correctionFilterNum','correctionFilterFlag','axisArrangementOption','testOrderFlagFromCMD', 'writeStepResultsToFileFlag', 'divisionLineForPlotsFlag']:
		CMDoptionsDict[optionToInitiate] = ''
	optsLoaded = []
	for opt, arg in opts:

		optsLoaded += [opt]

		if opt in ("-f", "--fileName"):
			# postProcFolderName = arg
			CMDoptionsDict['fileNameOfFileToLoadFiles'] = os.path.join(CMDoptionsDict['cwd'], 'InputFiles',arg)

			if 'actuatormesswerte' in arg.lower():
				CMDoptionsDict['actuatorMesswerte'] = True
				CMDoptionsDict['actuatorFlag'] = False
				CMDoptionsDict['dmsFlag'] = False
			elif 'general' in arg.lower():
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
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

			if argShowFigure.lower() in ('true', 't'):
				CMDoptionsDict['showFigures'] = True
			elif argShowFigure.lower() in ('false', 'f'):
				CMDoptionsDict['showFigures'] = False
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

		elif opt in ("-r", "--rangeFileIDs"):

			# CMDoptionsDict['rangeFileIDs'] = [int(t) for t in arg.split(',')]
			CMDoptionsDict['rangeFileIDs'] = arg.split(',')

		elif opt in ("-a", "--additionalCals"):

			if arg.lower() in ('false', 'f'):
				CMDoptionsDict['additionalCalsFlag'] = False
				CMDoptionsDict['additionalCalsOpt'] = 0
			else:
				CMDoptionsDict['additionalCalsFlag'] = True
				CMDoptionsDict['additionalCalsOpt'] = float(arg)

		elif opt in ("-c", "--correctionFilter"):

			if arg.lower() in ('false', 'f'):
				CMDoptionsDict['correctionFilterFlag'] = False
			elif arg.lower() in ('true', 't'):
				CMDoptionsDict['correctionFilterFlag'] = True
				CMDoptionsDict['correctionFilterNum'] = float(arg)
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

		elif opt in ("-n", "--multipleYaxisInSameFigure"):

			argSplit = arg.split(',')

			CMDoptionsDict['axisArrangementOption'] = arg
			if arg[0].lower() in ('true', 't', '2', '3'):
				CMDoptionsDict['multipleYaxisInSameFigure'] = True
				CMDoptionsDict['oneVariableInEachAxis'] = False
				if len(argSplit) == 1:
					# Load other options 
					CMDoptionsDict['numberMultipleYaxisInSameFigure'] = max( [len(opt_current[1].split(',')) for opt_current in opts if opt_current[0] in ("-v", "--variables")][0] ,  [len(opt_current[1].split(',')) for opt_current in opts if opt_current[0] in ("-m", "--magnitudes")][0])
				else:
					CMDoptionsDict['numberMultipleYaxisInSameFigure'] = int(argSplit[-1])
			elif arg[0].lower() in ('false', 'f', '1'):
				CMDoptionsDict['multipleYaxisInSameFigure'] = False
				CMDoptionsDict['oneVariableInEachAxis'] = False
			elif arg[0].lower() in ('4'):
				CMDoptionsDict['multipleYaxisInSameFigure'] = False
				CMDoptionsDict['oneVariableInEachAxis'] = True
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

		elif opt in ("-w", "--writeStepResultsToFileFlag"):

			if arg.lower() in ('true', 't'):
				CMDoptionsDict['writeStepResultsToFileFlag'] = True
			elif arg.lower() in ('false', 'f'):
				CMDoptionsDict['writeStepResultsToFileFlag'] = False
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

		elif opt in ("-l", "--divisionLineForPlotsFlag"):

			if arg.lower() in ('true', 't'):
				CMDoptionsDict['divisionLineForPlotsFlag'] = True
			elif arg.lower() in ('false', 'f'):
				CMDoptionsDict['divisionLineForPlotsFlag'] = False
			else:
				raise ValueError('ERROR: Wrong input for parameter '+opt)

	CMDoptionsDict['optsLoaded'] = optsLoaded
	return CMDoptionsDict

class dataForVariable(object): #NOT IN USE
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

	def addSectionsInfoActuator(rawLine, sectionName, inputDataClass):
		
		cleanLine = cleanString(rawLine)
		
		if sectionName == 'Files to load':
			inputDataClass.addSharedAddress(cleanLine)

		elif sectionName == 'Loads upper and lower limits':

			inputDataClass.addDataFromTestOrder([float(t) for t in cleanLine.split(',')])

		return inputDataClass

	def addSectionsInfoActuatorMesswerte(rawLine, sectionName, inputDataClass):
		
		cleanLine = cleanString(rawLine)
		
		if sectionName == 'Files to load':
			inputDataClass.addSharedAddress(cleanLine)

		elif sectionName == 'Signal characteristics actuator':

			variableStringKey2 = cleanLine.split(':')[0]
			variableStringKey1 = variableStringKey2.rstrip()
			variableStringKey = variableStringKey1.rstrip()
			valueLine2 = cleanLine.split(':')[1]
			valueLine1 = valueLine2.lstrip()
			valueLine = valueLine1.rstrip()

			dict_temp_fromClass = inputDataClass.get_actuatorDataInfoDict()

			if not variableStringKey in dict_temp_fromClass.keys():

				inputDataClass.updateActuatorDataInfoDict(variableStringKey, valueLine)

		return inputDataClass

	
	def addSectionsInfoGauge(rawLine, sectionName, inputDataClass, currentVariable):
		
		cleanLine = cleanString(rawLine)
		variableStringKey2 = cleanLine.split(':')[0]
		variableStringKey1 = variableStringKey2.lstrip()
		variableStringKey = variableStringKey1.rstrip()
		
		valueLine2 = cleanLine.split(':')[1]
		valueLine1 = valueLine2.lstrip()
		valueLine = valueLine1.rstrip()

		if sectionName == 'Folders to load':
			inputDataClass.addSharedAddress(cleanLine)

		elif sectionName == 'Variable info':

			if 'name:' in cleanLine:

				currentVariable = valueLine

				dict_temp = {'name' : valueLine}
				inputDataClass.updateVariablesInfoDict(valueLine, dict_temp)

			else:

				dict_temp_fromClass = inputDataClass.get_variablesInfoDict()
				dict_temp = dict_temp_fromClass[currentVariable]
				dict_temp[variableStringKey] = valueLine
				inputDataClass.updateVariablesInfoDict(currentVariable, dict_temp)

		elif sectionName == 'Test info':

			dict_temp_fromClass = inputDataClass.get_variablesInfoDict()
			
			if not 'testData' in dict_temp_fromClass:
				inputDataClass.updateVariablesInfoDict('testData', {})
			else:
				dict_temp_fromClass = inputDataClass.get_variablesInfoDict()
				dict_temp = dict_temp_fromClass['testData']
				dict_temp[variableStringKey] = valueLine
				inputDataClass.updateVariablesInfoDict('testData', dict_temp)

		return inputDataClass, currentVariable

	file = open(fileName, 'r')

	lines = file.readlines()

	inputDataClass = inputDataClassDef()

	newSectionIdentifier = '->'

	section_index, currentVariable, sectionName = 0, None, ''

	for i in range(0, int((len(lines)))):

		cleanLine = cleanString(lines[i])

		if cleanLine != '': #Filter out blank lines

			if newSectionIdentifier in cleanLine: #Header detected, change to new sections

				valueLine2 = cleanLine.split(newSectionIdentifier)[1]
				valueLine1 = valueLine2.lstrip()
				sectionName = valueLine1.rstrip()
				
			elif typeData == 'actuator':

				inputDataClass = addSectionsInfoActuator(cleanLine, sectionName, inputDataClass)

			elif typeData == 'actuatorMesswerte':

				inputDataClass = addSectionsInfoActuatorMesswerte(cleanLine, sectionName, inputDataClass)

			elif typeData == 'gauges':

				inputDataClass, currentVariable = addSectionsInfoGauge(cleanLine, sectionName, inputDataClass, currentVariable)

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
		self.__actuatorDataInfoDict= {}

	def addSharedAddress(self, fileAddress):

		if os.path.isfile(fileAddress) or os.path.isdir(fileAddress):

			self.__setOfAddress_tuple += (fileAddress,)

		else:

			raise ValueError('ERROR: Address '+fileAddress+' does not exist or is not a directory')


	def updateActuatorDataInfoDict(self, variableStringKey, variableDict):

		self.__actuatorDataInfoDict.update({variableStringKey: variableDict})

	def get_actuatorDataInfoDict(self):
		return self.__actuatorDataInfoDict

	def addDataFromTestOrder(self, testOrderRange_in):
		self.__testOrderRange = testOrderRange_in

	def getTupleFiles(self):

		return self.__setOfAddress_tuple

	def get_testOrderRange(self):
		return self.__testOrderRange

	def updateVariablesInfoDict(self, variableStringKey, variableDict):

		self.__variablesInfoDict.update({variableStringKey: variableDict})

	def get_variablesInfoDict(self):
		return self.__variablesInfoDict

def importDataActuator(fileName, iFile, CMDoptionsDict, inputDataClass):

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

				weg += [returnNumber(currentLineSplit[int(inputDataClass.get_actuatorDataInfoDict()['excel_row_weg'])])]
				kraft += [returnNumber(currentLineSplit[int(inputDataClass.get_actuatorDataInfoDict()['excel_row_kraft'])])]

			lineN += 1
				

		file.close()

		print('\t'+'-> Last computed data point index (file): ' + str(lineN/1000000.0) + ' millions')

		dataFromRun = dataFromRunClassMesswerte(iFile, fileNameShort.split('_')[0]+'_'+fileNameShort.split('_')[1], lineN)

		dataFromRun.add_data(weg, kraft)

		# Artificially create time vector
		step_from_freq = 1 / float(inputDataClass.get_actuatorDataInfoDict()['sampling_freq'])
		time_from_freq = np.arange(0.0, step_from_freq*(lineN - int(inputDataClass.get_actuatorDataInfoDict()['time_offset'])), step = step_from_freq)
		if not len(time_from_freq) == len(kraft):
			dif = len(time_from_freq) - len(kraft)
			print('WARNING: Vector length mismatch. The length of the force vector is '+ str(len(kraft))+' and the length of the time vector is '+str(len(time_from_freq)), ' time vector reduced by '+str(dif))
			time_from_freq = time_from_freq[:-1]
		
		dataFromRun.add_time(time_from_freq)
		assert len(time_from_freq) == len(kraft), 'ERROR: Vector length mismatch. The length of the force vector is '+ str(len(kraft))+' and the length of the time vector is '+str(len(time_from_freq))
			
		#Filtering
		low_pass_force_data = filter(kraft, float(inputDataClass.get_actuatorDataInfoDict()['sampling_freq']), 'low-pass', float(inputDataClass.get_actuatorDataInfoDict()['cut-off_freq'])) #0.1 Hz of cut-off freq
		high_pass_force_data = filter(kraft, float(inputDataClass.get_actuatorDataInfoDict()['sampling_freq']), 'high-pass', float(inputDataClass.get_actuatorDataInfoDict()['cut-off_freq'])) #0.1 Hz of cut-off freq
		low_pass_displ_data = filter(weg, float(inputDataClass.get_actuatorDataInfoDict()['sampling_freq']), 'low-pass', float(inputDataClass.get_actuatorDataInfoDict()['cut-off_freq'])) #0.1 Hz of cut-off freq
		high_pass_displ_data = filter(weg, float(inputDataClass.get_actuatorDataInfoDict()['sampling_freq']), 'high-pass', float(inputDataClass.get_actuatorDataInfoDict()['cut-off_freq'])) #0.1 Hz of cut-off freq

		if CMDoptionsDict['correctionFilterFlag']:
				low_pass_force_data = [t + CMDoptionsDict['correctionFilterNum'] for t in low_pass_force_data]
				high_pass_force_data = [t - CMDoptionsDict['correctionFilterNum'] for t in high_pass_force_data]
		
		dataFromRun.add_filteredData(lowpass_displ_in = low_pass_displ_data, highpass_displ_in = high_pass_displ_data, lowpass_force_in = low_pass_force_data, highpass_force_in = high_pass_force_data)


	return dataFromRun

class dataFromRunClassMesswerte(object):
	"""docstring for dataFromRunClassMesswerte"""
	def __init__(self, id_in, testName_in, lastDataPointCounter_in):
		# super(dataFromRun, self).__init__()

		self.id = id_in
		self.__name = testName_in
		self.__lastDataPointCounter = lastDataPointCounter_in

	def get_attr(self, attr_string):
		
		return getattr(self, attr_string)

	def add_time(self,time_in):
		self.__time = time_in

	def add_data(self, weg_in, kraft_in):
		
		self.weg = weg_in
		self.kraft = kraft_in

	def add_filteredData(self, lowpass_force_in, highpass_force_in, lowpass_displ_in, highpass_displ_in):
		
		self.lowpass_force = lowpass_force_in
		self.highpass_force = highpass_force_in
		self.lowpass_displ = lowpass_displ_in
		self.highpass_displ = highpass_displ_in

	def get_name(self):
		return self.__name
	def get_weg(self):
		return self.weg
	def get_kraft(self):
		return self.kraft
	def get_time(self):
		return self.__time
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
		figure.Run(10, 6, forward=True)

		ax.plot(self.__cycleN, self.__maxF, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max force', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__meanF, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean force', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__minF, linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min force', **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

		ax.legend(**plotSettings['legend'])
		ax.set_title('Results from Run #'+str(self.__id), **plotSettings['ax_title'])

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
		figure.set_size_inches(16, 10, forward=True)

		ax.plot(self.__cycleN, self.__maxDispl, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Max displacement', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__meanDispl, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = 'Mean displacement', **plotSettings['line'])
		ax.plot(self.__cycleN, self.__minDispl, linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Min displacement', **plotSettings['line'])

		ax.set_xlabel('Number of cycles [Millions]', **plotSettings['axes_x'])
		ax.set_ylabel('Displacement [mm]', **plotSettings['axes_y'])

		ax.legend(**plotSettings['legend'])
		ax.set_title('Results from Run #'+str(self.__id), **plotSettings['ax_title'])

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
	def __init__(self, description_in, mag_in, testFactor_in, orderDeriv_in):
		# super(dataFromGaugesSingleMagnitudeClass, self).__init__()

		self.__description = description_in
		self.__mag = mag_in
		self.__testFactor = testFactor_in
		self.__orderDeriv = orderDeriv_in

		self.__max = []
		self.__mean = []
		self.__min = []
		self.__rs = []
		self.__rs_split = []

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


	def reStartXvaluesAndLastID(self):
		self.__lastID = 0
		self.__xValues = []
		self.__xValuesNewRun = []

	def get_description(self):
		return self.__description
	def get_testFactor(self):
		return self.__testFactor
	def get_orderDeriv(self):
		return self.__orderDeriv
	def get_mag(self):
		return self.__mag
	def get_freqData(self):
		return self.__freqData
	def get_timeRs(self):
		return self.__timeRs
	def get_rs(self):
		return self.__rs
	def get_rs_split(self):
		return self.__rs_split
	def get_timeSecNewRunRs(self):
		return self.__timeSecNewRunRs
	def get_stepID(self):
		return self.__stepID

	def set_magData(self, nameField, data):

		if nameField in ('rs','lp','hp','di'):
			self.__rs += data
			self.__rs_split += [data]
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

	def importDataForClass(self, shortFileName, longFileName, fieldOfFile, CMDoptionsDict, fileOutComeSummaryForVarAndMag):

		fileName = shortFileName
		file = open(longFileName, 'r')
		lines = file.readlines()

		skipLines, dataID, data, counter, totalLines = 0, [], [], 0, len(lines)

		for line in lines[(skipLines+1):]:

			if cleanString(line) != '': #Filter out blank lines

				try:

					if CMDoptionsDict['correctionFilterFlag'] and fieldOfFile in ('lp'):
						data += [float(cleanString(line)) + CMDoptionsDict['correctionFilterNum']]
					elif CMDoptionsDict['correctionFilterFlag'] and fieldOfFile in ('hp'):
						data += [float(cleanString(line)) - CMDoptionsDict['correctionFilterNum']]
					else:
						data += [float(cleanString(line))]

				except ValueError as e:
					print('Error when reading line '+str(counter)+', data content: '+cleanString(line))
					raise e

				if counter == 0: #First iteration
					dataID += [self.__lastID+1]
				else:
					dataID += [dataID[-1]+1]

			# status = round((counter/totalLines)* 100, 2)
			# sys.stdout.write('-----> Status: '+ str(status) +'% \r')
			# sys.stdout.flush()

			counter += 1
		
		file.close()

		if CMDoptionsDict['correctionFilterFlag'] and fieldOfFile in ('lp', 'hp'):
			print('\t'+'-> Correction applied to each imported data point, value: '+str(CMDoptionsDict['correctionFilterNum']))

		self.set_magData(fieldOfFile, data)

		#Data stats:
		max_data = max(data)
		min_data = min(data)
		mean_data = np.mean(data)

		# Remove outliers and calculate max and min
		flagOutliers = False
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
			self.__MinMax += [[min_data, max_data]]
		
		self.__lastID = dataID[-1]

		self.__xValuesNewRun += [dataID[-1],]

		self.__xValues += dataID
		
		# Obtain step index
		fileName_0 = fileName.split('.csv')[0]
		file_stepID = fileName_0.split('__')[-1]
		self.__stepID += [file_stepID]

		#Obtain frequency for recorded data
		if fieldOfFile in ('lp', 'hp'):
			self.__filterData += [float(fileName_0.split('__')[-2][:-2])]
			self.__freqData += [float(fileName_0.split('__')[-3][:-2])]
		else:
			self.__freqData += [float(fileName_0.split('__')[-2][:-2])]

		# Last computed point stats
		print('\t'+'-> Last computed data point index (file): ' + str(counter/1000000.0) + ' millions / '+calculateDaysHoursMinutes_string(counter, self.__freqData[-1]))
		print('\t'+'-> Max, min and mean values read (file), max: ' + str(max_data) + ', min: '+str(min_data)+', mean: '+str(mean_data))

		if flagOutliers and fieldOfFile in ('lp', 'hp'):
			print('\t'+'-> Max and min values without outliers (file), max: ' + str(round(self.__MinMax[-1][1], 2)) + ', min: '+str(round(self.__MinMax[-1][0], 2)))
		
		print('\t'+'-> Last computed data point index (accumulated): ' + str(dataID[-1]/1000000.0) + ' millions / '+calculateDaysHoursMinutes_string(dataID[-1], self.__freqData[-1]))

		#Print results to file
		if CMDoptionsDict['writeStepResultsToFileFlag']:
			fileOutComeSummaryForVarAndMag.write(','.join([str(t) for t in [file_stepID,max_data, min_data, mean_data]]) + '\n') 

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

	def addDataManual1(self, dataClasses, forceName1, forceName2, inputDataClass):
		"""
		Customized function to calculate the fighting force
		"""
		result = []

		forceHP1 = [temp for temp in dataClasses if temp.get_description() == forceName1][0]
		forceHP2 = [temp for temp in dataClasses if temp.get_description() == forceName2][0]

		for f1, f2 in zip(forceHP1.get_rs(), forceHP2.get_rs()):

			result += [abs(f1-f2)]

		self.__rs = result
		self.__freqData = forceHP1.get_freqData()
		self.__timeRs = forceHP1.get_timeRs()
		self.__timeSecNewRunRs = forceHP1.get_timeSecNewRunRs()
		self.__stepID = forceHP1.get_stepID()

		variableDict = {'y-label' : inputDataClass.get_variablesInfoDict()[forceHP1.get_mag()+'__'+forceHP1.get_description()]['y-label']}
		inputDataClass.updateVariablesInfoDict(forceHP1.get_mag()+'__'+self.__description, variableDict)

	def addDataManual2(self, dataClasses):
		"""
		Customized function to calculate the fighting force
		"""
		result = []

		forceHP1 = [temp for temp in dataClasses if temp.get_description() == 'ForceEye1'][0]
		forceHP2 = [temp for temp in dataClasses if temp.get_description() == 'ForceEye2'][0]

		for f1, f2 in zip(forceHP1.get_rs(), forceHP2.get_rs()):

			result += [f1+f2]

		self.__rs = result
		self.__freqData = forceHP1.get_freqData()
		self.__timeRs = forceHP1.get_timeRs()
		self.__timeSecNewRunRs = forceHP1.get_timeSecNewRunRs()
		self.__stepID = forceHP1.get_stepID()

	def addDataManual3(self, dataClasses, dof_to_calculate, area):
		
		vel = [temp for temp in dataClasses if temp.get_description() == dof_to_calculate][0]

		assert vel.get_mag() == 'di', 'Error'

		factor = 60.0 / 1E6 #mm^3/s to L/min

		self.__rs = [abs(t)*area*factor for t in vel.get_rs()]
		self.__freqData = vel.get_freqData()
		self.__timeRs = vel.get_timeRs()
		self.__timeSecNewRunRs = vel.get_timeSecNewRunRs()
		self.__stepID = vel.get_stepID()

	def addDataManual4(self, vectorNewPoints, exampleDataClass):

		self.__rs = vectorNewPoints
		self.__freqData = exampleDataClass.get_freqData()
		self.__timeRs = exampleDataClass.get_timeRs()
		self.__timeSecNewRunRs = exampleDataClass.get_timeSecNewRunRs()
		self.__stepID = exampleDataClass.get_stepID()

	def addDataManual5(self, dataClasses):

		data_lng = [temp for temp in dataClasses if temp.get_description() == 'Q_LNG'][0]
		data_lat = [temp for temp in dataClasses if temp.get_description() == 'Q_LAT'][0]

		vectorNewPoints = [max(lng,lat) for lng,lat in zip(data_lng.get_rs(), data_lat.get_rs())]

		self.__rs = vectorNewPoints
		self.__freqData = data_lng.get_freqData()
		self.__timeRs = data_lng.get_timeRs()
		self.__timeSecNewRunRs = data_lng.get_timeSecNewRunRs()
		self.__stepID = data_lng.get_stepID()

	def addDataManual6(self, correction):

		self.__rs = [t + correction for t in self.__rs]

	def addDataManual7(self):
		"""
		Add increment variable
		"""

		originalVector = self.__rs
		incrementVector = [0]
		i = 0
		for point in originalVector[1:]:
			incrementVector += [point - originalVector[i]]
			i += 1

		assert len(originalVector) == len(incrementVector)

		self.rs_increments = incrementVector

	def plotMaxMinMean_fromDIAdem(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(16, 10, forward=True)

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
		ax.set_title(self.__description, **plotSettings['ax_title'])

		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.set_ylim(ax.get_ylim())

		#Figure settings
		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

	def plotResampled(self, plotSettings, CMDoptionsDict, magnitude, additionalInput, inputDataClass):

		# Range files
		if len(CMDoptionsDict['rangeFileIDs']) < 8:
			rangeIDstring = ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])
		else:
			rangeIDstring = str(CMDoptionsDict['rangeFileIDs'][0])+'...'+str(CMDoptionsDict['rangeFileIDs'][-1])
		
		plotsDone = 0

		# pdb.set_trace()

		if CMDoptionsDict['multipleYaxisInSameFigure'] and CMDoptionsDict['numberMultipleYaxisInSameFigure'] != 1 and plotSettings['currentAxis'][1] == -1:
			figure, axesList = plt.subplots(CMDoptionsDict['numberMultipleYaxisInSameFigure'], 1, sharex='col')
			figure.set_size_inches(16, 10, forward=True)
			plotSettings.update({'listMultipleAxes': axesList})
			plotSettings.update({'currentFigureMultipleAxes': figure})

			ax = axesList[0]
			plotSettings.update({'currentAxis': [ax, 0]})

			# Figure title
			figure.suptitle(rangeIDstring, **plotSettings['figure_title'])

		elif CMDoptionsDict['multipleYaxisInSameFigure'] and CMDoptionsDict['numberMultipleYaxisInSameFigure'] != 1 and plotSettings['currentAxis'][1] != -1:
			
			new_ax_id = plotSettings['currentAxis'][1]+1
			ax = plotSettings['listMultipleAxes'][new_ax_id]
			plotSettings.update({'currentAxis': [ax, new_ax_id]})
		else:
			# Normal operation, one single plot
			figure, ax = plt.subplots(1, 1)
			figure.set_size_inches(16, 10, forward=True)
			
			# Figure title
			figure.suptitle(rangeIDstring, **plotSettings['figure_title'])

		if not additionalInput[0]:
			ax.plot( [t/self.__freqData[0] for t in self.__timeRs], self.__rs, linestyle = '-', marker = '', c = plotSettings['colors'][plotsDone], label = self.__description, **plotSettings['line'])
			plotsDone += 1
		# Mean based on max and min
		if not additionalInput[0]:
			mean_min = np.mean([setOne[0] for setOne in self.__MinMax])
			mean_max = np.mean([setOne[1] for setOne in self.__MinMax])

			mean_fromMinMax = ((mean_max - mean_min)/2) + mean_min
			print('mean record data :'+str(mean_fromMinMax))

		if additionalInput[0]:
			dataClasses = additionalInput[1]
			for dataClass in dataClasses:
				for additionalInputString in additionalInput[2]:
					if dataClass.get_description() == additionalInputString:
						ax.plot( [t/dataClass.get_freqData()[0] for t in dataClass.get_timeRs()], dataClass.get_rs(), linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = dataClass.get_description(), **plotSettings['line'])

						plotsDone += 1
		
		#Division line for runs
		if CMDoptionsDict['divisionLineForPlotsFlag']:
			valuesMaxRs = ax.get_ylim()[1]
			valuesMinRs = ax.get_ylim()[0]
			maxPlot_y = valuesMaxRs*1.2 if valuesMaxRs > 0.0 else valuesMaxRs*0.8
			minPlot_y = valuesMinRs*0.8 if valuesMinRs > 0.0 else valuesMinRs*1.2
			previousDiv = 0.0
			i = 0
			ax.plot(2*[0.0], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])
			for div in [t/self.__freqData[0] for t in self.__timeSecNewRunRs]:
				ax.plot(2*[div], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])

				#Add text with step number
				ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, self.__stepID[i], bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')
				# ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, 'Step '+self.__stepID[i], bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')
				
				previousDiv = div
				i += 1

		# Test Order plots 
		if not additionalInput[0] and CMDoptionsDict['testOrderFlagFromCMD'] and ( (inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['TO spec'].lower() in ('yes', 'y') and magnitude == 'rs') or (inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['Fatigue load spec'].lower() in ('yes', 'y') and magnitude in ('lp', 'hp')) ):
			maxPlot_x = 0.0
			minPlot_x = max(self.__timeSecNewRunRs)/self.__freqData[0]

			limitsLoadsBoundaries = []
			if magnitude == 'rs':
				limitLoads = [float(t) for t in [inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['max load'], inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['min load']]]
			elif magnitude == 'lp' and inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['Fatigue load spec'].lower() in ('yes', 'y'):
				limitLoads = [float(inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['static load'])]
				margin = float(inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['margin static load (%)'])
				limitsLoadsBoundaries = [1 + (margin/100), 1 - (margin/100)]
			elif magnitude == 'hp' and inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['Fatigue load spec'].lower() in ('yes', 'y'):
				limitLoads = [float(inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['alternate load']), -float(inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['alternate load'])]
				margin = float(inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['margin alternate load (%)'])
				limitsLoadsBoundaries = [1 + (margin/100), 1 - (margin/100)]

			for limitLoad in limitLoads:
				ax.plot([minPlot_x, maxPlot_x], 2*[limitLoad], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])
				if limitsLoadsBoundaries:
					for limitLoadBoundary in limitsLoadsBoundaries:
						ax.plot([minPlot_x, maxPlot_x], 2*[limitLoad*limitLoadBoundary], linestyle = '-.', marker = '', c = plotSettings['colors'][6], scaley = False, scalex = False, **plotSettings['line'])

		# x-label
		if not CMDoptionsDict['multipleYaxisInSameFigure'] or CMDoptionsDict['numberMultipleYaxisInSameFigure'] == 1:
			ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])
		elif CMDoptionsDict['numberMultipleYaxisInSameFigure']==(plotSettings['currentAxis'][1]+1):
			ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

		# y-label
		ax.set_ylabel(inputDataClass.get_variablesInfoDict()[magnitude+'__'+self.__description]['y-label'], **plotSettings['axes_y'])

		#Legend and title
		if additionalInput[0]:
			ax.legend(**plotSettings['legend'])
		else:
			if magnitude == 'rs':
				ax.set_title(self.__description+', '+str(int(self.__freqData[0]))+' Hz', **plotSettings['ax_title'])
			elif magnitude == 'lp':
				a = self.__filterData[0]
				ax.set_title(self.__description+', low-pass filtered with '+str(float(self.__filterData[0]))+' Hz cut-off freq.', **plotSettings['ax_title'])
			elif magnitude == 'hp':
				ax.set_title(self.__description+', high-pass filtered with '+str(float(self.__filterData[0]))+' Hz cut-off freq.', **plotSettings['ax_title'])
			else:
				ax.set_title(self.__description, **plotSettings['ax_title'])

		#Figure settings
		usualSettingsAX(ax, plotSettings)
		
		#Save figure
		if CMDoptionsDict['saveFigure'] and not CMDoptionsDict['multipleYaxisInSameFigure']:

			if additionalInput[0]:
				figure.savefig(os.path.join(CMDoptionsDict['cwd'], magnitude+'_'+rangeIDstring+'_'+self.__description+'&'+'&'.join(additionalInput[2])+'.png'), dpi = plotSettings['figure_settings']['dpi'])
			else: 
				figure.savefig(os.path.join(CMDoptionsDict['cwd'], magnitude+'_'+rangeIDstring+'_'+self.__description+'.png'), dpi = plotSettings['figure_settings']['dpi'])
		elif CMDoptionsDict['saveFigure'] and CMDoptionsDict['numberMultipleYaxisInSameFigure']==(plotSettings['currentAxis'][1]+1): #CMDoptionsDict['multipleYaxisInSameFigure'] is True

			figure = plotSettings['currentFigureMultipleAxes']
			figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['magnitudes']])+'_'+rangeIDstring+'_'+','.join([str(i) for i in CMDoptionsDict['variables']])+'.png'), dpi = plotSettings['figure_settings']['dpi'])

		return plotSettings

	def plotOneVariableAgainstOther(self, plotSettings, CMDoptionsDict, inputDataClass, dataClasses):

			# Range files
			if len(CMDoptionsDict['rangeFileIDs']) < 8:
				rangeIDstring = ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])
			else:
				rangeIDstring = str(CMDoptionsDict['rangeFileIDs'][0])+'...'+str(CMDoptionsDict['rangeFileIDs'][-1])

			# Data Classes
			data1 = [temp for temp in dataClasses if temp.get_description() == CMDoptionsDict['variables'][0]][0]
			data2 = [temp for temp in dataClasses if temp.get_description() == CMDoptionsDict['variables'][1]][0]

			#Vector of steps
			stepStrs = data1.get_stepID()
			indexDictForSteps = {}
			for id_curr in stepStrs:
				indexDictForSteps[id_curr] = stepStrs.index(id_curr)

			figure, ax = plt.subplots(1, 1, sharex='col')
			figure.set_size_inches(16, 10, forward=True)
			figure.suptitle(rangeIDstring, **plotSettings['figure_title'])

			plotsDone = 0
			for stepName in stepStrs:
				ax.plot( data1.get_rs_split()[indexDictForSteps[stepName]], data2.get_rs_split()[indexDictForSteps[stepName]], linestyle = plotSettings['linestyles'][int(plotsDone/7)], marker = '', c = plotSettings['colors'][plotsDone], label = stepName, **plotSettings['line'])
				plotsDone += 1

			ax.set_xlabel(inputDataClass.get_variablesInfoDict()[data1.get_mag()+'__'+data1.get_description()]['y-label'], **plotSettings['axes_x'])
			ax.set_ylabel(inputDataClass.get_variablesInfoDict()[data2.get_mag()+'__'+data2.get_description()]['y-label'], **plotSettings['axes_y'])

			ax.legend(**plotSettings['legend'])
			usualSettingsAX(ax, plotSettings)
			# Save figure
			if CMDoptionsDict['saveFigure']:

				figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['magnitudes']])+'_'+rangeIDstring+'_'+'_vs_'.join([str(i) for i in CMDoptionsDict['variables']])+'.png'), dpi = plotSettings['figure_settings']['dpi'])

	def plotMinMeanMax(self, plotSettings):

		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(16, 10, forward=True)

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
		ax.set_title(self.__description, **plotSettings['ax_title'])

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
	figure.set_size_inches(16, 10, forward=True)

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
		ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, 'Run '+str(data.get_stepID()), bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')

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
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['ax_title'])

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

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+'ActuatorLoadsMaxMinMean.png'), dpi = plotSettings['figure_settings']['dpi'])

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
	figure.set_size_inches(16, 10, forward=True)

	counterPlots = 0
	for data in dataFromRuns:

		ax.plot(data.get_weg(), data.get_kraft(), linestyle = '-', marker = '', c = plotSettings['colors'][counterPlots], label = data.get_name(), **plotSettings['line'])

		counterPlots += 1

	ax.set_xlabel('Displacement [mm]', **plotSettings['axes_x'])
	ax.set_ylabel('Force [kN]', **plotSettings['axes_y'])

	#Legend and title
	ax.legend(**plotSettings['legend'])
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['ax_title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()

	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+'ActuatorForceDisplacementTotalStaticAlternate.png'), dpi = plotSettings['figure_settings']['dpi'])

	#Central differences plot
	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(16, 10, forward=True)

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
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['ax_title'])

	#Figure settings
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()

	#Double y-axis 
	axdouble_in_y = ax.twinx()
	axdouble_in_y.set_ylim(ax.get_ylim())

	#Save figure
	if CMDoptionsDict['saveFigure']:

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+'ActuatorForceDisplacement.png'), dpi = plotSettings['figure_settings']['dpi'])

def plotAllRuns_displacement(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass):

	def threePlotForRun(dataFromRun, plotSettings, ax):
		
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_maxDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][0], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_meanDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][1], **plotSettings['line'])
		ax.plot(dataFromRun.get_absoluteNCycles_mill(), dataFromRun.get_minDispl(), linestyle = '-', marker = '', c = plotSettings['colors'][2], **plotSettings['line'])	
	
	figure, ax = plt.subplots(1, 1)
	figure.set_size_inches(16, 10, forward=True)

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
		ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, 'Run '+str(data.get_stepID()), bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')

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
	ax.set_title('Results fatigue test, data from actuator', **plotSettings['ax_title'])

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

		figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+'ActuatorDisplacementMaxMinMean.png'), dpi = plotSettings['figure_settings']['dpi'])

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

	# split in ranges
	range_spacing = 100
	init_range = 0
	size_vector = len(x_list)

	assert len(x_list) == len(y_list), 'ERROR: Mismatch between the sizes of x, y'

	# Linear fit
	# f(x) = regre[0]*x_list + regre[1]

	regre = np.polyfit(x_list, y_list, 1)

	error_list, vari = errorVectorFunction(x_list, y_list, regre)

	x_list_woOutliers, y_list_woOutliers, outliers = removeOutliers(x_list, y_list, error_list, vari, 1.960) #2.576

	return x_list_woOutliers, y_list_woOutliers

def plotAllRuns_filtered_Messwerte(dataFromRuns, timesDict, plotSettings, CMDoptionsDict, inputDataClass):
	
	attrs_to_plot_list = [['kraft', 'lowpass_force', 'highpass_force'], ['weg', 'lowpass_displ', 'highpass_displ']]
	# attrs_to_plot_list = [['kraft']]
	titles = {'kraft': 'Force measured by the actuator, total, static and alternate',
				'weg' : 'Displacement imposed by the actuator, total, static and alternate',
				'lowpass_force': 'Force low-pass filtered with '+inputDataClass.get_actuatorDataInfoDict()['cut-off_freq']+' Hz cut-off freq.', 
				'highpass_force': 'Force high-pass filtered with '+inputDataClass.get_actuatorDataInfoDict()['cut-off_freq']+' Hz cut-off freq.',
				'lowpass_displ': 'Displacement low-pass filtered with '+inputDataClass.get_actuatorDataInfoDict()['cut-off_freq']+' Hz cut-off freq.', 
				'highpass_displ': 'Displacement high-pass filtered with '+inputDataClass.get_actuatorDataInfoDict()['cut-off_freq']+' Hz cut-off freq.'}

	for attrs_to_plot in attrs_to_plot_list:
		figure, axesList = plt.subplots(len(attrs_to_plot), 1, sharex='col')
		figure.set_size_inches(16, 10, forward=True)

		for ax, attr in zip(axesList, attrs_to_plot):
			# ax = axesList
			# attr = 'kraft'

			LastData, lastPoint = None, 0.0

			for data in dataFromRuns:

				if not LastData:
					ax.plot( data.get_time().tolist(), data.get_attr(attr), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = data.get_name(), **plotSettings['line'])
				else:
					lastPoint += LastData.get_time().tolist()[-1]
					ax.plot( [t+lastPoint for t in data.get_time().tolist()] , data.get_attr(attr), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = data.get_name(), **plotSettings['line'])

					#Give mean high-pass
					if attr == 'highpass_force':
						print('Mean value: ' + str(np.mean(data.get_attr(attr))))

				LastData = data

			#Division line for runs
			valuesMaxRs = ax.get_ylim()[1]
			valuesMinRs = ax.get_ylim()[0]
			maxPlot_y = valuesMaxRs*1.2 if valuesMaxRs > 0.0 else valuesMaxRs*0.8
			minPlot_y = valuesMinRs*0.8 if valuesMinRs > 0.0 else valuesMinRs*1.2
			previousDiv = 0.0
			i = 0
			ax.plot(2*[0.0], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
			for div in timesDict['lastTimeList']:
				ax.plot(2*[div], [minPlot_y, maxPlot_y], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

				#Add text with step number
				ax.text(previousDiv + ((div - previousDiv)/2), minPlot_y, 'Run '+str(CMDoptionsDict['rangeFileIDs'][i]), bbox=dict(facecolor='black', alpha=0.2), horizontalalignment = 'center')
				
				previousDiv = div
				i += 1

			if CMDoptionsDict['testOrderFlagFromCMD'] and inputDataClass.get_actuatorDataInfoDict()['TO spec'].lower() in ('yes', 'y') and ('force' in attr or 'kraft' in attr):
				maxPlot_x = 0.0
				minPlot_x = timesDict['lastTimeList'][-1]
				limitsLoadsBoundaries = []
				if attr == 'kraft':
					limitLoads = [float(t) for t in [inputDataClass.get_actuatorDataInfoDict()['max load'], inputDataClass.get_actuatorDataInfoDict()['min load']]]
				elif attr == 'lowpass_force' and inputDataClass.get_actuatorDataInfoDict()['Fatigue load spec'].lower() in ('yes', 'y'):
					limitLoads = [float(inputDataClass.get_actuatorDataInfoDict()['static load'])]
					margin = float(inputDataClass.get_actuatorDataInfoDict()['margin static load (%)'])
					limitsLoadsBoundaries = [1 + (margin/100), 1 - (margin/100)]
				elif attr == 'highpass_force' and inputDataClass.get_actuatorDataInfoDict()['Fatigue load spec'].lower() in ('yes', 'y'):
					limitLoads = [float(inputDataClass.get_actuatorDataInfoDict()['alternate load']), -float(inputDataClass.get_actuatorDataInfoDict()['alternate load'])]
					margin = float(inputDataClass.get_actuatorDataInfoDict()['margin alternate load (%)'])
					limitsLoadsBoundaries = [1 + (margin/100), 1 - (margin/100)]

				for limitLoad in limitLoads:
					ax.plot([minPlot_x, maxPlot_x], 2*[limitLoad], linestyle = '--', marker = '', c = plotSettings['colors'][5], **plotSettings['line'])
					if limitsLoadsBoundaries:
						for limitLoadBoundary in limitsLoadsBoundaries:
							ax.plot([minPlot_x, maxPlot_x], 2*[limitLoad*limitLoadBoundary], linestyle = '-.', marker = '', c = plotSettings['colors'][6], **plotSettings['line'])

			if 'force' in attr or 'kraft' in attr:
				ax.set_ylabel('Force [KN]', **plotSettings['axes_y'])
			elif 'weg' in attr or 'displ' in attr:
				ax.set_ylabel('Displ. [mm]', **plotSettings['axes_y'])

			ax.set_title(titles[attr], **plotSettings['ax_title'])

			#Figure settings
			ax.grid(which='both', **plotSettings['grid'])
			ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			ax.minorticks_on()

			#Double y-axis 
			axdouble_in_y = ax.twinx()
			axdouble_in_y.minorticks_on()
			axdouble_in_y.set_ylim(ax.get_ylim())

		#Only last ax
		ax.set_xlabel('Time [s]', **plotSettings['axes_x'])

		#Save figure
		if CMDoptionsDict['saveFigure']:

			figure.savefig(os.path.join(CMDoptionsDict['cwd'], ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])+titles[attrs_to_plot[0]]+'.png'), dpi = plotSettings['figure_settings']['dpi'])

def plotStiffnessForChoosenSteps_Messwerte(dataFromRuns, timesDict, plotSettings, CMDoptionsDict, inputDataClass):
	"""
	Function for post-processing of BT0220
	CMD execution line:python main.py -f filesToLoad_actuatorMesswerte_actuatorBolts.txt -c f -o t -s f,t -r 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 -w f
	"""
	tests_Dict = {15.7: {'torqued by nut': [6,8,10], 'torqued by bolt':[12,14,16]}, 23: {'torqued by nut': [7,9,11], 'torqued by bolt':[13,15,17]}}

	dictForDataID = {}
	for data in dataFromRuns:
		for key in tests_Dict.keys():
			for key2 in tests_Dict[key].keys():
				if data.id in tests_Dict[key][key2]:
					dictForDataID[data.id] = [key, key2]

	figure1, ax1 = plt.subplots(1, 1) #, sharex='col'
	figure2, ax2 = plt.subplots(1, 1) #, sharex='col'
	axesList = [ax1, ax2]
	figure1.set_size_inches(16, 10, forward=True)
	figure1.suptitle('Stiffness of specimen, TBN:Torqued by nut / TBB:Torqued by bolt', **plotSettings['figure_title'])
	figure2.set_size_inches(16, 10, forward=True)
	figure2.suptitle('Stiffness of specimen, TBN:Torqued by nut / TBB:Torqued by bolt', **plotSettings['figure_title'])

	axsDict = {15.7:axesList[0], 23:axesList[1]}
	colorsDict = {'torqued by nut' : 0, 'torqued by bolt' : 1}
	labelsDict = {'torqued by nut' : 'TBN', 'torqued by bolt' : 'TBB'}
	markersList = ['o', '+', '^']
	markersDict = {6:markersList[0],7:markersList[0],8:markersList[1],9:markersList[1],10:markersList[0],11:markersList[1],12:markersList[1],13:markersList[0],14:markersList[1],15:markersList[1],16:markersList[2],17:markersList[2]}
	
	for data in [t for t in dataFromRuns if t.id >= 6]:
		axsDict[dictForDataID[data.id][0]].plot( data.get_attr('weg'), [t/1000.0 for t in data.get_attr('kraft')], linestyle = '', marker = markersDict[data.id], c = plotSettings['colors'][colorsDict[dictForDataID[data.id][1]]], label = str(data.id)+'_'+labelsDict[dictForDataID[data.id][1]], **plotSettings['line'])

	axesList[-1].set_xlabel('Zwick displ. [mm]', **plotSettings['axes_x'])
	axesList[0].set_xlabel('Zwick displ. [mm]', **plotSettings['axes_x'])
	axesList[0].set_title('Target 15.7 KN', **plotSettings['ax_title'])
	axesList[1].set_title('Target 23 KN', **plotSettings['ax_title'])
	for ax in axesList:
		ax.legend(**plotSettings['legend'])
		ax.set_ylabel('Force [KN]', **plotSettings['axes_y'])
		usualSettingsAX(ax, plotSettings)

def filter(data, fs, typeFilter, cutoff):

	from scipy.signal import butter, lfilter, freqz

	def butter_filter(data, cutoff, fs, typeFilter_in, order_in=5):
		if 'low' in typeFilter_in:
			typeFilter = 'low'
		elif 'high' in typeFilter_in:
			typeFilter = 'high'
		# nyq = 0.5 * fs
		# normal_cutoff = cutoff / nyq
		b, a = butter(order, cutoff, btype=typeFilter, analog=False)
		y = lfilter(b, a, data)
		return y

	# Filter requirements.
	order = 6
	# fs = 30.0       # sample rate, Hz
	# cutoff = 3.667  # desired cutoff frequency of the filter, Hz

	y = butter_filter(data, cutoff, fs, typeFilter,order_in = order)
	# y = butter_filter(y, cutoff, fs, typeFilter,order_in = order) #Add

	return y

def createSegmentsOf_rs_FromVariableClass(variableClass, segmentList, index_rs_split):

	allTime = get_timeVectorClass(variableClass, index_rs_split)

	assert len(allTime) == len(variableClass.get_rs_split()[index_rs_split])

	if isinstance(segmentList, list):
		startTime_index = allTime.index([t for t in allTime if abs(segmentList[0]-t)<(0.6*(1/variableClass.get_freqData()[0]))][0])
		endTime_index = allTime.index([t for t in allTime if abs(segmentList[1]-t)<(0.6*(1/variableClass.get_freqData()[0]))][0])

		new_rs = variableClass.get_rs_split()[index_rs_split][startTime_index:endTime_index+1]

		newTime = allTime[startTime_index:endTime_index+1]

		return new_rs, newTime

	else:
		singleTime_index = allTime.index([t for t in allTime if abs(segmentList-t)<(0.6*(1/variableClass.get_freqData()[0]))][0])
		new_rs = variableClass.get_rs_split()[index_rs_split][singleTime_index]
		newTime = allTime[singleTime_index]

		return new_rs, newTime


#Utility functions
def checkErrors(dataClasses, CMDoptionsDict, inputDataClass):

	if not dataClasses: #If dataClasses is empty
		raise ImportError('EXCEPTION CAUGHT: No files loaded. Verify variables names, steps IDs, specified location of data folder, ...')

	# Check if any of the variables names are not described
	for classCurrent in dataClasses:
		if not classCurrent.get_mag()+'__'+classCurrent.get_description() in inputDataClass.get_variablesInfoDict().keys():
			raise AssertionError('EXCEPTION CAUGHT: Variable '+classCurrent.get_mag()+'__'+classCurrent.get_description()+' is not described in '+CMDoptionsDict['fileNameOfFileToLoadFiles'])

	if '-n' in CMDoptionsDict['optsLoaded']:
		if CMDoptionsDict['oneVariableInEachAxis'] and len(CMDoptionsDict['variables']) != 2:
			raise AssertionError('EXCEPTION CAUGHT: One two variables can be plotted one against each other. The current number of variables is '+str(len(CMDoptionsDict['variables'])))
		elif CMDoptionsDict['oneVariableInEachAxis']:
			# Data Classes
			data1 = [temp for temp in dataClasses if temp.get_description() == CMDoptionsDict['variables'][0]][0]
			data2 = [temp for temp in dataClasses if temp.get_description() == CMDoptionsDict['variables'][1]][0]

			if data1.get_freqData() != data2.get_freqData():
				raise AssertionError('EXCEPTION CAUGHT: The two variables which are going to be plotted one against each other need to have the same sampling freq.')

def usualSettingsAX(ax, plotSettings):
	
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()
	#Double y-axis 
	axdouble_in_y = ax.twinx()
	axdouble_in_y.minorticks_on()
	axdouble_in_y.set_ylim(ax.get_ylim())
	axdouble_in_y.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])

	return axdouble_in_y

def usualSettingsAXNoDoubleAxis(ax, plotSettings):
	
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()

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

	totalTimeString = str(round(seconds/3600.0, 2))+' hours / '+str(n_days)+' days, '+str(n_hours)+' hours, '+str(n_minutes)+' minutes, '+str(round(remainingSeconds, 2))+' seconds ('+str(freq)+' Hz)'

	return totalTimeString

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
	axes_label_x  = {'size' : 14, 'weight' : 'medium', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 14, 'weight' : 'medium', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	figure_text_title_properties = {'weight' : 'bold', 'size' : 18}
	ax_text_title_properties = {'weight' : 'regular', 'size' : 16}
	axes_ticks = {'labelsize' : 12}
	line = {'linewidth' : 1.5, 'markersize' : 2.5}
	scatter = {'linewidths' : 1.0}
	legend = {'fontsize' : 10, 'loc' : 'best', 'markerscale' : 1.5}
	grid = {'alpha' : 0.7}
	colors = ['k', 'b', 'r', 'm', 'y', 'c', 'g', 'k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c']
	markers = ['o', 'v', '^', 's', '*', '+']
	linestyles = ['-', '--', '-.', ':']
	axes_ticks_n = {'x_axis' : 3} #Number of minor labels in between 
	figure_settings = {'dpi' : 200}

	plotSettings = {'axes_x':axes_label_x,'axes_y':axes_label_y, 'figure_title':figure_text_title_properties, 'ax_title':ax_text_title_properties,
	                'axesTicks':axes_ticks, 'line':line, 'legend':legend, 'grid':grid, 'scatter':scatter,
	                'colors' : colors, 'markers' : markers, 'linestyles' : linestyles, 'axes_ticks_n' : axes_ticks_n,
	                'figure_settings' : figure_settings}

	# Additional computing data
	plotSettings['currentAxis'] = [None, -1] #[Axis object, index]
	plotSettings['listMultipleAxes'] = None
	plotSettings['currentFigureMultipleAxes'] = None


	return plotSettings

def sortFilesInFolderByLastNumberInName(listOfFiles, folderName, CMDoptionsDict):

	a = []
	for file in listOfFiles:
		if file.endswith('.csv'):
			file_0 = file.split('.csv')[0]
			fileID0_int = file_0.split('__')[-1]
			fileID_int = int(fileID0_int.split('-')[0])
			a += [(file, fileID_int),]

	a_sorted = sorted(a, key=lambda x: x[1])
	listOfFilesSorted = [[folderName,b[0]] for b in a_sorted]

	return listOfFilesSorted

def cleanString(stringIn):
	
	if stringIn[-1:] in ('\t', '\n'):

		return cleanString(stringIn[:-1])

	else:

		return stringIn

def get_indexDictForSteps(exampleClass):
	stepStrs = exampleClass.get_stepID()
	indexDictForSteps = {}
	for id_curr in stepStrs:
		indexDictForSteps[id_curr] = stepStrs.index(id_curr)

	return indexDictForSteps, stepStrs

def get_timeVectorClass(variableClass, index_rs_split):

	allTime = list(np.linspace(0, float(len(variableClass.get_rs_split()[index_rs_split])*(1/variableClass.get_freqData()[0])), len(variableClass.get_rs_split()[index_rs_split]), endpoint=True))

	return allTime

def showInputOptions(CMDoptionsDict):

	print('\n'+'**** Options loaded'+'\n')

	titlesDict = {
					'-f': 'File name with test definition (-f):',
					'-v': 'Input variables (-v):',
					'-m': 'Variables magnitudes (-m):',
					'-r': 'Range of steps considered (-r):',
					'-c': 'Offset correction to be applied to the filtered data (-c):',
					'-s': 'Figure display options (-s):',
					'-n': 'Axes arrangements option (-n):',
					'-o': 'Show reference lines (Test Order values) (-o):',
					'-a': 'Additional calculations option (-a):',
					'-w': 'Write data summary report in spreadsheet (-w):',
					'-l': 'Plot division between consecutive test steps (-l):',
					}
	
	valuesDict = {
					'-f': CMDoptionsDict['fileNameOfFileToLoadFiles'],
					'-v': ' '.join(CMDoptionsDict['variables']),
					'-m': ' '.join(CMDoptionsDict['magnitudes']),
					'-r': ' '.join(CMDoptionsDict['rangeFileIDs']),
					'-c': 'Enabled, with value '+str(CMDoptionsDict['correctionFilterNum']) if CMDoptionsDict['correctionFilterFlag'] else 'Disabled',
					'-s': ', '.join(['Show figure: ' + 'Enabled' if CMDoptionsDict['showFigures'] else 'Disabled', 'Save figure: ' + 'Enabled' if CMDoptionsDict['saveFigure'] else 'Disabled']),
					'-n': CMDoptionsDict['axisArrangementOption'],
					'-o': 'Enabled' if CMDoptionsDict['testOrderFlagFromCMD'] else 'Disabled',
					'-a': 'Option '+str(CMDoptionsDict['additionalCalsOpt']) if CMDoptionsDict['additionalCalsFlag'] else 'Disabled',
					'-w': 'Enabled' if CMDoptionsDict['writeStepResultsToFileFlag'] else 'Disabled',
					'-l': 'Enabled' if CMDoptionsDict['divisionLineForPlotsFlag'] else 'Disabled',
					}
	
	for option in CMDoptionsDict['optsLoaded']:
		print('-> '+titlesDict[option])
		print(valuesDict[option])