import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import statistics as stat
import math
import getopt
import pdb #pdb.set_trace()

def importPlottingOptions():
	#### PLOTTING OPTIONS ####

	#Plotting options
	axes_label_x  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	text_title_properties = {'weight' : 'bold', 'size' : 14}
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

	plotSettings = {'axes_x':axes_label_x,'axes_y':axes_label_y, 'title':text_title_properties,
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

class ClassVariableDef(object):
	"""docstring for ClassVariableDef"""
	def __init__(self, name_in):
		self.name = name_in

	def get_attr(self, attr_string):
		
		return getattr(self, attr_string)

	def importData(self, CMDoptionsDict, typeImport):

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

		if typeImport == 'segment':

			timeSegments = []
			dataSegments = []

			for segmentString in CMDoptionsDict['flightTestInfo']['segment'].split(';'):

				segmentList = [float(t) for t in segmentString.split(',')]

				indexStartTime = time_proc.index(segmentList[0])
				indexEndTime = time_proc.index(segmentList[1])

				timeSegments += [time_proc[indexStartTime:indexEndTime]]
				dataSegments += [data_proc[indexStartTime:indexEndTime]]

			self.timeSegments = timeSegments
			self.dataSegments = dataSegments

		else:

			self.time = time_proc
			self.data = data_proc

	def convertToIncrement(self):

		newDataSegments = []
		
		for dataSegment in self.dataSegments:

			initialValue = dataSegment[0]

			updatedDataSegment = [t - initialValue for t in dataSegment]

			newDataSegments += [updatedDataSegment]

		self.dataSegments = newDataSegments



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

	# for segmentID in range(len(varClasses[0].get_attr('timeSegments'))):
	for segmentID in range(len(varClassesDict[list(varClassesDict.keys())[0]].get_attr('timeSegments'))):

		# dataSegment = varClass.get_attr('dataSegments')

		# for dataSegment, timeSegment in zip(varClass.get_attr('dataSegments'), varClass.get_attr('timeSegments')):

		figure, axesList = plt.subplots(len(list(varClassesDict.keys())), 1, sharex='col')
		figure.set_size_inches(12, 6, forward=True)

		for ax, var in zip(axesList, varClassesDict.keys()):

			ax.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], varClassesDict[var].get_attr('dataSegments')[segmentID], linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varClassesDict[var].get_attr('name'), **plotSettings['line'])		

			if ax == axesList[-1]:
				ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

			ax.set_ylabel(CMDoptionsDict['variablesInfo'][varClassesDict[var].get_attr('name')]['units'], **plotSettings['axes_y'])

			ax.set_title(varClassesDict[var].get_attr('name'), **plotSettings['axes_y'])

			ax.grid(which='both', **plotSettings['grid'])
			ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			ax.minorticks_on()

			figure.suptitle(str(segmentID+1)+' sub-set, '+str(varClassesDict[var].get_attr('timeSegments')[segmentID][0])+'s to '+str(varClassesDict[var].get_attr('timeSegments')[segmentID][-1])+'s', **plotSettings['title'])

			#Double y-axis
			axdouble_in_y = ax.twinx()
			axdouble_in_y.minorticks_on()
			if not varClassesDict[var].get_attr('name') == 'CNT_DST_BST_LNG':
				axdouble_in_y.set_ylim(ax.get_ylim())
			else:
				diffData0 = np.diff(varClassesDict[var].get_attr('dataSegments')[segmentID])
				diffData = [diffData0.tolist()[0]]+diffData0.tolist() #Correct reduction in the dimension
				axdouble_in_y.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], diffData, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = varClassesDict[var].get_attr('name')+'_diff', **plotSettings['line'])
				ax.legend(**plotSettings['legend'])
				axdouble_in_y.legend(**plotSettings['legend'])



def cleanString(stringIn):
	
	if stringIn[-1:] in ('\t', '\n'):

		return cleanString(stringIn[:-1])

	else:

		return stringIn
		