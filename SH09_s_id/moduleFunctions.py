import os
import sys
import numpy as np
import matplotlib as mlt
mlt.rcParams.update({'figure.max_open_warning': 0})
import matplotlib.pyplot as plt
import scipy.stats as st
import scipy.linalg as lalg
import statistics as stat
from scipy import signal
import math
import copy
import getopt
import pdb #pdb.set_trace()

def importPlottingOptions():
	#### PLOTTING OPTIONS ####

	#Plotting options
	axes_label_x  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 12, 'weight' : 'medium', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
	figure_text_title_properties = {'weight' : 'bold', 'size' : 14}
	ax_text_title_properties = {'weight' : 'regular', 'size' : 12}
	axes_ticks = {'labelsize' : 10}
	line = {'linewidth' : 1.5, 'markersize' : 2}
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

	short_opts = "f:" #"o:f:"
	long_opts = ["inputFile="] #["option=","fileName="]
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

				std_X = np.hstack((np.ones_like(regre1), std_regre1, -std_regre2))

				N = std_z.shape[0]
				n_p = std_X.shape[1] #Shall be equal to 2

				std_D = lalg.inv( np.matmul(std_X.T, std_X) )
				std_theta_est = np.matmul(np.matmul(std_D, std_X.T), std_z)

				# Get estimation not standard
				theta_est = np.array([[float(std_theta_est[0]) * np.sqrt(szz_z)], [float(std_theta_est[1]) * np.sqrt(szz_z/sjj_regre1)], [float(std_theta_est[2]) * np.sqrt(szz_z/sjj_regre2)]])				

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
		
		rowCounter = printRowTable('header1', 15, 1)

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
		rowCounter = printRowTable('header1', 15, 1)
		
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
		rowCounter = printRowTable('header1', 15, 1)
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
		rowCounter = printRowTable('header1', 15, 1)

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

def printRowTable(listToPrint, widthCellUnits, rowCounter):

	header1 = ['Segment', 't1 (s)', 't2 (s)', 'delta_t (s)', 'tau_input (s)','Mean F (N)', 'Pilot f. (Hz)', 'k', '+- delta_k','T (s)', '+- delta_T','u (t=0)','delta_u','x1 (t=0)']
	
	if isinstance(listToPrint, str):
		if listToPrint == 'header1':
			listToPrint = header1

	for item in listToPrint:
		if isinstance(item, float) or isinstance(item, int):
			item = str(round(item, 3))
		print(item.rjust(widthCellUnits), end="")

	print('\n')

	if rowCounter%10 == 0:
		for item in header1:
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