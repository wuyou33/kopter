# Collection of functions
import numpy as np
import matplotlib.pyplot as plt

###### Funtions
def returnNumber(numStr):
	
	if numStr[-4] == '.':
		numStr_ohnePunkt = numStr.replace('.','')
		return float(numStr[:-13]+numStr_ohnePunkt[-10:])
		# return float(numStr[:(numStr.index('.')+1)]+numStr[(numStr.index('.')+1):].replace('.',''))
	else:

		return float(numStr)

def importPlottingOptions():
	#### PLOTTING OPTIONS ####

	#Plotting options
	axes_label_x  = {'size' : 18, 'weight' : 'bold', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 18, 'weight' : 'bold', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	text_title_properties = {'weight' : 'bold', 'size' : 18}
	axes_ticks = {'labelsize' : 14}
	line = {'linewidth' : 2, 'markersize' : 5}
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
		self.__maxF = maxF_in 
		self.__meanF = meanF_in 
		self.__minF = minF_in

	def get_cycleN(self):
		return self.__cycleN
	def get_maxF(self):
		return self.__maxF
	def get_meanF(self):
		return self.__meanF
	def get_minF(self):
		return self.__minF

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

	plt.show(block = True)