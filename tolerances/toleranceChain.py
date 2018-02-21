# Main
import numpy as np
import math
import pdb
import matplotlib.pyplot as plt

from configClassModule import *

#Load plotting options
plotSettings = plottingOptionsFn()

####################
flightActivationAngle_rad = 18 * (np.pi / 180)
####################
#Tolerance chain option 1
path_A_1 = {'obl' : [ 
			[0.925, -0.925], #1
			[0.1, -0.1], #2
			[0.1, -0.1] #3
			], 
			'cos' : [], 
			'sin' : [],
			'hor_flight' : [],
			'ver_flight' : [],
			'hor_flight_const' : [],
			'ver_flight_const' : []
			}

path_B_1 = {'obl' : [
			[0.5, -0.5] #3
			], 
			'cos' : [], 
			'sin' : [] 
			}
#Angular displacement
dist_ground_1 = (164.2488 + 7) * (np.pi/180) #distance in mm * 1deg
dist_flight_1 = 0.0 #distance in mm * 1deg
angleTouch_1 = 90

#############
#Tolerance chain option 2
angleTouch_2 = 14.84 #deg
path_A_2 = {'obl' : [ 
			[0.2, -0.2], #3
			[0.2, -0.2] #4
			], 
			'cos' : [
			[0.25, -0.25], #1
			[0.575, -0.575] #2
			], 
			'sin' : [
			[0.0, -0.05], #9
			[0.01, -0.03], #10
			[0.1, -0.1] #8
			],
			'hor_flight' : [
			[0.575, -0.575] #2
			],
			'ver_flight' : [
			[0.01, -0.03], #10
			[0.1, -0.1] #8
			],
			'hor_flight_const' : [[0.25, -0.25]], #1
			'ver_flight_const' : [[0.0, -0.05]], #9
			}

path_B_2 = {'obl' : [ 
			[0.1, -0.1], #6
			[0.2, -0.2] #7
			], 
			'cos' : [
			[0.5, -0.5] #5
			], 
			'sin' : [
			[0.2, -0.2] #11
			]
			}

#Angular displacement
dist_ground_2 = 136.1304 * (np.pi/180) #distance in mm * 1deg
dist_flight_2 = 117.3881 * (np.pi/180) #distance in mm * 1deg

#####################
#Tolerance chain option 3
angleTouch_3 = 9.393 #deg

path_A_3 = {'obl' : [ 
			[0.2, -0.2], #3
			[0.2, -0.2] #4
			], 
			'cos' : [
			[0.625, -0.625], #1
			[0.1, -0.1] #2
			], 
			'sin' : [
			[0.1, -0.1], #8
			[0.05, -0.05] #9
			],
			'hor_flight' : [
			[0.625, -0.625], #1
			[0.1, -0.1] #2
			], 
			'ver_flight' : [
			[0.1, -0.1], #8
			[0.05, -0.05] #9
			],
			'hor_flight_const' : [],
			'ver_flight_const' : []
			}

path_B_3 = {'obl' : [ 
			[0.2, -0.2] #7
			], 
			'cos' : [
			[0.05, -0.05] #5
			], 
			'sin' : [
			[0.1, -0.1] #6
			]
			}

#Angular displacement
dist_ground_3 = 27.6945 * (np.pi/180) #distance in mm * 1deg
dist_flight_3 = 35.67 * (np.pi/180) #distance in mm * 1deg

#################
##### ASSIGNMENT

config1 = configClass(0, path_A_1, path_B_1, dist_ground_1, dist_flight_1, angleTouch_1)
config2 = configClass(1, path_A_2, path_B_2, dist_ground_2, dist_flight_2, angleTouch_2)
config3 = configClass(2, path_A_3, path_B_3, dist_ground_3, dist_flight_3, angleTouch_3)

configs = [config1, config2, config3]

for conf in configs:
	conf.computePath(conf.get_AngleTouchInitial(), flightActivationAngle_rad)
	conf.computeToleranceUncertainty(printFlag = True)

#Different angles
setOfAngles = np.linspace(0, 90, 100, endpoint=True)

result = [[], []]

for angle in setOfAngles:

	for conf in configs[1:]:

		conf.initializePaths()
		conf.computePath(angle, flightActivationAngle_rad)
		conf.computeToleranceUncertainty(printFlag = False)

		result[conf.get_ID()-1] += [[conf.get_AngleUncertaintyGround(), conf.get_AngleUncertaintyFlight()],]

figure, ax = plt.subplots(1, 1)
ax.grid(which='both', **plotSettings['grid'])
figure.set_size_inches(10, 6, forward=True)
ax.tick_params(axis='both', **plotSettings['axesTicks'])

ax.set_xlabel('$\\alpha_{\mathrm{contact}} \quad [deg]$', **plotSettings['axes_x'])
ax.set_ylabel('$ \\beta_{\mathrm{range}} \quad [\pm deg]$', **plotSettings['axes_y'])
# ax.plot(angles,  [i[0] for i in result[0]], label='x/L='+str(round(x/maxXforModel,2)), **plotSettings['line'])

ax.plot(setOfAngles , [i[0] for i in result[0]], linestyle = '-', c = plotSettings['colors'][0], label='opt 1 / ground', **plotSettings['line'])
ax.plot(setOfAngles , [i[1] for i in result[0]], linestyle = '-.', c = plotSettings['colors'][0], label='opt 1 / flight', **plotSettings['line'])
ax.plot(setOfAngles , [i[0] for i in result[1]], linestyle = '-', c = plotSettings['colors'][1], label='opt 2 / ground', **plotSettings['line'])
ax.plot(setOfAngles , [i[1] for i in result[1]], linestyle = '-.', c = plotSettings['colors'][1], label='opt 2 / flight', **plotSettings['line'])

ax.legend(**plotSettings['legend'])

plt.show(block = True)