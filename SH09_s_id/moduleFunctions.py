import os
import sys
import numpy as np
import matplotlib as mlt
mlt.rcParams.update({'figure.max_open_warning': 0})
import matplotlib.pyplot as plt
import scipy.stats as st
import scipy.linalg as lalg
import statistics as stat
from scipy import interpolate
from scipy import signal
import math
import copy
import getopt
import pdb #pdb.set_trace()
import cmath

def importPlottingOptions():
	#### PLOTTING OPTIONS ####

	#Plotting options
	axes_label_x  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	figure_text_title_properties = {'weight' : 'bold', 'size' : 16}
	ax_text_title_properties = {'weight' : 'regular', 'size' : 14}
	axes_ticks = {'labelsize' : 10}
	line = {'linewidth' : 1.5, 'markersize' : 4}
	scatter = {'linewidths' : 1.0}
	legend = {'fontsize' : 10, 'loc' : 'best'}
	grid = {'alpha' : 0.7}
	colors = ['k', 'b', 'y', 'm', 'r', 'c', 'g', 'k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c','k', 'b', 'y', 'm', 'r', 'c']
	markers = ['o', 'v', '^', 's', '*', '+']
	linestyles = ['-', '--', '-.', ':']
	axes_ticks_n = {'x_axis' : 3} #Number of minor labels in between 
	figure_settings = {'dpi' : 200}

	plotSettings = {'axes_x':axes_label_x,'axes_y':axes_label_y, 'figure_title':figure_text_title_properties, 'ax_title':ax_text_title_properties,
	                'axesTicks':axes_ticks, 'line':line, 'legend':legend, 'grid':grid, 'scatter':scatter,
	                'colors' : colors, 'markers' : markers, 'linestyles' : linestyles, 'axes_ticks_n' : axes_ticks_n,
	                'figure_settings' : figure_settings}

	return plotSettings

def readCMDoptions(argv, CMDoptionsDict):

	short_opts = "f:o:p:" #"o:f:"
	long_opts = ["inputFile=","outputFlag=","executionOption="] #["option=","fileName="]
	try:
		opts, args = getopt.getopt(argv,short_opts,long_opts)
	except getopt.GetoptError:
		raise ValueError('ERROR: Not correct input to script')

	# check input
	# if len(opts) != len(long_opts):
		# raise ValueError('ERROR: Invalid number of inputs')	

	for opt, arg in opts:

		if opt in ("-f", "--inputFile"):
			# postProcFolderName = arg

			CMDoptionsDict['inputFile'] = arg

		elif opt in ("-o", "--outputFlag"):

			if arg.lower() in ('true', 't'):
				CMDoptionsDict['outputFlag'] = True
			elif arg.lower() in ('false', 'f'):
				CMDoptionsDict['outputFlag'] = False

		elif opt in ("-p", "--executionOption"):

			if arg.lower() in ('cav', 't'):
				CMDoptionsDict['cavitationFlag'] = True
				CMDoptionsDict['FRF'] = False
			elif arg.lower() in ('frf'):
				CMDoptionsDict['cavitationFlag'] = False
				CMDoptionsDict['FRF'] = True
			else:
				CMDoptionsDict['cavitationFlag'] = False
				CMDoptionsDict['FRF'] = False


	return CMDoptionsDict

