#estimation of variability of damping

import numpy as np
import matplotlib.pyplot as plt
import scipy.linalg as lalg
import pdb # pdb.set_trace()

from configClassModule import *

#Load plotting options
plotSettings = plottingOptionsFn()


################### DATA ####################
z = np.matrix([[0.01],
				[-0.083],
				[-0.154],
				[-0.218],
				[-0.279],
				[-0.341],
				[-0.434],
				[-0.54],
				[-0.639]
				])

X = np.matrix([
				[0.0, -1.0],
				[-2.0, -1.0],
				[-4.0, -1.0],
				[-6.0, -1.0],
				[-8.0, -1.0],
				[-10.0, -1.0],
				[-12.0, -1.0],
				[-14.0, -1.0],
				[-16.0, -1.0]
				])

################# MODEL #######################
# theta = [ 1/Ku  d0/Ku]
# eq: d = u/Ku - d0/Ku

################ OPER #########################

N = z.shape[0]
n_p = X.shape[1]

D = lalg.inv( np.matmul(X.getT(), X) )
theta_est = np.matmul(np.matmul(D, X.getT()), z)

y_est = np.matmul(X, theta_est)

res = z - y_est

sig = np.sqrt(np.matmul(res.getT(), res) / (N-3))

print('Ku:' + str(1/theta_est[0]) + ', d0:' +str(theta_est[1]/theta_est[0]))

delta_y = np.zeros((N, 1))
max_y = np.zeros((N, 1))
min_y = np.zeros((N, 1))

for i in range(0,N):
	delta_y[i] = 2 * np.sqrt( np.matmul(np.matmul(np.matmul(np.matmul(sig, sig), X[i, :]), D), X[i, :].getT()) )

	max_y[i] = y_est[i] + delta_y[i] 
	min_y[i] = y_est[i] - delta_y[i] 

print('Maximum deviation: '+ str(round(max(delta_y).item(0), 4)) + 'mm')

#########
# Plotting
figure, ax = plt.subplots(1, 1)
ax.grid(which='both', **plotSettings['grid'])
figure.set_size_inches(10, 14, forward=True)
ax.tick_params(axis='both', **plotSettings['axesTicks'])

ax.set_xlabel('Displacement [mm]', **plotSettings['axes_x'])
ax.set_ylabel('Load [kN]', **plotSettings['axes_y'])
# ax.plot(angles,  [i[0] for i in result[0]], label='x/L='+str(round(x/maxXforModel,2)), **plotSettings['line'])

ax.plot(y_est[:, 0], X[:, 0], linestyle = '-',  c = plotSettings['colors'][2], label = 'linear', **plotSettings['line'])
ax.plot(max_y[:, 0], X[:, 0], linestyle = '-.',  c = plotSettings['colors'][1], label = 'upper lim', **plotSettings['line'])
ax.plot(min_y[:, 0], X[:, 0], linestyle = '-.',  c = plotSettings['colors'][4], label = 'lower lim', **plotSettings['line'])
ax.plot(z[:, 0], X[:, 0], marker = 'o', linestyle = '', c = plotSettings['colors'][0], label = 'measured data', **plotSettings['line'])

ax.legend(**plotSettings['legend'])

plt.show(block = True)

# pdb.set_trace()