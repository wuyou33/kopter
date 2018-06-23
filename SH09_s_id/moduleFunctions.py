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
	axes_label_x  = {'size' : 14, 'weight' : 'bold', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 14, 'weight' : 'bold', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	text_title_properties = {'weight' : 'bold', 'size' : 14}
	axes_ticks = {'labelsize' : 10}
	line = {'linewidth' : 1.5, 'markersize' : 2}
	scatter = {'linewidths' : 2}
	legend = {'fontsize' : 14, 'loc' : 'best'}
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

	def importData(self, CMDoptionsDict):

		fileName = os.path.join(os.path.join(CMDoptionsDict['cwd'], CMDoptionsDict['folderFTdata']), self.name+'.csv')

		file = open(fileName, 'r')
		lines = file.readlines()

		skipLines, time_proc, data_proc, counter = 0, [1], [], 0

		for line in lines[(skipLines+1):]:

			data_proc += [float(cleanString(line))]

			if counter != 0: #First iteration is already counted
				time_proc += [time_proc[-1]+(1/float(CMDoptionsDict['variablesInfo'][self.name]['samplingFreq']))]

			counter += 1

		self.data = data_proc
		self.time = time_proc

def importFTIdefFile(fileName_in, CMDoptionsDict):

	fileName = os.path.join(os.path.join(CMDoptionsDict['cwd'], CMDoptionsDict['folderFTdata']), fileName_in)

	file = open(fileName, 'r')

	lines = file.readlines()

	newSectionIdentifier = '->'

	section_index, currentVariable, dict_proc = 0, None, {}

	for i in range(0, int((len(lines)))):

		rawLine = lines[i]

		cleanLine = cleanString(rawLine)

		if cleanLine != '': #Filter out blank lines

			if newSectionIdentifier in rawLine: #Header detected, change to new sections

				currentVariable2 = cleanLine.split(':')[1]
				currentVariable1 = currentVariable2.lstrip()
				currentVariable = currentVariable1.rstrip()

			elif currentVariable != None:

				variableStringKey = cleanLine.split(':')[0]
				valueLine2 = cleanLine.split(':')[1]
				valueLine1 = valueLine2.lstrip()
				valueLine = valueLine1.rstrip()

				temp_dict = {variableStringKey : valueLine}
				dict_proc[currentVariable] = temp_dict


	CMDoptionsDict['variablesInfo'] = dict_proc

	return CMDoptionsDict

def plotSignals(plotSettings, varClasses):

	figure, axesList = plt.subplots(len(varClasses), 1, sharex='col')
	figure.set_size_inches(12, 6, forward=True)

	for ax, varClass in zip(axesList, varClasses):

		ax.plot( varClass.get_attr('time'), varClass.get_attr('data'), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varClass.get_attr('name'), **plotSettings['line'])

		if ax == axesList[-1]:
			ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

		ax.set_ylabel(varClass.get_attr('name'), **plotSettings['axes_y'])

		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()

		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.set_ylim(ax.get_ylim())

def cleanString(stringIn):
	
	if stringIn[-1:] in ('\t', '\n'):

		return cleanString(stringIn[:-1])

	else:

		return stringIn
		