class testClassDef(object):
	"""docstring for testClass"""
	def __init__(self, name_in):
		# self.arg = arg
		self.name = name_in

	def includeTimeSegmentsFreq(self, varClassesDict, dof, plotSettings, CMDoptionsDict):

		classExample = varClassesDict['CNT_DST_'+dof]

		self.timeSegments = classExample.timeSegments

		freqSegments = []
		
		for timeSegment in self.timeSegments:

			freqSegments += [np.power(2*(timeSegment[-1]-timeSegment[0]), -1)]

		self.freqSegments = freqSegments

		print('-> Characteristic pilot frequencies per segment [Hz]:')
		print('--> '+','.join([str(round(t, 3)) for t in freqSegments]))

		#Weights
		freqWeightSegments = calculateSelfWeight(freqSegments)
		self.freqWeightSegments = freqWeightSegments
		print('-> Characteristic pilot frequencies weights per segment [Hz]:')
		print('--> '+','.join([str(round(t, 3)) for t in freqWeightSegments]))

		self.freqSegmentsMaxWeight = freqSegments[freqWeightSegments.index(min(freqWeightSegments))]

		#Plot weights
		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)
		ax.bar(freqSegments, freqWeightSegments,width = calculateBarWidth(freqSegments, 0.02), align='center')
		ax.set_title('Pilot input freq. weights for each data partition', **plotSettings['ax_title'])
		ax.set_xlabel('Pilot input freq. measured [Hz]', **plotSettings['axes_x'])
		ax.set_ylabel('Pilot input freq. weights', **plotSettings['axes_y'])
		usualSettingsAX(ax, plotSettings)
		figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), 'inputFreqWeights.png'), dpi = plotSettings['figure_settings']['dpi'])

	def getSegmentParameters(self, varClassesDict, dof, plotSettings, CMDoptionsDict):

		forceSegments = varClassesDict['CNT_FRC_BST_'+dof].dataSegments

		characteristicForceSegments = []

		for forceSegment in forceSegments:

			characteristicForceSegments += [np.mean(forceSegment)]

		self.characteristicForceSegments = characteristicForceSegments

		print('-> Characteristic forces per segment [N]:')
		print('--> '+','.join([str(round(t, 3)) for t in characteristicForceSegments]))

		#Weights
		characteristicForceWeightSegments = calculateSelfWeight(characteristicForceSegments)
		self.characteristicForceWeightSegments = characteristicForceWeightSegments
		print('-> Characteristic forces weights per segment:')
		print('--> '+','.join([str(round(t, 3)) for t in characteristicForceWeightSegments]))

		# self.characteristicForceSegmentsMaxWeight = characteristicForceSegments[characteristicForceWeightSegments.index(min(characteristicForceWeightSegments))]
		self.characteristicForceSegmentsMaxWeight = -300

		#Plot weights
		figure, ax = plt.subplots(1, 1)
		figure.set_size_inches(10, 6, forward=True)
		ax.bar(characteristicForceSegments, characteristicForceWeightSegments,width = calculateBarWidth(characteristicForceSegments, 0.02),align='center')
		ax.set_title('Force weights for each data partition', **plotSettings['ax_title'])
		ax.set_xlabel('Mean force measured [N]', **plotSettings['axes_x'])
		ax.set_ylabel('Measured force weights', **plotSettings['axes_y'])
		usualSettingsAX(ax, plotSettings)
		figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), 'forceWeights.png'), dpi = plotSettings['figure_settings']['dpi'])

	def identifyFirstOrder(self, varClassesDict, dof, plotSettings, CMDoptionsDict, varClassesGetSegmentsDict):

		def standRegressor(v):
			
			mean_v = np.mean(v)
			# Standard deviation calculation
			p = 0
			for v_i in v: 
			    p += np.power(v_i - mean_v, 2)		
			sxx = p

			stdRegre = []

			for v_i in v:

				stdRegre += [(v_i - mean_v)/np.sqrt(sxx) ]

			return np.vstack(stdRegre), float(sxx)

		def regressionMethodIdentification(regre1, regre2, z, standardRegressorsFlag):
			
			################ OPER #########################

			if standardRegressorsFlag:

				std_regre1, sjj_regre1 = standRegressor(regre1)
				std_regre2, sjj_regre2 = standRegressor(regre2)
				std_z, szz_z = standRegressor(z)

				# std_X = np.hstack((np.ones_like(regre1), std_regre1, -std_regre2)) #Seems to be incorrect 08.03.2019
				std_X = np.hstack((std_regre1, -std_regre2)) #Correction 08.03.2019

				N = std_z.shape[0]
				n_p = std_X.shape[1] #Shall be equal to 2

				std_D = lalg.inv( np.matmul(std_X.T, std_X) )
				std_theta_est = np.matmul(np.matmul(std_D, std_X.T), std_z)

				# Get estimation not standard
				theta_est_0 = np.mean(z) - ( (float(std_theta_est[0]) * np.sqrt(szz_z/sjj_regre1) * np.mean(regre1)) + (float(std_theta_est[1])  * np.sqrt(szz_z/sjj_regre2) * np.mean(regre2)) ) #Correction 08.03.2019
				# theta_est = np.array([[float(std_theta_est[0]) * np.sqrt(szz_z)], [float(std_theta_est[1]) * np.sqrt(szz_z/sjj_regre1)], [float(std_theta_est[2]) * np.sqrt(szz_z/sjj_regre2)]]) #Seems to be incorrect 08.03.2019		
				theta_est = np.array([[theta_est_0], [float(std_theta_est[0]) * np.sqrt(szz_z/sjj_regre1)], [float(std_theta_est[1]) * np.sqrt(szz_z/sjj_regre2)]]) #Correction 08.03.2019	

				# Get residuals and y_est
				X = np.hstack((np.ones_like(regre1), regre1, -regre2))
				D = lalg.inv( np.matmul(X.T, X) )
				y_est = np.matmul(X, theta_est)
				res = z - y_est
				sigmaSQRT = np.matmul(res.T, res) / (N-n_p)

			else:
				### LOOP for non standard regressors
				# Matrix X
				X = np.hstack((np.ones_like(regre1), regre1, -regre2))

				N = z.shape[0]
				n_p = X.shape[1] #Shall be equal to 2

				D = lalg.inv( np.matmul(X.T, X) )
				theta_est = np.matmul(np.matmul(D, X.T), z)

				y_est = np.matmul(X, theta_est)

				res = z - y_est

				sigmaSQRT = np.matmul(res.T, res) / (N-n_p)
				sig = np.sqrt(sigmaSQRT)


			#Results
			interval_theta1 = float(2*np.sqrt(sigmaSQRT * D[0,0]))
			interval_theta2 = float(2*np.sqrt(sigmaSQRT * D[1,1]))
			interval_theta3 = float(2*np.sqrt(sigmaSQRT * D[2,2]))
			intervals = [interval_theta1, interval_theta2, interval_theta3]

			return theta_est, y_est, res, sigmaSQRT, intervals

		def identifyOuterLoop(inputClass, outputClass, segmentID, standardRegressorsFlag, delayFlag):

			# Input
			delta_u = np.vstack(inputClass.dataIncrementSegments[segmentID])
			delta_u_time = np.vstack(inputClass.timeSegments[segmentID])
			delta_u_delay = np.vstack(inputClass.dataIncrementSegments_delay[segmentID])
			delta_u_time_delay = np.vstack(inputClass.timeSegments_delay[segmentID])

			# Output
			delta_x1 = np.vstack(outputClass.dataIncrementSegments[segmentID])
			delta_x1_time = np.vstack(outputClass.timeSegments[segmentID])

			# Velocity output
			dot_x1 = np.vstack(outputVelClass.dataSegments[segmentID])

			#Time delay considered
			timeDelayLow = inputClass.timeDelay

			################# MODEL #######################
			# theta = [theta_0 theta_1  theta_2]' = [1  k_l/lambda_a  k_a/lambda_a]'
			# eq: dot_x1 = bias + delta_u * k_l/lambda_a - delta_x1 * k_a/lambda_a

			################ OPER #########################
			if delayFlag:
				theta_est, y_est, res, sigmaSQRT, interval_theta = regressionMethodIdentification(delta_u_delay, delta_x1, dot_x1, standardRegressorsFlag) #regre1, regre2, z
			else:
				theta_est, y_est, res, sigmaSQRT, interval_theta = regressionMethodIdentification(delta_u, delta_x1, dot_x1, standardRegressorsFlag) #regre1, regre2, z
			
			################ RESULTS #########################
			theta_1 = theta_est[1]
			theta_1_max = theta_est[1] + interval_theta[1]
			theta_1_min = theta_est[1] - interval_theta[1]
			theta_2 = theta_est[2]
			theta_2_max = theta_est[2] + interval_theta[2]
			theta_2_min = theta_est[2] - interval_theta[2]

			k = theta_1 / theta_2
			interval_k = abs((theta_1_max/theta_2_min) - (theta_1_min/theta_2_max))/2
			T = np.power(theta_2, -1)
			interval_T = abs(np.power(theta_2_min, -1) - np.power(theta_2_max, -1))/2

			if delayFlag:
				yout = (k *delta_u_delay) - (T*dot_x1) + (T*theta_est[0]*np.ones_like(dot_x1))
			else:
				yout = (k *delta_u) - (T*dot_x1) + (T*theta_est[0]*np.ones_like(dot_x1))

			res_yout = yout - delta_x1

			regresionVectorsDict = {'yout':yout, 
									'res_yout':res_yout,
									'delta_u':delta_u,
									'delta_u_time':delta_u_time,
									'delta_u_delay':delta_u_delay,
									'delta_u_time_delay':delta_u_time_delay,
									'delta_x1':delta_x1,
									'delta_x1_time':delta_x1_time,
									'dot_x1':dot_x1,
									'y_est':y_est,
									'res':res,
									'res_yout':res_yout}
			
			return float(k), float(interval_k), float(T), float(interval_T), timeDelayLow, regresionVectorsDict

		# Start function

		# Input classes
		inputClass = varClassesDict['CNT_DST_'+dof]
		inputVelClass = varClassesDict['DIF_CNT_DST_'+dof]
		outputClass = varClassesDict['CNT_DST_BST_'+dof]
		outputVelClass = varClassesDict['DIF_CNT_DST_BST_'+dof]
		forceClass = varClassesDict['CNT_FRC_BST_'+dof]

		# Output file
		file = open(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), 'identificationResults.csv'), 'w')
		for key in CMDoptionsDict['flightTestInfo'].keys():
			file.write(','.join([key, CMDoptionsDict['flightTestInfo'][key]]) + '\n')
		header1 = ['Segment', 't1 (s)', 't2 (s)', 'delta_t (s)', 'tau_input (s)', 'Mean F (N)', 'Pilot f. (Hz)', 'k', '+- delta_k','T (s)', '+- delta_T','u (t=0)','delta_u','x1 (t=0)']
		file.write(','.join(header1) + '\n')

		standardRegressorsFlag = CMDoptionsDict['flightTestInfo']['standardRegressorsFlag'].lower() == 'true'
		delayFlag = CMDoptionsDict['flightTestInfo']['delayFlag'].lower() == 'true'
		optimizeTimeDelayLowFlag = CMDoptionsDict['flightTestInfo']['optimizeTimeDelayLowFlag'].lower() == 'true'

		if standardRegressorsFlag:
			print('\n'+'* Identification results per segment (standardized regressors)')
		else:
			print('\n'+'* Identification results per segment (non-standardized regressors)')
		
		rowCounter = printRowTable('headerSID', 15, 1)

		kSegments = []
		TSegments = []
		timeDelayLowSegments = []
		kSegmentsInterval = []
		TSegmentsInterval = []

		for segmentID in range(len(inputClass.dataIncrementSegments)):

			if not optimizeTimeDelayLowFlag:

				k, interval_k, T, interval_T, timeDelayLow = identifyOuterLoop(inputClass, outputClass, segmentID, standardRegressorsFlag, delayFlag)

			else: #Time delay optimization
				timeDelaysLowVector = np.arange(-0.08, 0.0, 0.006)
				intervals_T, intervals_k = [], []

				for currentTimeDelaysLowVector in timeDelaysLowVector:
					
					# Get a copy of CMD dict
					tempCMDDict = copy.deepcopy(CMDoptionsDict) #deep copy remove likage with original dict for inner variables
					tempCMDDict['flightTestInfo'].update({'timeDelay' : currentTimeDelaysLowVector})

					# New input class
					tempInputClass = ClassVariableDef(inputClass.name)
					tempInputClass.importData(tempCMDDict, 'segment', varClassesGetSegmentsDict)
					tempInputClass.convertToIncrement()

					k, interval_k, T, interval_T, timeDelayLow, regresionVectorsDict = identifyOuterLoop(tempInputClass, outputClass, segmentID, standardRegressorsFlag, delayFlag)

					assert timeDelayLow == currentTimeDelaysLowVector, 'ERROR: Incorrect time delay considered'
					intervals_k += [interval_k]
					intervals_T += [interval_T]

				# Optimization plot
				figure, ax = plt.subplots(1, 1)
				figure.set_size_inches(10, 8, forward=True)
				figure.suptitle(str(segmentID+1)+' sub-set, '+str(inputClass.timeSegments[segmentID][0])+'s to '+str(inputClass.timeSegments[segmentID][-1])+' s', **plotSettings['figure_title']) #  /  k :'+str(round(float(k),2))+'$\pm$'+str(round(float(interval_k),3))+', T :'+str(round(float(T),2))+'$\pm$'+str(round(float(interval_T),3))+'s'
				ax.plot(timeDelaysLowVector, intervals_T, linestyle = '-', marker = 'o', c = plotSettings['colors'][1], label = '$\pm \Delta T/2$', **plotSettings['line'])
				ax.set_ylabel('$\pm \Delta/2$', **plotSettings['axes_y'])
				ax.set_xlabel('Time delay $\\tau_{input} $ [seconds]', **plotSettings['axes_x'])
				ax.legend(**plotSettings['legend'])
				doubleAx_y = usualSettingsAX(ax, plotSettings)
				figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), str(segmentID+1)+'_timeDelayOptimization.png'), dpi = plotSettings['figure_settings']['dpi'])
				
				# Optimization results
				indexMinError_k = intervals_k.index(min(intervals_k))
				indexMinError_T = intervals_T.index(min(intervals_T))
				if not indexMinError_k == indexMinError_T:
					indexMinError = int(min([indexMinError_k, indexMinError_T]) + (abs(indexMinError_k - indexMinError_T)/2))
				else:
					indexMinError = indexMinError_k
				finalTimeDelay = timeDelaysLowVector[indexMinError]

				# Get a copy of CMD dict
				tempCMDDict = copy.deepcopy(CMDoptionsDict)
				tempCMDDict['flightTestInfo'].update({'timeDelay' : finalTimeDelay})

				# New input class
				tempInputClass = ClassVariableDef(inputClass.name)
				tempInputClass.importData(tempCMDDict, 'segment', varClassesGetSegmentsDict)
				tempInputClass.convertToIncrement()

				k, interval_k, T, interval_T, timeDelayLow, regresionVectorsDict = identifyOuterLoop(tempInputClass, outputClass, segmentID, standardRegressorsFlag, delayFlag)
			
			kSegments += [k]
			TSegments += [T]
			timeDelayLowSegments += [timeDelayLow]
			kSegmentsInterval += [interval_k]
			TSegmentsInterval += [interval_T]

			################ PLOT RESULTS #########################
			figure, axs = plt.subplots(4, 1, sharex='col')
			figure.set_size_inches(14, 12, forward=True)
			figure.suptitle(str(segmentID+1)+' sub-set, '+str(inputClass.timeSegments[segmentID][0])+'s to '+str(inputClass.timeSegments[segmentID][-1])+'s  /  $\\tau_{input}=$'+str(round(timeDelayLow, 2))+'s  /  k :'+str(round(float(k),4))+'$\pm$'+str(round(float(interval_k),3))+', T :'+str(round(float(T),2))+'$\pm$'+str(round(float(interval_T),3))+'s', **plotSettings['figure_title'])

			# Force measurement
			axs[0].set_title(forceClass.name, **plotSettings['ax_title'])
			axs[0].plot(forceClass.timeSegments[segmentID], forceClass.dataSegments[segmentID], linestyle = '-', marker = '', c = plotSettings['colors'][4], label = 'Measured force', **plotSettings['line'])
			axs[0].plot([forceClass.timeSegments[segmentID][0], forceClass.timeSegments[segmentID][-1]], 2*[self.characteristicForceSegments[segmentID]], linestyle = '-.', marker = '', c = plotSettings['colors'][0], label = 'Reference measured force', **plotSettings['line'])
			axs[0].legend(**plotSettings['legend'])
			axs[0].set_ylabel('Force [N]', **plotSettings['axes_y'])
			doubleAx_y = usualSettingsAX(axs[0], plotSettings)
						
			# Velocity
			axs[1].set_title(outputVelClass.name, **plotSettings['ax_title'])
			axs[1].plot(regresionVectorsDict['delta_x1_time'], regresionVectorsDict['dot_x1'], linestyle = '-', marker = '', c = plotSettings['colors'][4], label = 'Measured output', **plotSettings['line'])
			axs[1].plot(regresionVectorsDict['delta_x1_time'], regresionVectorsDict['y_est'], linestyle = '-.', marker = '', c = plotSettings['colors'][1], label = 'Estimated output', **plotSettings['line'])
			axs[1].set_ylabel('Vel. [mm/s]', **plotSettings['axes_y'])
			axs[1].grid(which='both', **plotSettings['grid'])
			axs[1].tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			axs[1].minorticks_on()
			handles = axs[1].get_legend_handles_labels()[0]
			#Double y-axis 
			doubleAx_y = axs[1].twinx()
			doubleAx_y.plot(regresionVectorsDict['delta_x1_time'], regresionVectorsDict['res'], linestyle = '', marker = 'o', c = plotSettings['colors'][3], label = 'Residuals output', **plotSettings['line'])
			handles_doubleAx_y = doubleAx_y.get_legend_handles_labels()[0]
			# doubleAx_y.legend(**plotSettings['legend'])
			doubleAx_y.set_ylabel('Residuals vel. [mm/s]', **plotSettings['axes_x'])
			axs[1].legend(handles = handles+handles_doubleAx_y, **plotSettings['legend'])


			################ PLOT RESULTS DISPLACEMENT #########################
			############ Simulation of TF, throws error
			# instantaneusTF = signal.TransferFunction([k], [T, 1])
			# simInput = np.hstack(delta_u)
			# simInputTime = np.hstack(delta_u_time)
			# tout, yout, xout = signal.lsim(instantaneusTF, simInput.astype(object), simInputTime.astype(object))

			
			# Displacement output
			axs[2].set_title(outputClass.name, **plotSettings['ax_title'])
			axs[2].plot(regresionVectorsDict['delta_x1_time'], regresionVectorsDict['delta_x1'], linestyle = '-', marker = '', c = plotSettings['colors'][4], label = 'Measured output', **plotSettings['line'])
			axs[2].plot(regresionVectorsDict['delta_x1_time'], regresionVectorsDict['yout'], linestyle = '-.', marker = '', c = plotSettings['colors'][1], label = 'Estimated output', **plotSettings['line'])
			axs[2].set_ylabel('Displ. [mm]', **plotSettings['axes_y'])
			axs[2].grid(which='both', **plotSettings['grid'])
			axs[2].tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			axs[2].minorticks_on()
			handles = axs[2].get_legend_handles_labels()[0]
			#Double y-axis 
			doubleAx_y = axs[2].twinx()
			doubleAx_y.plot(regresionVectorsDict['delta_x1_time'], regresionVectorsDict['res_yout'], linestyle = '', marker = 'o', c = plotSettings['colors'][3], label = 'Residuals output', **plotSettings['line'])
			handles_doubleAx_y = doubleAx_y.get_legend_handles_labels()[0]
			doubleAx_y.set_ylabel('Residuals displ. [mm]', **plotSettings['axes_x'])
			axs[2].legend(handles = handles+handles_doubleAx_y, **plotSettings['legend'])

			# Input
			axs[3].set_title(inputClass.name + ', '+inputVelClass.name, **plotSettings['ax_title'])
			axs[3].plot(regresionVectorsDict['delta_u_time'], regresionVectorsDict['delta_u'], linestyle = '-', marker = '', c = plotSettings['colors'][4], label = 'Measured input displ.', **plotSettings['line'])
			axs[3].plot(regresionVectorsDict['delta_u_time_delay'], regresionVectorsDict['delta_u_delay'], linestyle = '--', marker = '', c = plotSettings['colors'][3], label = 'Measured input displ. ($t+\\tau$)', **plotSettings['line'])
			axs[3].set_xlabel('Time [seconds]', **plotSettings['axes_x'])
			axs[3].set_ylabel('Displ. [mm]', **plotSettings['axes_y'])
			axs[3].grid(which='both', **plotSettings['grid'])
			axs[3].tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			axs[3].minorticks_on()
			handles = axs[3].get_legend_handles_labels()[0]
			#Double y-axis 
			doubleAx_y = axs[3].twinx()
			doubleAx_y.plot(regresionVectorsDict['delta_u_time'], inputVelClass.dataSegments[segmentID], linestyle = '-.', marker = '', c = plotSettings['colors'][4], label = 'Measured input vel.', **plotSettings['line'])
			handles_doubleAx_y = doubleAx_y.get_legend_handles_labels()[0]
			doubleAx_y.set_ylabel('Vel. [mm/s]', **plotSettings['axes_x'])
			axs[3].legend(handles = handles+handles_doubleAx_y, **plotSettings['legend'])

			# Ax titles
			#Save figures
			figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), str(segmentID+1)+'_identificationResult.png'), dpi = plotSettings['figure_settings']['dpi'])
			plt.clf() #Close figure
			
			# CMD output
			identificationRowOutPut = [segmentID+1, inputClass.timeSegments[segmentID][0], inputClass.timeSegments[segmentID][-1], inputClass.timeSegments[segmentID][-1]-inputClass.timeSegments[segmentID][0], timeDelayLow,self.characteristicForceSegments[segmentID], self.freqSegments[segmentID], float(kSegments[segmentID]), float(interval_k),float(TSegments[segmentID]), float(interval_T),inputClass.dataInitialValues[segmentID],inputClass.differenceFirstAndLastValues[segmentID],outputClass.dataInitialValues[segmentID]]
			rowCounter = printRowTable(identificationRowOutPut, 15, rowCounter)

			#File save
			file.write(','.join([str(t) for t in identificationRowOutPut]) + '\n')

		# output
		self.inputDifferenceFirstAndLastValues = inputClass.differenceFirstAndLastValues
		self.inputInitialValues = inputClass.dataInitialValues
		self.outputInitialValues = outputClass.dataInitialValues
		self.kSegments = kSegments
		self.TSegments = TSegments
		self.timeDelayLowSegments = timeDelayLowSegments
		self.kSegmentsInterval = kSegmentsInterval
		self.TSegmentsInterval = TSegmentsInterval

		file.close()

	def checkDeviation(self, i, CMDoptionsDict):

		list_bools = []
		# accuraccy = float(CMDoptionsDict['flightTestInfo']['deviation_accuracy']) #%
		# list_bools += [abs(float(self.kSegmentsInterval[i] / self.kSegments[i]) * 100) < accuraccy ]			
		# list_bools += [abs(float(self.TSegmentsInterval[i] / self.TSegments[i]) * 100) < accuraccy ]
		list_bools += [float(self.kSegmentsInterval[i]) < float(CMDoptionsDict['flightTestInfo']['max_allowed_k_interval']) ]
		list_bools += [float(self.TSegmentsInterval[i]) < float(CMDoptionsDict['flightTestInfo']['max_allowed_T_interval']) ]

		return list_bools

	def showInfluenceForceAndPilotFreq(self, plotSettings, CMDoptionsDict):

		figure, axs = plt.subplots(2, 2, sharex='col')
		figure.set_size_inches(14, 10, forward=True)
		
		# Show influence of input freq, find "constant" force
		ax_k_freq = axs[0,0]
		ax_T_freq = axs[1,0]

		print('\n'+'* Influence of pilot input freq. for "constant" measured mean force, identification results')
		rowCounter = printRowTable('headerSID', 15, 1)
		
		margin = float(CMDoptionsDict['flightTestInfo']['margin_force'])
		characteristicForceSegmentChosen = []
		while not characteristicForceSegmentChosen: #While the list is empty
			indexSegmentsChosen, indexCurrentSegment, characteristicForceSegmentChosen = [], 0, []
			print('-> Searching for data segments with "constant" force, reference value: '+str(round(self.characteristicForceSegmentsMaxWeight, 3))+'N, margin: '+str(margin)+'%')
			for characteristicForceSegment in self.characteristicForceSegments:

				if abs(characteristicForceSegment-self.characteristicForceSegmentsMaxWeight) < ((margin/100)*abs(self.characteristicForceSegmentsMaxWeight)) and all(self.checkDeviation(indexCurrentSegment, CMDoptionsDict)):
					indexSegmentsChosen += [indexCurrentSegment]
					characteristicForceSegmentChosen += [characteristicForceSegment]

				indexCurrentSegment += 1

			margin += 5.0

		# Plot results
		k_plot_posInput, T_plot_posInput, k_plot_negInput, T_plot_negInput, freq_plot_posInput, freq_plot_negInput = [], [], [], [], [], []

		for i in indexSegmentsChosen:
			if self.inputDifferenceFirstAndLastValues[i] > 0.0:
				k_plot_posInput += [self.kSegments[i]]
				T_plot_posInput += [self.TSegments[i]]
				freq_plot_posInput += [self.freqSegments[i]]
			else:
				k_plot_negInput += [self.kSegments[i]]
				T_plot_negInput += [self.TSegments[i]]
				freq_plot_negInput += [self.freqSegments[i]]
			rowCounter = printRowTable([i+1, self.timeSegments[i][0], self.timeSegments[i][-1], self.timeSegments[i][-1]-self.timeSegments[i][0], self.timeDelayLowSegments[i],self.characteristicForceSegments[i], self.freqSegments[i], float(self.kSegments[i]), float(self.kSegmentsInterval[i]),float(self.TSegments[i]), float(self.TSegmentsInterval[i]),self.inputInitialValues[i],self.inputDifferenceFirstAndLastValues[i],self.outputInitialValues[i]], 15, rowCounter)

		ax_T_freq.scatter( freq_plot_posInput, T_plot_posInput, marker = 'o', c = plotSettings['colors'][1], **plotSettings['scatter'])
		ax_T_freq.scatter( freq_plot_negInput, T_plot_negInput, marker = 'o', c = plotSettings['colors'][2], **plotSettings['scatter'])
		ax_k_freq.scatter( freq_plot_posInput, k_plot_posInput, marker = 'o', c = plotSettings['colors'][1], **plotSettings['scatter'])
		ax_k_freq.scatter( freq_plot_negInput, k_plot_negInput, marker = 'o', c = plotSettings['colors'][2], **plotSettings['scatter'])

		ax_T_freq.set_ylabel('Time constant, $T$ [s]', **plotSettings['axes_y'])
		ax_k_freq.set_ylabel('Gain, $k$', **plotSettings['axes_y'])
		ax_T_freq.set_xlabel('Pilot input freq. [Hz]', **plotSettings['axes_x'])
		ax_k_freq.set_title('Mean force measured, range '+str(round(min(characteristicForceSegmentChosen), 2))+'N to '+str(round(max(characteristicForceSegmentChosen), 2))+'N', **plotSettings['axes_y'])

		handle_pos = plt.Line2D([],[], color=plotSettings['colors'][1], marker='o', linestyle='', label='$\Delta u > 0$')
		handle_neg = plt.Line2D([],[], color=plotSettings['colors'][2], marker='o', linestyle='', label='$\Delta u < 0$')
		handles = [handle_pos, handle_neg]
		ax_T_freq.legend(handles = handles, **plotSettings['legend'])
		ax_k_freq.legend(handles = handles, **plotSettings['legend'])
		# Final axis adjustments
		doubl_y_ax_T_freq = usualSettingsAX(ax_T_freq, plotSettings)
		doubl_y_ax_k_freq = usualSettingsAX(ax_k_freq, plotSettings)
		#####################################
		print('\n'+'* Influence of measured mean force for "constant" pilot input freq., identification results')
		rowCounter = printRowTable('headerSID', 15, 1)
		ax_k_force = axs[0,1]
		ax_T_force = axs[1,1]

		# Show influence of force, find "constant" input freq.
		margin = float(CMDoptionsDict['flightTestInfo']['margin_freq'])
		characteristicFreqSegmentChosen = []
		while not characteristicFreqSegmentChosen: #While the list is empty
			indexSegmentsChosen, indexCurrentSegment, characteristicFreqSegmentChosen = [], 0, []
			print('-> Searching for data segments with "constant" pilot input freq., reference value: '+str(round(self.freqSegmentsMaxWeight, 3))+'Hz, margin: '+str(margin)+'%')
			for freqSegment in self.freqSegments:

				if abs(freqSegment-self.freqSegmentsMaxWeight) < ((margin/100)*abs(self.freqSegmentsMaxWeight)) and all(self.checkDeviation(indexCurrentSegment, CMDoptionsDict)):
					indexSegmentsChosen += [indexCurrentSegment]
					characteristicFreqSegmentChosen += [freqSegment]

				indexCurrentSegment += 1

			margin += 5.0

		# Plot results
		k_plot_posInput, T_plot_posInput, k_plot_negInput, T_plot_negInput, force_plot_posInput, force_plot_negInput = [], [], [], [], [], []

		for i in indexSegmentsChosen:
			if self.inputDifferenceFirstAndLastValues[i] > 0.0:
				k_plot_posInput += [self.kSegments[i]]
				T_plot_posInput += [self.TSegments[i]]
				force_plot_posInput += [self.characteristicForceSegments[i]]
			else:
				k_plot_negInput += [self.kSegments[i]]
				T_plot_negInput += [self.TSegments[i]]
				force_plot_negInput += [self.characteristicForceSegments[i]]
			rowCounter = printRowTable([i+1, self.timeSegments[i][0], self.timeSegments[i][-1], self.timeSegments[i][-1]-self.timeSegments[i][0], self.timeDelayLowSegments[i], self.characteristicForceSegments[i], self.freqSegments[i], float(self.kSegments[i]), float(self.kSegmentsInterval[i]),float(self.TSegments[i]), float(self.TSegmentsInterval[i]),self.inputInitialValues[i],self.inputDifferenceFirstAndLastValues[i],self.outputInitialValues[i]], 15, rowCounter + 1)

		ax_T_force.scatter( force_plot_posInput, T_plot_posInput, marker = 'o', c = plotSettings['colors'][1], **plotSettings['scatter'])
		ax_T_force.scatter( force_plot_negInput, T_plot_negInput, marker = 'o', c = plotSettings['colors'][2], **plotSettings['scatter'])
		ax_k_force.scatter( force_plot_posInput, k_plot_posInput, marker = 'o', c = plotSettings['colors'][1], **plotSettings['scatter'])
		ax_k_force.scatter( force_plot_negInput, k_plot_negInput, marker = 'o', c = plotSettings['colors'][2], **plotSettings['scatter'])

		ax_T_force.set_xlabel('Mean force measured. [N]', **plotSettings['axes_x'])
		ax_k_force.set_title('Pilot input freq. [Hz], range '+str(round(min(characteristicFreqSegmentChosen), 3))+'Hz to '+str(round(max(characteristicFreqSegmentChosen), 3))+'Hz', **plotSettings['axes_y'])

		ax_T_force.legend(handles = handles, **plotSettings['legend'])
		ax_k_force.legend(handles = handles, **plotSettings['legend'])

		# Final axis adjustments
		doubl_y_ax_T_force = usualSettingsAX(ax_T_force, plotSettings)
		doubl_y_ax_k_force = usualSettingsAX(ax_k_force, plotSettings)
		doubl_y_ax_T_force.set_ylabel('Time constant, $T$ [s]', **plotSettings['axes_x'])
		doubl_y_ax_k_force.set_ylabel('Gain, $k$', **plotSettings['axes_x'])

		figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), 'influenceForceAndPilotFreq.png'), dpi = plotSettings['figure_settings']['dpi'])

	def showInfluenceParameters(self, plotSettings, CMDoptionsDict):

		# CMD output
		print('\n'+'* Parameter study, valid time segments:')
		rowCounter = printRowTable('headerSID', 15, 1)

		figure, axs = plt.subplots(3, 6, sharey='row', sharex='col')
		figure.set_size_inches(18, 10, forward=True)

		axsDict = 	{'k_u0' : axs[0,0],
					'k_x10' : axs[0,1],
					'k_fInput' : axs[0,2],
					'k_force' : axs[0,3],
					'k_deltaU' : axs[0,4],
					'k_delta' : axs[0,5],
					'T_u0' : axs[1,0],
					'T_x10' : axs[1,1],
					'T_fInput' : axs[1,2],
					'T_force' : axs[1,3],
					'T_deltaU' : axs[1,4],
					'T_delta' : axs[1,5],
					'delta_u0' : axs[2,0],
					'delta_x10' : axs[2,1],
					'delta_fInput' : axs[2,2],
					'delta_force' : axs[2,3],
					'delta_deltaU' : axs[2,4],
					'delta_delta' : axs[2,5]}

		axsDictSettings = 	{'_u0' : ['$u_{t=0}$ [%]', 'Initial value pilot input'],
							'_x10' : ['$x_{1,t=0}$ [mm]', 'Initial value piston displ.'],
							'_fInput' : ['$f_{pilot}$ [Hz]', 'Pilot input freq.'],
							'_force' : ['$\\bar{F}$ [N]', 'Mean booster link force'],
							'_delta' : ['$\pm \Delta/2$', 'Parameter est. 95\% conf. interval'],
							'_deltaU' : ['$\Delta u$ [%]', 'Increment of pilot input']}

		axsDict['T_u0'].set_ylabel('Time constant, $T$ [s]', **plotSettings['axes_y'])
		axsDict['k_u0'].set_ylabel('Gain, $k$', **plotSettings['axes_y'])
		axsDict['delta_u0'].set_ylabel('Time delay $\\tau_{input} $ [s]', **plotSettings['axes_y'])

		for key in axsDictSettings.keys():
			axsDict['k'+key].set_title(axsDictSettings[key][1], **plotSettings['ax_title'])
			axsDict['T'+key].set_xlabel(axsDictSettings[key][0], **plotSettings['axes_x'])

		# Segments filtering
		indexSegmentsChosen = []
		for currentSegmentID in range(len(self.timeSegments)):
			if all(self.checkDeviation(currentSegmentID, CMDoptionsDict)):
				indexSegmentsChosen += [currentSegmentID]
				rowCounter = printRowTable([currentSegmentID+1, self.timeSegments[currentSegmentID][0], self.timeSegments[currentSegmentID][-1], self.timeSegments[currentSegmentID][-1]-self.timeSegments[currentSegmentID][0], self.timeDelayLowSegments[currentSegmentID], self.characteristicForceSegments[currentSegmentID], self.freqSegments[currentSegmentID], float(self.kSegments[currentSegmentID]), float(self.kSegmentsInterval[currentSegmentID]),float(self.TSegments[currentSegmentID]), float(self.TSegmentsInterval[currentSegmentID]),self.inputInitialValues[currentSegmentID],self.inputDifferenceFirstAndLastValues[currentSegmentID],self.outputInitialValues[currentSegmentID]], 15, rowCounter)

		for indexSegmentChosen in indexSegmentsChosen:
			axsDict['k_u0'].scatter(self.inputInitialValues[indexSegmentChosen], self.kSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['k_x10'].scatter(self.outputInitialValues[indexSegmentChosen], self.kSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['k_fInput'].scatter(self.freqSegments[indexSegmentChosen], self.kSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['k_force'].scatter(self.characteristicForceSegments[indexSegmentChosen], self.kSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['k_deltaU'].scatter(self.inputDifferenceFirstAndLastValues[indexSegmentChosen], self.kSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['T_u0'].scatter(self.inputInitialValues[indexSegmentChosen], self.TSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['T_x10'].scatter(self.outputInitialValues[indexSegmentChosen], self.TSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['T_fInput'].scatter(self.freqSegments[indexSegmentChosen], self.TSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['T_force'].scatter(self.characteristicForceSegments[indexSegmentChosen], self.TSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['T_deltaU'].scatter(self.inputDifferenceFirstAndLastValues[indexSegmentChosen], self.TSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			
			#Errors
			axsDict['k_delta'].scatter(self.kSegmentsInterval[indexSegmentChosen], self.kSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['T_delta'].scatter(self.TSegmentsInterval[indexSegmentChosen], self.TSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])

			#Time input delays
			axsDict['delta_u0'].scatter(self.inputInitialValues[indexSegmentChosen], self.timeDelayLowSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['delta_x10'].scatter(self.outputInitialValues[indexSegmentChosen], self.timeDelayLowSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['delta_fInput'].scatter(self.freqSegments[indexSegmentChosen], self.timeDelayLowSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['delta_force'].scatter(self.characteristicForceSegments[indexSegmentChosen], self.timeDelayLowSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['delta_deltaU'].scatter(self.inputDifferenceFirstAndLastValues[indexSegmentChosen], self.timeDelayLowSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			
			#Errors and time delay
			axsDict['delta_delta'].scatter(self.TSegmentsInterval[indexSegmentChosen], self.timeDelayLowSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][0], **plotSettings['scatter'])
			axsDict['delta_delta'].scatter(self.kSegmentsInterval[indexSegmentChosen], self.timeDelayLowSegments[indexSegmentChosen], marker = 'o', c = plotSettings['colors'][1], **plotSettings['scatter'])

		for key in axsDict.keys():
			axsDict[key].grid(which='both', **plotSettings['grid'])
			axsDict[key].tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			axsDict[key].minorticks_on()
		
		for ax in [axs[0,-1], axs[1,-1], axs[2,-1]]:
			doubl_y_ax = usualSettingsAX(ax, plotSettings)

		#Legends
		axsDict['delta_delta'] = plt.Line2D([],[], color=plotSettings['colors'][0], marker='o', linestyle='', label='T')
		axsDict['delta_delta'] = plt.Line2D([],[], color=plotSettings['colors'][1], marker='o', linestyle='', label='k')
		axsDict['delta_delta'].legend(handles = [handle_1, handle_2], **plotSettings['legend'])

		figure.savefig(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), 'influenceParameters.png'), dpi = plotSettings['figure_settings']['dpi'])

class ClassVariableDef(object):
	"""docstring for ClassVariableDef"""
	def __init__(self, name_in):
		self.name = name_in

	def get_attr(self, attr_string):
		
		return getattr(self, attr_string)

	def importDataWithTime(self, CMDoptionsDict):
		"""
		Method needed for "dynamicActuatorScript.py".
		Load variables that contain time in the second row
		"""
		fileName = os.path.join(CMDoptionsDict['flightTestInfo']['folderFTdata'], self.name+'.csv')

		file = open(fileName, 'r')
		lines = file.readlines()

		skipLines, data_proc, time_proc, n = 1, [], [], 0

		for line in lines[skipLines:]:

			cleanLine = cleanString(line)

			try:
				data_proc += [float(cleanLine.split('\t')[0])]
				time_proc += [round(float(cleanLine.split('\t')[1]), 3)]
			except ValueError as e:
				print ('Error line: '+cleanLine+' in line '+str(n))
				raise e

			n += 1

		self.data = data_proc
		self.time = time_proc

		file.close()

	def importData(self, CMDoptionsDict, typeImport, varClassesGetSegmentsDict):

		def dofImporting(name):
			
			if 'LNG' in name:
				return 'LNG'
			elif 'COL' in name:
				return 'COL'
			elif 'LAT' in name:
				return 'LAT'
			else:
				raise ValueError('ERROR: Variable is not linked to any degree of freedom')


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

		#Raw data is imported until here

		if typeImport == 'segment':

			timeSegments, dataSegments, timeSegments_delay, dataSegments_delay = [], [], [], []

			if CMDoptionsDict['flightTestInfo']['segment_calculationMode'].lower() == 'auto':

				timeSegmentsList = varClassesGetSegmentsDict['DIF_CNT_DST_'+dofImporting(self.name)].timeSegmentsLimits
			
			else:
				
				timeSegmentsList0 = CMDoptionsDict['flightTestInfo']['segment_'+dofImporting(self.name)].split(';')
				timeSegmentsList = []
				for t in timeSegmentsList0:
					timeSegmentsList += [[float(i) for i in t.split(',')]]
			
			for timeSegmentList in timeSegmentsList:
				indexStartTime = time_proc.index(timeSegmentList[0])
				indexEndTime = time_proc.index(timeSegmentList[1])
				timeSegments += [time_proc[indexStartTime:indexEndTime]]
				dataSegments += [data_proc[indexStartTime:indexEndTime]]

				#Considering time delay (need to consider point in the future for the identification)
				indexStartTime_delay = time_proc.index(round(timeSegmentList[0] + float(CMDoptionsDict['flightTestInfo']['timeDelay']), 3))
				indexEndTime_delay = time_proc.index(round(timeSegmentList[1] + float(CMDoptionsDict['flightTestInfo']['timeDelay']), 3))
				timeSegments_delay += [time_proc[indexStartTime_delay:indexEndTime_delay]]
				dataSegments_delay += [data_proc[indexStartTime_delay:indexEndTime_delay]]


			self.timeSegments = timeSegments
			self.dataSegments = dataSegments

			#Delay 
			self.timeSegments_delay = timeSegments_delay
			self.dataSegments_delay = dataSegments_delay
			self.timeDelay = float(CMDoptionsDict['flightTestInfo']['timeDelay'])

		elif typeImport == 'getSegment':

			# range to import 
			timeSegmentList = [float(t) for t in CMDoptionsDict['flightTestInfo']['rangeCalculationSegments_'+dofImporting(self.name)].split(',')]

			indexStartTime = time_proc.index(timeSegmentList[0])
			indexEndTime = time_proc.index(timeSegmentList[1]+1)

			timeChosen = time_proc[indexStartTime:indexEndTime]
			dataChosen = data_proc[indexStartTime:indexEndTime]

			timeSegmentsLimits, firstPointFlag, nPoint, nPreviousPoint = [], False, 0, 0
			freq = 500.0 #Hz
			delta_t = float(CMDoptionsDict['flightTestInfo']['segmentSelection_delta_t']) #seconds
			threashole = float(CMDoptionsDict['flightTestInfo']['segmentSelection_zeroThreashole'])
			delta_t_forward = float(CMDoptionsDict['flightTestInfo']['segmentSelection_delta_t_forward'])
			vel_forward = float(CMDoptionsDict['flightTestInfo']['segmentSelection_vel_forward'])
			pilotFreqThreadshole = float(CMDoptionsDict['flightTestInfo']['segmentSelection_pilotFreqThreadshole']) #Hz
			for data in dataChosen[:int(0.95*len(dataChosen))]:

				if abs(data) < threashole:

					if not firstPointFlag and abs(dataChosen[int(nPoint + delta_t_forward*freq)]) > vel_forward and ((nPoint-nPreviousPoint) > (delta_t*freq)):
						firstPoint = timeChosen[dataChosen.index(data)]
						firstPointFlag = True
					elif firstPointFlag:
						secondPoint = timeChosen[dataChosen.index(data)]
						if (secondPoint - firstPoint) > np.power(pilotFreqThreadshole, -1)/2:
							timeSegmentsLimits += [[firstPoint, secondPoint]]
						firstPointFlag = False
						nPreviousPoint = nPoint

				nPoint += 1

			self.timeSegmentsLimits = timeSegmentsLimits

		else:

			self.time = time_proc
			self.data = data_proc

		file.close()

	def convertToIncrement(self):

		newDataSegments, initialValues, differenceFirstAndLastValues = [], [], []
		
		for dataSegment in self.dataSegments:

			initialValue = dataSegment[0]

			differenceFirstAndLastValue = dataSegment[-1] - dataSegment[0]

			updatedDataSegment = [t - initialValue for t in dataSegment]

			newDataSegments += [updatedDataSegment]
			initialValues += [initialValue]
			differenceFirstAndLastValues += [differenceFirstAndLastValue]

		self.dataIncrementSegments = newDataSegments
		self.dataInitialValues = initialValues
		self.differenceFirstAndLastValues = differenceFirstAndLastValues

		#With time delay, same code as above
		newDataSegments, initialValues, differenceFirstAndLastValues = [], [], []
		
		for dataSegment in self.dataSegments_delay:

			initialValue = dataSegment[0]

			differenceFirstAndLastValue = dataSegment[-1] - dataSegment[0]

			updatedDataSegment = [t - initialValue for t in dataSegment]

			newDataSegments += [updatedDataSegment]
			initialValues += [initialValue]
			differenceFirstAndLastValues += [differenceFirstAndLastValue]

		self.dataIncrementSegments_delay = newDataSegments
		self.dataInitialValues_delay = initialValues
		self.differenceFirstAndLastValues_delay = differenceFirstAndLastValues

	def get_picks_and_travel(self, CMDoptionsDict):
		"""
		Method needed for "dynamicActuatorScript.py".
		This function creates two new fields for the class which contains picks max and minimum and the their occurrence time

		-> What to improve?
		* The rounding in the import is not so nice, reduce precision
		* To be able to work when the first pick is a maximum or a minimum
		"""
		def checkPick(index, vector_of_index, all_range):

			value = all_range[index]
			vector = []
			for i in vector_of_index:
				vector += [all_range[index+i], all_range[index-i]]

			boolsMax = ()
			for v in vector:
				boolsMax += (value >= v, )

			boolsMin = ()
			for v in vector:
				boolsMin += (value <= v, )

			return boolsMax, boolsMin
		
		# Input parameters
		freqPicks = float(CMDoptionsDict['flightTestInfo']['freqPicks']) #seconds-1
		startTime = float(CMDoptionsDict['flightTestInfo']['startTimeSlope']) 
		endTime = float(CMDoptionsDict['flightTestInfo']['endTimeSlope']) 
		data_xStep = self.time[1] - self.time[0] #Seconds
		numberPointsCycle = int(1 / (freqPicks * data_xStep))
		time_fn = self.time
		data_fn = self.data
		indexStartTime = time_fn.index([t for t in time_fn if abs(startTime-t)<0.02][0])
		indexEndTime = time_fn.index([t for t in time_fn if abs(endTime-t)<0.02][0])

		#Automatic search
		if 'sg__CopyYCNT_DST_BST_L' in self.name:
			numberOfPointsSearch = 80
		elif 'sg__CopyYCNT_DST_L' in self.name:
			numberOfPointsSearch = 20
		CMDrowsCounter = printRowTable('headerPicks', 12, 1, 'headerPicks')
		maxs, mins, index, skipN = [], [], indexStartTime, 0.0
		list_max_pairs, list_min_pairs = [], []
		for point in data_fn[indexStartTime:indexEndTime]:
			if skipN == 0.0:
				boolsCheckMax, boolsCheckMin = checkPick(index, range(1 ,numberOfPointsSearch), data_fn) #[1, 2, 5, 7, 10, 12, 15, 20, 30, 40, 50]
				if all(boolsCheckMax):
					list_max_pairs += [[time_fn[index], point]]
					skipN = int(0.1 * numberPointsCycle)
					CMDrowsCounter = printRowTable([len(list_max_pairs)+len(list_min_pairs), 'max', list_max_pairs[-1][0], list_max_pairs[-1][1]], 12, CMDrowsCounter, 'headerPicks')
				elif all(boolsCheckMin):
					list_min_pairs += [[time_fn[index], point]]
					skipN = int(0.1 * numberPointsCycle)
					CMDrowsCounter = printRowTable([len(list_max_pairs)+len(list_min_pairs), 'min', list_min_pairs[-1][0], list_min_pairs[-1][1]], 12, CMDrowsCounter, 'headerPicks')

			index += 1

			# Skip after pick found
			if skipN != 0.0:
				skipN -= 1.0

		self.list_max_pairs = list_max_pairs
		self.list_min_pairs = list_min_pairs

		# Get travel
		i = 0
		travel, freq_from_picks = [], []
		times_max = [t[0] for t in list_max_pairs]
		times_min = [t[0] for t in list_min_pairs]
		maxs = [t[1] for t in list_max_pairs]
		mins = [t[1] for t in list_min_pairs]

		if times_max[0] > times_min[0]: #If first point is a maximum
			firstPickFlag = False
		else:
			firstPickFlag = True
		
		CMDrowsCounter = printRowTable('headerValuesBetweenPicks', 23, 1, 'headerValuesBetweenPicks')
		for max_i, min_i in zip(maxs, mins):
			if not i == 0:
				travel += [[(times_max[i] + times_min[i-1])/2, abs(max_i-mins[i-1])]]

				if firstPickFlag:
					freq_from_picks += [[(times_max[i] + times_max[i-1])/2, 1/abs(times_max[i]-times_max[i-1])]] #Measure instant freq from period between consecutive peaks
					freq_from_picks += [[(times_min[i] + times_min[i-1])/2, 1/abs(times_min[i]-times_min[i-1])]] #Measure instant freq from period between consecutive peaks
				else:
					freq_from_picks += [[(times_min[i] + times_min[i-1])/2, 1/abs(times_min[i]-times_min[i-1])]] #Measure instant freq from period between consecutive peaks
					freq_from_picks += [[(times_max[i] + times_max[i-1])/2, 1/abs(times_max[i]-times_max[i-1])]] #Measure instant freq from period between consecutive peaks
				CMDrowsCounter = printRowTable([travel[-1][0], travel[-1][1], freq_from_picks[-1][1]], 23, CMDrowsCounter, 'headerValuesBetweenPicks')

			travel += [[(times_max[i] + times_min[i])/2, abs(max_i-min_i)]] #Measure instant freq as pick to pick
			# freq += [[(times_max[i] + times_min[i])/2, 1/(abs(times_max[i]-times_min[i])*2)]] #Measure instant freq as pick to pick
			# CMDrowsCounter = printRowTable([travel[-1][0], travel[-1][1], freq_from_picks[-1][1]], 23, CMDrowsCounter, 'headerValuesBetweenPicks')
			CMDrowsCounter = printRowTable([travel[-1][0], travel[-1][1]], 23, CMDrowsCounter, 'headerValuesBetweenPicks')

			i += 1

		if len(maxs) != len(mins): #Last point, if the series do not have the same length. They can only differ in length by one unit
			travel += [[(times_max[-1] + times_min[-1])/2, abs(maxs[-1]-mins[-1])]]
			if firstPickFlag:
				freq_from_picks += [[(times_max[-1] + times_max[-2])/2, 1/abs(times_max[-1]-times_max[-2])]]
				# freq_from_picks += [[(times_min[-1] + times_min[-2])/2, 1/abs(times_min[-1]-times_min[-2])]]
			else:
				freq_from_picks += [[(times_min[-1] + times_min[-2])/2, 1/abs(times_min[-1]-times_min[-2])]]
				# freq_from_picks += [[(times_max[-1] + times_max[-2])/2, 1/abs(times_max[-1]-times_max[-2])]]

		self.travel = travel
		self.freq_from_picks = freq_from_picks

		#Interpolate freqs for travel
		interpol_f = interpolate.interp1d([t[0] for t in freq_from_picks], [t[1] for t in freq_from_picks], kind = 'linear', bounds_error = False, fill_value = 'extrapolate', assume_sorted = True)
		freq_travel = interpol_f([t[0] for t in travel])

		self.freq_from_travel = [[t[0], f] for t,f in zip(travel, freq_travel)]

		#Output
		if CMDoptionsDict['outputFlag']:
			file = open('resultsCavitationInvestigation_'+self.name+'.csv', 'w')
			i = 0
			file.write(','.join(['time','travel','freq']) + '\n')
			for travelPair in self.travel:
				file.write(','.join(map(str, [travelPair[0],travelPair[1],self.freq_from_travel[i][1]])) + '\n')
				i+=1

			file.close()

def FRF(input_in, output_in, settingsDict_FRF, plotSettings, CMDoptionsDict):
	"""
	Calculate the frequency response of the actuator

	-> input_in: 2 column numpy array, [data, time]
	-> output_in: 2 column numpy array, [data, time]
	"""

	inputFreqsMinMax = [float(p) for p in CMDoptionsDict['flightTestInfo']['inputFreqsMinMax'].split(',')]

	N = input_in.shape[0]

	#Input and output variables
	x = input_in[:N,0] - np.mean(input_in[:N,0])
	y = output_in[:N,0] - np.mean(output_in[:N,0])

	# Time vector
	time = input_in[:N,1]
	# Check the same time vector is used from each 
	assert input_in[1,1] == output_in[1,1], 'Error: Mismatch between time vectors for input and output'

	# Correlation plots

	if settingsDict_FRF['correlationPlotsFlag']:

		R_xx = np.zeros([N-1, 1])
		R_yy = np.zeros([N-1, 1])
		R_xy = np.zeros([N-1, 1])
		R_yx = np.zeros([N-1, 1])
		lags = np.zeros([N-1, 1])

		for n_tau in range(N-1):
			for n in range(N-1-abs(n_tau)):
				R_xx[n_tau] += (x[n] * x[n+n_tau])/(N - n_tau)
				R_yy[n_tau] += (y[n] * y[n+n_tau])/(N - n_tau)
				R_xy[n_tau] += (x[n] * y[n+n_tau])/(N - n_tau)
				R_yx[n_tau] += (y[n] * x[n+n_tau])/(N - n_tau)

			lags[n_tau] = [time[n_tau]-time[0]]

		figure, axs = plt.subplots(3, 1, sharex='col')
		figure.set_size_inches(14, 10, forward=True)
		figure.suptitle('Correlation functions', **plotSettings['figure_title'])

		axs[0].plot(np.concatenate((np.flip(lags[1:],0)*-1, lags)), np.concatenate((np.flip(R_xx[1:],0), R_xx)), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'R_xx', **plotSettings['line'])
		axs[1].plot(np.concatenate((np.flip(lags[1:],0)*-1, lags)), np.concatenate((np.flip(R_yy[1:],0), R_yy)), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'R_yy', **plotSettings['line'])
		axs[2].plot(np.concatenate((np.flip(lags[1:],0)*-1, lags)), np.concatenate((np.flip(R_xy[1:],0), R_xy)), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'R_xy', **plotSettings['line'])

		axs[0].set_ylabel('R_xx', **plotSettings['axes_y'])
		axs[1].set_ylabel('R_yy', **plotSettings['axes_y'])
		axs[2].set_ylabel('R_xy', **plotSettings['axes_y'])

		axs[-1].set_xlabel('Lags [s]', **plotSettings['axes_x'])

		for ax in axs:
			usualSettingsAX(ax, plotSettings)

	# #######################
	# Overlapped windowing
	T_rec = time[-1]
	T_s = time[1]-time[0]
	f_s = 1/T_s
	output_delay = 0.6 #????

	x_frac = settingsDict_FRF['x_frac']
	K = settingsDict_FRF['K']

	# Window length
	T_win = T_rec / ( ((K-1)*(1 - x_frac)) + 1)

	#Number of samples in each window
	N_win = int( N / ( ((K-1)*(1 - x_frac)) + 1) )

	# Power spectral density
	f_PSD_x, Pxx_den_PSD_x = signal.welch(x, fs=f_s, window=settingsDict_FRF['window'], nperseg=N_win, noverlap=N_win/2, scaling= 'spectrum')
	f_PSD_y, Pxx_den_PSD_y = signal.welch(y, fs=f_s, window=settingsDict_FRF['window'], nperseg=N_win, noverlap=N_win/2, scaling= 'spectrum')
	

	if settingsDict_FRF['additionalPlots']:
		figure, axs = plt.subplots(2, 1, sharex='col')
		figure.set_size_inches(14, 10, forward=True)
		axs[0].semilogy(f_PSD_x, np.sqrt(Pxx_den_PSD_x), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'x', **plotSettings['line'])
		axs[1].semilogy(f_PSD_y, np.sqrt(Pxx_den_PSD_y), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'y', **plotSettings['line'])

		axs[0].set_ylabel('Linear spectrum [mm RMS]', **plotSettings['axes_y'])
		axs[1].set_ylabel('Linear spectrum [% RMS]', **plotSettings['axes_y'])
		
		axs[-1].set_xlabel('Frequency [Hz]', **plotSettings['axes_x'])

		for ax in axs:
			usualSettingsAX(ax, plotSettings)

	# Subdivision in segments
	x_int, y_int, t_int = K*[None], K*[None], K*[None]
	
	for k in range(1,K-1):
		lower_index = int((1-x_frac)*k*(N_win-1))
		upper_index = int(((1-x_frac)*k*N_win) + N_win)
		
		x_int[k] = x[lower_index:upper_index]
		y_int[k] = y[lower_index:upper_index]
		t_int[k] = time[lower_index:upper_index]

	x_int[0] = x[:N_win]
	y_int[0] = y[:N_win]
	t_int[0] = time[:N_win]

	x_int[K-1] = x[-N_win:]
	y_int[K-1] = y[-N_win:]
	t_int[K-1] = time[-N_win:]

	# Windowing
	x_window, y_window = K*[None], K*[None]

	windowFunctionsDict = {'bartlett' : np.bartlett, 'blackman' : np.blackman, 'hamming' : np.hamming, 'hanning' : np.hanning}

	for k in range(K):

		x_window[k] = x_int[k] * windowFunctionsDict[settingsDict_FRF['window']](x_int[k].shape[0])
		y_window[k] = y_int[k] * windowFunctionsDict[settingsDict_FRF['window']](y_int[k].shape[0])


	if settingsDict_FRF['additionalPlots']:
		figure, axs = plt.subplots(4, 1, sharex='col')
		figure.set_size_inches(14, 10, forward=True)
		figure.suptitle('Correlation functions', **plotSettings['figure_title'])

		axs[0].plot(time, x, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'x', **plotSettings['line'])
		for seg_id in range(K):
			axs[1].plot(t_int[seg_id], x_window[seg_id], linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'x_window', **plotSettings['line'])
		
		axs[2].plot(time, y, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'y', **plotSettings['line'])
		for seg_id in range(K):
			axs[3].plot(t_int[seg_id], y_window[seg_id], linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'y_window', **plotSettings['line'])

		axs[0].set_ylabel('x', **plotSettings['axes_y'])
		axs[1].set_ylabel('x_window', **plotSettings['axes_y'])
		axs[2].set_ylabel('y', **plotSettings['axes_y'])
		axs[3].set_ylabel('y_window', **plotSettings['axes_y'])
		
		axs[-1].set_xlabel('Time [s]', **plotSettings['axes_x'])

		for ax in axs:
			usualSettingsAX(ax, plotSettings)

	# Discrete Fourier transforms
	X1, X, Y1, Y, freq = K*[None], K*[None], K*[None], K*[None], K*[None]

	for k in range(K):

		X1[k] = np.fft.fft(x_window[k], n = N)
		X[k] = X1[k][0:int((N+1)/2-1)]
		Y1[k] = np.fft.fft(y_window[k], n = N)
		Y[k] = Y1[k][0:int((N+1)/2-1)]

		# temp = np.fft.fftfreq(x_window[k].shape[-1], d = T_s)
		# freq[k] = temp[0:int((N+1)/2-1)]

	# Frequency
	f = [p * (f_s/N) for p in range(0, int((N-1)/2))]

	# Rough estimate
	G_xx_rough, G_yy_rough, G_xy_rough = K*[None], K*[None], K*[None]

	for k in range(K):

		G_xx_rough[k] = [o*o*(2/T_win) for o in X[k]]
		G_yy_rough[k] = [o*o*(2/T_win) for o in Y[k]]
		G_xy_rough[k] = [o*p*(2/T_win) for o,p in zip(X[k], Y[k])]

	G_xx, G_yy, G_xy = min([len(u) for u in G_xx_rough])*[None], min([len(u) for u in G_xx_rough])*[None], min([len(u) for u in G_xx_rough])*[None]
	for p in range(min([len(u) for u in G_xx_rough])):
		temp_a, temp_b, temp_c = [], [], []
		for k in range(K):
			# print('{}, {}'.format(p, k))
			temp_a += [G_xx_rough[k][p]]
			temp_b += [G_yy_rough[k][p]]
			temp_c += [G_xy_rough[k][p]]
		# pdb.set_trace()
		G_xx[p] = np.mean(temp_a)
		G_yy[p] = np.mean(temp_b)
		G_xy[p] = np.mean(temp_c)

	# Estimate the FRF H
	H = [m/n for m,n in zip(G_xy,G_xx)]

	mod = [20*np.log10(cmath.polar(o)[0]) for o in H]
	phi = [(180/cmath.pi)*cmath.polar(o)[1] for o in H]

	if settingsDict_FRF['additionalPlots']:
		figure, axs = plt.subplots(2, 1, sharex='col')
		figure.set_size_inches(14, 10, forward=True)
		axs[0].semilogx(f, mod, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'x', **plotSettings['line'])
		axs[1].semilogx(f, phi, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'x', **plotSettings['line'])

		for lim in inputFreqsMinMax:
			axs[0].semilogx(2*[lim], [max(mod), min(mod)], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])
			axs[1].semilogx(2*[lim], [max(phi), min(phi)], linestyle = '--', marker = '', c = plotSettings['colors'][4], **plotSettings['line'])

		axs[0].set_ylabel('|H| [dB]', **plotSettings['axes_y'])
		axs[1].set_ylabel('$\\varphi$ [deg]', **plotSettings['axes_y'])
		
		axs[-1].set_xlabel('Frequency [Hz]', **plotSettings['axes_x'])

		for ax in axs:
			usualSettingsAX(ax, plotSettings)

	outputDict = {'f':f, 'mod':mod, 'phi':phi}

	return outputDict

def importFTIdefFile(fileName_in, CMDoptionsDict):
	"""
	This function is used by displayFightTest script
	"""

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

	for segmentID in range(len(varClassesDict[list(varClassesDict.keys())[0]].get_attr('timeSegments'))):

		figure, axesList = plt.subplots(len(list(varClassesDict.keys())), 1, sharex='col')
		figure.set_size_inches(12, 6, forward=True)

		for ax, var in zip(axesList, varClassesDict.keys()):

			if not 'DIF' in var:
				ax.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], varClassesDict[var].get_attr('dataIncrementSegments')[segmentID], linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varClassesDict[var].get_attr('name'), **plotSettings['line'])		
			else:
				ax.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], varClassesDict[var].get_attr('dataSegments')[segmentID], linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varClassesDict[var].get_attr('name'), **plotSettings['line'])		

			if ax == axesList[-1]:
				ax.set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

			ax.set_ylabel(CMDoptionsDict['variablesInfo'][varClassesDict[var].get_attr('name')]['units'], **plotSettings['axes_y'])

			ax.set_title(varClassesDict[var].get_attr('name'), **plotSettings['axes_y'])

			ax.grid(which='both', **plotSettings['grid'])
			ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
			ax.minorticks_on()

			figure.suptitle(str(segmentID+1)+' sub-set, '+str(varClassesDict[var].get_attr('timeSegments')[segmentID][0])+'s to '+str(varClassesDict[var].get_attr('timeSegments')[segmentID][-1])+'s', **plotSettings['figure_title'])

			#Double y-axis
			axdouble_in_y = ax.twinx()
			axdouble_in_y.minorticks_on()
			if not varClassesDict[var].get_attr('name') == 'CNT_DST_BST_LNG':
				axdouble_in_y.set_ylim(ax.get_ylim())
			else:
				diffData0 = np.diff(varClassesDict[var].get_attr('dataIncrementSegments')[segmentID])
				diffData = [diffData0.tolist()[0]]+diffData0.tolist() #Correct reduction in the dimension
				axdouble_in_y.plot( varClassesDict[var].get_attr('timeSegments')[segmentID], diffData, linestyle = '-', marker = '', c = plotSettings['colors'][1], label = varClassesDict[var].get_attr('name')+'_diff', **plotSettings['line'])
				ax.legend(**plotSettings['legend'])
				axdouble_in_y.legend(**plotSettings['legend'])

def cleanString(stringIn):
	
	if stringIn[-1:] in ('\t', '\n'):

		return cleanString(stringIn[:-1])

	else:

		return stringIn

def usualSettingsAX(ax, plotSettings):
	
	ax.grid(which='both', **plotSettings['grid'])
	ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
	ax.minorticks_on()
	#Double y-axis 
	axdouble_in_y = ax.twinx()
	axdouble_in_y.minorticks_on()
	axdouble_in_y.set_ylim(ax.get_ylim())

	return axdouble_in_y

def calculateSelfWeight(v):

	def f_back(v, i):

		sum = 0
		for j in range(i):

			sum += abs(v[i]-v[j])

		return sum

	def f_forward(v, i):

		sum = 0
		for j in range(i+1,len(v)):

			sum += abs(v[i]-v[j])

		return sum

	N = len(v)

	weightVector = []

	for i in range(N):

		weightVector += [f_back(v, i)+f_forward(v, i)]

	return weightVector

def printRowTable(listToPrint, widthCellUnits, rowCounter, headerKey):

	headersDict = {'headerSID' : ['Segment', 't1 (s)', 't2 (s)', 'delta_t (s)', 'tau_input (s)','Mean F (N)', 'Pilot f. (Hz)', 'k', '+- delta_k','T (s)', '+- delta_T','u (t=0)','delta_u','x1 (t=0)'], 
					'headerPicks' : ['Pick number', 'Type', 'time', 'value'], 
					'headerValuesBetweenPicks' : ['Time stamp', 'Travel pick to pick', 'Instant frequency (Hz)']}

	if isinstance(listToPrint, str):
		listToPrint = headersDict[listToPrint] 

	for item in listToPrint:
		if isinstance(item, float) or isinstance(item, int):
			item = str(round(item, 3))
		print(item.rjust(widthCellUnits), end="")

	print('\n')

	if rowCounter%10 == 0:
		for item in headersDict[headerKey]:
			print(item.rjust(widthCellUnits), end="")
		print('\n')

	return rowCounter + 1

def calculateBarWidth(xValues, gapFactor):
	spaces = [abs(xValues[i+1]-xValues[i]) for i in range(len(xValues)-2)]
	return min(spaces) - (gapFactor*np.mean(xValues))

def reviewInputParameters(CMDoptionsDict):

	print('\n'+'* Input parameters:')
	
	for key, value in CMDoptionsDict['flightTestInfo'].items():

		print(key, ': ',value)

def writeIdentificationResults():
	
	file = open(os.path.join(os.path.join(CMDoptionsDict['flightTestInfo']['folderResults'], self.name+'\\'), 'identificationResults.csv'), 'a')

	for frameValue in frameValueList:

		file.write(str(frame_i) + '\n')

		file.write(str(frameValue) + '\n')

		frame_i += 1

	file.close()

def plot_fti_measurements_cavitation(inputVar, var_pistonDist, var_press, var_vel, varClassesDict, plotSettings):

	figure, axs = plt.subplots(4, 2, sharex='all')
	figure.set_size_inches(14, 10, forward=True)
	########################################

	def plotIndividual( varToPlot, varClassesDict, plotSettings, plotCount, plotColumnCount):

		var_vel = 'dif__'+varToPlot.split('__')[1]

		if plotColumnCount == 0:
			plotLeftFlag = True
		else:
			plotLeftFlag = False

		fs = 1/(varClassesDict[varToPlot].time[1] - varClassesDict[varToPlot].time[0])

		ax = axs[plotCount, plotColumnCount]
		if 'CNT_DST_BST_L' in varToPlot:
			ax.set_title('Actuator piston displ. [mm]', **plotSettings['ax_title'])
		elif 'CNT_DST_L' in varToPlot:
			ax.set_title('Pilot input [%]', **plotSettings['ax_title'])


		ax.plot(varClassesDict[varToPlot].time, varClassesDict[varToPlot].data, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varToPlot, **plotSettings['line'])
		ax.plot([t[0] for t in varClassesDict[varToPlot].list_max_pairs], [t[1] for t in varClassesDict[varToPlot].list_max_pairs], linestyle = '-.', marker = 'o', c = plotSettings['colors'][1], label = 'Max', **plotSettings['line'])
		ax.plot([t[0] for t in varClassesDict[varToPlot].list_min_pairs], [t[1] for t in varClassesDict[varToPlot].list_min_pairs], linestyle = '-.', marker = 'o', c = plotSettings['colors'][1], label = 'Min', **plotSettings['line'])
		if plotLeftFlag:
			ax.set_ylabel('Displ. [mm],[%]', **plotSettings['axes_y'])

		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()
		#Double y-axis
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.plot([t[0] for t in varClassesDict[varToPlot].freq_from_picks], [t[1] for t in varClassesDict[varToPlot].freq_from_picks], linestyle = '-', marker = 'o', c = plotSettings['colors'][2], label = 'Freq.', **plotSettings['line'])
		if not plotLeftFlag:
			axdouble_in_y.set_ylabel('Instant freq. [Hz]', **plotSettings['axes_x'])
		handles_doubleAx_y = axdouble_in_y.get_legend_handles_labels()[0]
		handles = ax.get_legend_handles_labels()[0]
		ax.legend(handles = handles_doubleAx_y, **plotSettings['legend'])


		########################################
		plotCount+=1
		ax = axs[plotCount, plotColumnCount]
		ax.plot(varClassesDict[varToPlot].time, varClassesDict[varToPlot].data, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = varToPlot, **plotSettings['line'])
		ax.plot([t[0] for t in varClassesDict[varToPlot].list_max_pairs], [t[1] for t in varClassesDict[varToPlot].list_max_pairs], linestyle = '-.', marker = 'o', c = plotSettings['colors'][1], label = 'Max', **plotSettings['line'])
		ax.plot([t[0] for t in varClassesDict[varToPlot].list_min_pairs], [t[1] for t in varClassesDict[varToPlot].list_min_pairs], linestyle = '-.', marker = 'o', c = plotSettings['colors'][1], label = 'Min', **plotSettings['line'])
		if plotLeftFlag:
			ax.set_ylabel('Displ. [mm],[%]', **plotSettings['axes_y'])

		ax.grid(which='both', **plotSettings['grid'])
		ax.tick_params(axis='both', which = 'both', **plotSettings['axesTicks'])
		ax.minorticks_on()
		#Double y-axis 
		axdouble_in_y = ax.twinx()
		axdouble_in_y.minorticks_on()
		axdouble_in_y.plot([t[0] for t in varClassesDict[varToPlot].travel], [t[1] for t in varClassesDict[varToPlot].travel], linestyle = '-', marker = 'o', c = plotSettings['colors'][2], label = 'Travel', **plotSettings['line'])
		if not plotLeftFlag:
			axdouble_in_y.set_ylabel('Instant amplitude [mm],[%]', **plotSettings['axes_x'])
		handles_doubleAx_y = axdouble_in_y.get_legend_handles_labels()[0]
		handles = ax.get_legend_handles_labels()[0]
		ax.legend(handles = handles_doubleAx_y, **plotSettings['legend'])

		########################################
		plotCount+=1
		ax = axs[plotCount, plotColumnCount]
		ax.plot(varClassesDict[var_vel].time, varClassesDict[var_vel].data, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = var_vel, **plotSettings['line'])
		if plotLeftFlag:
			ax.set_ylabel('Vel. [mm/s],[%/s]', **plotSettings['axes_y'])

		usualSettingsAX(ax, plotSettings)


	###################################

	column_n = 0

	if 'LNG' in inputVar:
		figure.suptitle('LNG', **plotSettings['figure_title'])
	elif 'LAT' in inputVar:
		figure.suptitle('LAT', **plotSettings['figure_title'])


	for varToPlot in (inputVar, var_pistonDist):

		plotIndividual( varToPlot, varClassesDict, plotSettings, 0, column_n)

		ax = axs[-1, column_n]
		ax.plot(varClassesDict[var_press].time, varClassesDict[var_press].data, linestyle = '-', marker = '', c = plotSettings['colors'][0], label = var_press, **plotSettings['line'])
		if column_n == 0:
			ax.set_ylabel('Hyd. press. [bar]', **plotSettings['axes_y'])
		ax.set_xlabel('Time [s]', **plotSettings['axes_x'])
		ax.legend(**plotSettings['legend'])
		usualSettingsAX(ax, plotSettings)

		column_n += 1