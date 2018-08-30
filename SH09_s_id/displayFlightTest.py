# Display flight test

import os
import time
import sys
import pdb #pdb.set_trace()
import getopt
import shutil
import matplotlib.animation as animation
from matplotlib import gridspec

# pip install ffmpy

from moduleFunctions import *

CMDoptionsDict = {}
#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptions(sys.argv[1:], CMDoptionsDict)

#Import FTI variables definitions, hard code input data
CMDoptionsDict = importFTIdefFile(CMDoptionsDict['inputFile'], CMDoptionsDict)
reviewInputParameters(CMDoptionsDict)

# Plot settings
plotSettings = importPlottingOptions()

# ##################

varClassesGetSegmentsDict = {}
for var in ('CNT_FRC_BST_LNG', 'CNT_FRC_BST_LAT', 'CNT_FRC_BST_COL'):

	varClass = ClassVariableDef(var)

	varClass.importData(CMDoptionsDict, 'nan', varClassesGetSegmentsDict)

	varClassesGetSegmentsDict.update({var : varClass})

time_vector = varClassesGetSegmentsDict['CNT_FRC_BST_LNG'].time
nFrames = int(CMDoptionsDict['flightTestInfo']['nFrames'])
startTimeIndex = time_vector.index(float(CMDoptionsDict['flightTestInfo']['startTime']))
# lastTimeIndex = time_vector.index(4970)
# indexFrames = range(0, len(varClassesGetSegmentsDict[var].time), nFrames)
indexFrames = range(startTimeIndex, len(time_vector), nFrames)
# indexFrames = range(startTimeIndex, lastTimeIndex, nFrames)
# indexFrames = range(0, int(varClassesGetSegmentsDict[var].time[-1]), 20)

data_samplingFreq = np.power(float(CMDoptionsDict['flightTestInfo']['data_samplingFreq']), -1)
fps_outputVideo = int(np.power(nFrames*data_samplingFreq, -1))
freqPlot = np.power(time_vector[indexFrames[1]] - time_vector[indexFrames[0]], -1)

# delayTime = 0.002 * nFrames

fig = plt.figure() 
fig.set_size_inches(14, 10, forward=True)
fig.suptitle('Data visualization replay FT106, screen feed freq.: %.3f Hz' % freqPlot, **plotSettings['figure_title'])

# Multiple axes
gs = gridspec.GridSpec(1, 2, width_ratios=[3, 1]) 
ax_cycl = plt.subplot(gs[0])
ax_col = plt.subplot(gs[1])
for ax in [ax_col, ax_cycl]:
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()

xdata_cycl, ydata_cycl = [], []
xdata_col, ydata_col = [], []
ln_cycl, = ax_cycl.plot([], [], 'ko', animated=True)
ln_col, = ax_col.plot([], [], 'ko', animated=True)
time_text = ax_cycl.text(0.6, 0.95, '', transform=ax_cycl.transAxes)

def initTime():
	ax.set_title(var, **plotSettings['ax_title'])
	ax.set_ylabel('Force [N]', **plotSettings['axes_y'])
	ax.set_xlabel('Total time', **plotSettings['axes_x'])
	ax.set_xlim(0.0, varClassesGetSegmentsDict[var].time[-1])
	ax.set_ylim(min(varClassesGetSegmentsDict[var].data), max(varClassesGetSegmentsDict[var].data))
	time_text.set_text('')
	return ln, time_text

