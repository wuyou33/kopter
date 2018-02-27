#Classes definition
import numpy as np
import math
import pdb # pdb.set_trace()

def plottingOptionsFn():

	#Plotting options
	axes_label_x  = {'size' : 10, 'weight' : 'bold', 'verticalalignment' : 'top', 'horizontalalignment' : 'center'} #'verticalalignment' : 'top'
	axes_label_y  = {'size' : 10, 'weight' : 'bold', 'verticalalignment' : 'bottom', 'horizontalalignment' : 'center'} #'verticalalignment' : 'bottom'
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

class configClass(object):
	"""docstring for config"""
	def __init__(self, id_num, path_A, path_B, dist_ground, dist_flight, angleTouch):
		# super(config, self).__init__()
		self.__id = id_num
		self.__path_A_uncomputed = path_A
		self.__path_B_uncomputed = path_B
		self.__dist_ground = dist_ground
		self.__dist_flight = dist_flight
		self.__angleTouch = angleTouch
		
		#Initialize paths
		self.initializePaths()

	def initializePaths(self):
			self.__path_A = []
			self.__path_B = []
			self.__path_A_flight = []

	def computePath(self, angleTouch, flightActivationAngle_rad):

		funcDict = {'obl' : 1, 'cos' : np.cos(angleTouch * (np.pi/180)), 'sin' : np.sin(angleTouch * (np.pi/180))}

		for key in funcDict.keys():
			if self.__path_A_uncomputed[key]: #if not empty
				for tols in self.__path_A_uncomputed[key]:
					self.__path_A += [[tol*funcDict[key] for tol in tols]]

			if self.__path_B_uncomputed[key]: #if not empty
				for tols in self.__path_B_uncomputed[key]:
					self.__path_B += [[tol*funcDict[key] for tol in tols]]

		funcDict_flight = {'obl' : 1, 'hor_flight' : (np.cos(flightActivationAngle_rad)*np.cos(angleTouch * (np.pi/180))) + (np.sin(flightActivationAngle_rad)*np.sin(angleTouch * (np.pi/180))), 
									'ver_flight' : (np.cos(flightActivationAngle_rad)*np.sin(angleTouch * (np.pi/180))) + (np.sin(flightActivationAngle_rad)*np.cos(angleTouch * (np.pi/180))),
									'hor_flight_const' : np.cos(angleTouch * (np.pi/180)), 'ver_flight_const' : np.sin(angleTouch * (np.pi/180))}

		for key in funcDict_flight.keys():
			if self.__path_A_uncomputed[key]: #if not empty
				for tols in self.__path_A_uncomputed[key]:
					self.__path_A_flight += [[tol*funcDict_flight[key] for tol in tols]]

	def computeToleranceUncertainty(self, printFlag):

		# ground
		a, b = 0, 0
		for tol in self.__path_A:
			a += tol[0]
			b += tol[1]

		for tol in self.__path_B:
			a -= tol[1]
			b -= tol[0]

		if printFlag:
			print('\n'+'\n'+'Configuration '+ str(self.__id) +' results' + '\n')
			print('Max deviation from nom in ground: ' + str(round(a, 4)))
			print('Min deviation from nom in ground: ' + str(round(b, 4)))

		self.__finalTol = a - b
		if printFlag:
			print('Oblique distance uncertainty due to tolerances in ground +-' + str(round(self.__finalTol, 4)) + 'mm')

		#flight
		a, b = 0, 0
		for tol in self.__path_A_flight:
			a += tol[0]
			b += tol[1]

		for tol in self.__path_B:
			a -= tol[1]
			b -= tol[0]

		if printFlag:
			print('Max deviation from nom in flight: ' + str(round(a, 4)))
			print('Min deviation from nom in flight: ' + str(round(b, 4)))

		self.__finalTol_flight = a - b
		if printFlag:
			print('Oblique distance uncertainty due to tolerances in flight +-' + str(round(self.__finalTol_flight, 4)) + 'mm')

		if self.__dist_ground != 0.0:
			self.__control_uncertainty_ground = self.__finalTol / self.__dist_ground
			if printFlag:
				print('Effective flap angle uncertainty in ground is +- ' + str(round(self.__control_uncertainty_ground, 4)) + 'deg')

		if self.__dist_flight != 0.0:
			self.__control_uncertainty_flight = self.__finalTol_flight / self.__dist_flight
			if printFlag:
				print('Effective flap angle uncertainty in flight is +- ' + str(round(self.__control_uncertainty_flight, 4)) + 'deg')

	def get_ID(self):
		return self.__id

	def get_AngleTouchInitial(self):
		return self.__angleTouch

	def get_AngleUncertaintyGround(self):
		return self.__control_uncertainty_ground

	def get_AngleUncertaintyFlight(self):
		return self.__control_uncertainty_flight
