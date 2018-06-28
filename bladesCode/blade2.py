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

x1 = []
y1 = []
x2 = []
y2 = []
x3 = []
y3 = []
x4 = []
y4 = []

for theta_i in azimuthsRad[:90]:

    for r_i in zeniths:

        x1 += [r_i * np.cos(theta_i)]

        y1 += [r_i * np.sin(theta_i)]

for theta_i in azimuthsRad[90:180]:

    for r_i in zeniths:

        x2 += [r_i * np.cos(theta_i)]

        y2 += [r_i * np.sin(theta_i)]

for theta_i in azimuthsRad[180:270]:

    for r_i in zeniths:

        x3 += [r_i * np.cos(theta_i)]

        y3 += [r_i * np.sin(theta_i)]


values1 = values[:90,:]
values2 = values[90:180,:]
values3 = values[180:270,:]
values4 = values[270:,:]
values4 = np.vstack((values4,np.full((10,len(zeniths)), np.nan)))

values1Mat = np.diag(values1.flatten())
values1Mat = values1Mat + np.tril(np.full_like(values1Mat, np.nan), -1) + np.triu(np.full_like(values1Mat, np.nan), 1)
values2Mat = np.diag(values2.flatten())
values2Mat = values2Mat + np.tril(np.full_like(values2Mat, np.nan), -1) + np.triu(np.full_like(values2Mat, np.nan), 1)
values3Mat = np.diag(values3.flatten())
values3Mat = values3Mat + np.tril(np.full_like(values3Mat, np.nan), -1) + np.triu(np.full_like(values3Mat, np.nan), 1)
values4Mat = np.diag(values4.flatten())
values4Mat = values4Mat + np.tril(np.full_like(values4Mat, np.nan), -1) + np.triu(np.full_like(values4Mat, np.nan), 1)

valuesTotal1 = np.hstack((values1Mat, values2Mat))
valuesTotal2 = np.hstack((values4Mat, values3Mat))

valuesTotal = np.vstack((valuesTotal1, valuesTotal2))

xtotal = x1 + x2 
ytotal = y1 + y3 
x_mesh, y_mesh = np.meshgrid(xtotal, ytotal)

x_mesh_short, y_mesh_short = np.meshgrid(x1, y1)

#-- Plot... ------------------------------------------------
# fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
# plt.register_cmap(cmap='seismic')
# cmap_current = mpl.colors.Colormap('seismic', N=256)
# cont = ax.contourf(theta, r, values, cmap=cmap_current
# norm=SqueezedNorm(vmin=-800, vmax=600, mid=0, s1=1.7, s2=4)
# cont = ax.contourf(theta, r, values, cmap="Spectral_r", norm=norm, aspect="auto")
# pene = plt.get_cmap('seismic')
# cont = ax.contourf(theta, r, values, cmap=plt.get_cmap('seismic'), interpolation='nearest', alpha = 1)


# plt.colorbar(cont)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
# ax.plot_surface(x_mesh, y_mesh, valuesTotal, rstride=1, cstride=1, cmap='seismic', edgecolor='none')
ax.plot_surface(x_mesh_short, y_mesh_short, values1Mat, rstride=1, cstride=1, cmap='seismic', edgecolor='none')

ax.set_title('Blade flapping moment')

# import numpy as np
# from mpl_toolkits.mplot3d import Axes3D
# import matplotlib.pyplot as plt
# import random

# def fun(x, y):
#   return x**2 + y

# fig = plt.figure()
# ax = fig.add_subplot(111, projection='3d')
# x = y = np.arange(-3.0, 3.0, 0.05)
# X, Y = np.meshgrid(x, y)
# zs = np.array([fun(x,y) for x,y in zip(np.ravel(X), np.ravel(Y))])
# Z = zs.reshape(X.shape)
plt.show()