def initForces():
	global CMDoptionsDict

	#Cyclic
	ax = ax_cycl
	ax.set_xlabel('LAT forces [N]', **plotSettings['axes_x'])
	ax.set_ylabel('LNG forces [N]', **plotSettings['axes_y'])
	lat_limits = [float(t) for t in CMDoptionsDict['flightTestInfo']['lat_limits_2sys'].split(',')]
	lng_limits = [float(t) for t in CMDoptionsDict['flightTestInfo']['lng_limits_2sys'].split(',')]
	ax.set_ylim([t*1.2 for  t in lng_limits]) #LAT limits
	ax.set_xlim([t*1.2 for  t in lat_limits]) #LNG limits
	ax.plot(2*[lng_limits[0]], lat_limits, linestyle = '-.', marker = '', c = 'r')
	ax.plot(2*[lng_limits[1]], lat_limits, linestyle = '-.', marker = '', c = 'r')
	ax.plot(lng_limits, 2*[lat_limits[0]], linestyle = '-.', marker = '', c = 'r')
	ax.plot(lng_limits, 2*[lat_limits[1]], linestyle = '-.', marker = '', c = 'r')

	lat_limits_1sys = [float(t) for t in CMDoptionsDict['flightTestInfo']['lat_limits_1sys'].split(',')]
	lng_limits_1sys = [float(t) for t in CMDoptionsDict['flightTestInfo']['lng_limits_1sys'].split(',')]
	ax.plot(2*[lng_limits_1sys[0]], lat_limits_1sys, linestyle = '-.', marker = '', c = 'c')
	ax.plot(2*[lng_limits_1sys[1]], lat_limits_1sys, linestyle = '-.', marker = '', c = 'c')
	ax.plot(lng_limits_1sys, 2*[lat_limits_1sys[0]], linestyle = '-.', marker = '', c = 'c')
	ax.plot(lng_limits_1sys, 2*[lat_limits_1sys[1]], linestyle = '-.', marker = '', c = 'c')
	ax_cycl.text(lat_limits_1sys[0], lng_limits_1sys[1], '1SYS', color = 'c', verticalalignment = 'bottom')
	ax_cycl.text(lat_limits[0], lng_limits[1], '2SYS', color = 'r', verticalalignment = 'bottom')
	time_text.set_text('')
	
	#COl settings
	ax = ax_col
	ax.set_ylabel('COL forces [N]', **plotSettings['axes_y'])
	col_limits = [float(t) for t in CMDoptionsDict['flightTestInfo']['col_limits_2sys'].split(',')]
	col_limits_1sys = [float(t) for t in CMDoptionsDict['flightTestInfo']['col_limits_1sys'].split(',')]
	ax.set_xlim([0.0, 1.0]) #LAT limits
	ax.set_ylim([t*1.2 for  t in col_limits]) #LNG limits
	ax.plot([0.0, 1.0], 2*[col_limits[0]], linestyle = '-.', marker = '', c = 'r')
	ax.plot([0.0, 1.0], 2*[col_limits[1]], linestyle = '-.', marker = '', c = 'r')
	ax.plot([0.0, 1.0], 2*[col_limits_1sys[0]], linestyle = '-.', marker = '', c = 'c')
	ax.plot([0.0, 1.0], 2*[col_limits_1sys[1]], linestyle = '-.', marker = '', c = 'c')
	ax.text(0.05, col_limits[1], '2SYS', color = 'r', verticalalignment = 'bottom')
	ax.text(0.05, col_limits[0], '2SYS', color = 'r', verticalalignment = 'bottom')
	ax.text(0.05, col_limits_1sys[1], '1SYS', color = 'c', verticalalignment = 'bottom')
	ax.text(0.05, col_limits_1sys[0], '1SYS', color = 'c', verticalalignment = 'bottom')
	
	return ln_cycl, ln_col, time_text

def animateTime(frame):
	global varClassesGetSegmentsDict, delayTime

	# pdb.set_trace()
	# currentTimeIndex = varClassesGetSegmentsDict[var].time.index(frame)
	currentTime = varClassesGetSegmentsDict[var].time[frame]
	# currentTime = frame
	# currentValue = varClassesGetSegmentsDict[var].data[currentTimeIndex]
	currentValue = varClassesGetSegmentsDict[var].data[frame]
	print('frame: ' +str(frame)+', '+str(currentTime)+', '+str(currentValue))
	
	xdata.append(currentTime)
	ydata.append(currentValue)
	ln.set_data(xdata, ydata)

	time_text.set_text('current time = %.2f s' % currentTime)
	# time_text.set_position('time = %.2f s' % currentTime)
	# ax.set_xlim(0.0, 1+currentTime)
	# ax.set_ylim(1.2*currentValue, -1.2*currentValue)

	plt.pause(delayTime-0.002)
	
	return ln, time_text

def animateForce(frame):
	global varClassesGetSegmentsDict, time_vector

	currentTime = time_vector[frame]
	
	# Cyclic
	ydata_cycl.append(varClassesGetSegmentsDict['CNT_FRC_BST_LNG'].data[frame])
	xdata_cycl.append(varClassesGetSegmentsDict['CNT_FRC_BST_LAT'].data[frame])
	ln_cycl.set_data(xdata_cycl[-5:], ydata_cycl[-5:])

	#Col
	ydata_col.append(varClassesGetSegmentsDict['CNT_FRC_BST_COL'].data[frame])
	ln_col.set_data([0.5]*len(ydata_col[-5:]), ydata_col[-5:])
	time_text.set_text('current time = %.3f s' % currentTime)
	
	return ln_cycl, ln_col, time_text

# print('%.6f, %.6f' % (time.clock(), currentTime))
# time_start = time.clock()
# animate(0)
# deltaTUpdate = (time.clock() - time_start)
# time_start = time.clock()
# animate(0)
# deltaTUpdate2 = (time.clock() - time_start)

print('\n' +'-> Recording video...')
anim = animation.FuncAnimation(fig, animateForce, interval = 0.000000000001,frames=indexFrames, init_func=initForces, repeat= False, blit=True)
Writer = animation.writers['ffmpeg']
writer = Writer(fps= fps_outputVideo, metadata=dict(artist='Alejandro Valverde', title='FT106'), bitrate=400)
anim.save('C:\\Users\\valverdea\\Documents\\out_video\\full-FT106.mp4', writer=writer)
# anim.save('animation.mp4')
# plt.show()