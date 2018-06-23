import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib as mpl

import pdb #pdb.set_trace()

def cleanString(stringIn):
	
	if stringIn[-1:] in ('\t', '\n'):

		return cleanString(stringIn[:-1])

	else:

		return stringIn

class SqueezedNorm(mpl.colors.Normalize):
    def __init__(self, vmin=None, vmax=None, mid=0, s1=2, s2=2, clip=False):
        self.vmin = vmin # minimum value
        self.mid  = mid  # middle value
        self.vmax = vmax # maximum value
        self.s1=s1; self.s2=s2
        f = lambda x, zero,vmax,s: np.abs((x-zero)/(vmax-zero))**(1./s)*0.5
        self.g = lambda x, zero,vmin,vmax, s1,s2: f(x,zero,vmax,s1)*(x>=zero) - \
                                             f(x,zero,vmin,s2)*(x<zero)+0.5
        mpl.colors.Normalize.__init__(self, vmin, vmax, clip)

    def __call__(self, value, clip=None):
        r = self.g(value, self.mid,self.vmin,self.vmax, self.s1,self.s2)
        return np.ma.masked_array(r)

file = open('P:\\kopter\\bladesCode\\blade.csv', 'r')
lines = file.readlines()

skipLines, azimuths, valuesLines, zeniths = 4, [], [], []

for r in lines[1].split(';'):
	if cleanString(r) != '':
		zeniths += [float(cleanString(r))]

for line in lines[skipLines:]:

	line0 = line.split(';')

	valuesLine = [float(cleanString(t)) for t in line0[:-1]]

	azimuths += [float(cleanString(line0[-1]))]

	valuesLines += [valuesLine]

file.close()

values = np.vstack(valuesLines)

# #-- Generate Data -----------------------------------------
# # Using linspace so that the endpoint of 360 is included...
azimuthsRad = np.radians(azimuths)

x, y = [], []
for r_i in zeniths:

    for theta_i in azimuthsRad:

        x += [r_i * np.cos(theta_i)]

        y += [r_i * np.sin(theta_i)]


r, theta = np.meshgrid(zeniths, azimuthsRad)
x_mesh, y_mesh = np.meshgrid(x, y)

#-- Plot... ------------------------------------------------
fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
# plt.register_cmap(cmap='seismic')
# cmap_current = mpl.colors.Colormap('seismic', N=256)
# cont = ax.contourf(theta, r, values, cmap=cmap_current
# norm=SqueezedNorm(vmin=-800, vmax=600, mid=0, s1=1.7, s2=4)
# cont = ax.contourf(theta, r, values, cmap="Spectral_r", norm=norm, aspect="auto")
pene = plt.get_cmap('seismic')
cont = ax.contourf(theta, r, values, cmap=plt.get_cmap('seismic'), interpolation='nearest', alpha = 1)

ax.set_title('Blade flapping moment')

plt.colorbar(cont)

# fig = plt.figure()
# ax = fig.add_subplot(111, projection='3d')
# pdb.set_trace()
values0 = values.flatten()
# values_mesh = values0.reshape(x_mesh.shape)
# ax.plot_surface(x_mesh, y_mesh, values)

# plt.show()

import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import random

def fun(x, y):
  return x**2 + y

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
x = y = np.arange(-3.0, 3.0, 0.05)
X, Y = np.meshgrid(x, y)
zs = np.array([fun(x,y) for x,y in zip(np.ravel(X), np.ravel(Y))])
Z = zs.reshape(X.shape)
pdb.set_trace()
