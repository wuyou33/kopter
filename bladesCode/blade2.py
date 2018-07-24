import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy import interpolate
import matplotlib as mpl
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter

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

def getRandAngle(x, y):

    r = np.sqrt( np.power(x, 2) + np.power(y, 2) )

    if y >= 0:
        ySignFlag = True
    else:
        ySignFlag = False

    if x >= 0:
        xSignFlag = True
    else:
        xSignFlag = False
    aTanDeg = np.arctan(abs(y) / abs(x)) * 180/np.pi

    if xSignFlag and ySignFlag:
        return r, aTanDeg
    if not xSignFlag and ySignFlag:
        return r, 90 + (90 -aTanDeg)
    if not xSignFlag and not ySignFlag:
        return r, 180 + aTanDeg
    if xSignFlag and not ySignFlag:
        return r, 270 + (90 - aTanDeg)

def normalizeFn(interpolatedValue, rangeValues, middlePoint):
    
    return (2.0 * (interpolatedValue - middlePoint)) / rangeValues

file = open('blade.csv', 'r')
lines = file.readlines()

skipLines, azimuths, valuesLines, zeniths, maxCurrent, minCurrent = 4, [], [], [], 0.0, 0.0

for r in lines[1].split(';'):
	if cleanString(r) != '':
		zeniths += [float(cleanString(r))]

for line in lines[skipLines:]:

    line0 = line.split(';')

    valuesLine = [float(cleanString(t)) for t in line0[:-1]]

    azimuths += [float(cleanString(line0[-1]))]

    if max(valuesLine) > maxCurrent:
        maxCurrent = max(valuesLine)
    elif min(valuesLine) < minCurrent:
        minCurrent = min(valuesLine)

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

valuesTotalBig = np.vstack((valuesTotal1, valuesTotal2))

xtotal = x1 + x2 
ytotal = y1 + y3 
x_mesh_big, y_mesh_big = np.meshgrid(xtotal, ytotal)
x_mesh_short, y_mesh_short = np.meshgrid(x1, y1) #short version



# Results

# x_mesh, y_mesh = x_mesh_big, y_mesh_big
x_mesh, y_mesh = x_mesh_short, y_mesh_short
# valuesTotal = valuesTotalBig
valuesTotal = values1Mat
# Interpolate
f_interpolate = interpolate.interp2d(zeniths, azimuths, valuesLines, kind = 'cubic', copy = True, bounds_error = False, fill_value = np.nan)

#Normalize
rangeValues = maxCurrent - minCurrent
middlePoint = minCurrent + (rangeValues/2.0)

# pdb.set_trace()
# iterate x and y matrix
it = np.nditer(x_mesh, flags = ['multi_index'])
while not it.finished:
    #it[0] is value 
    #it.multi_index is tuple, rows and columns

    if it.multi_index[1] != it.multi_index[0]: #off-diagonal values
        print('{}, {}'.format(it.multi_index[0], it.multi_index[1]))
        x_current = float(it[0])
        y_current = y_mesh[it.multi_index[0], it.multi_index[1]]

        get_r, get_angle = getRandAngle(x_current, y_current)

        interpolatedValue = f_interpolate(get_r, get_angle)
        # valuesTotal[it.multi_index[0], it.multi_index[1]] = interpolatedValue
        valuesTotal[it.multi_index[0], it.multi_index[1]] = normalizeFn(interpolatedValue, rangeValues, middlePoint)
    
    it.iternext()


#-- Plot... ------------------------------------------------
# fig, ax = plt.subplots(subplot_kw=dict(projection='polar'))
# plt.register_cmap(cmap='seismic')
# cmap_current = mpl.colors.Colormap('seismic', N=256)
# cont = ax.contourf(theta, r, values, cmap=cmap_current
# cont = ax.contourf(theta, r, values, cmap="Spectral_r", norm=norm, aspect="auto")
# pene = plt.get_cmap('seismic')
# cont = ax.contourf(theta, r, values, cmap=plt.get_cmap('seismic'), interpolation='nearest', alpha = 1)


# plt.colorbar(cont)

fig = plt.figure()
fig.set_size_inches(16, 10, forward=True)
ax = fig.add_subplot(111, projection='3d')
# ax.plot_surface(x_mesh, y_mesh, valuesTotal, rstride=1, cstride=1, cmap='seismic', edgecolor='none')
# customNorm=SqueezedNorm(vmin=-800, vmax=600, mid=0, s1=1.7, s2=4)
# surf = ax.plot_surface(x_mesh, y_mesh, valuesTotal, 
#                 rstride=10, cstride=10, norm = customNorm, 
#                 cmap=cm.coolwarm, linewidth=0, antialiased=False, aspect="auto")#'seismic'
                # aspect="auto",#norm=norm, 
                # antialiased=False, edgecolor='none')
# ax.plot_surface(x_mesh_short, y_mesh_short, values1Mat, rstride=1, cstride=1, cmap='seismic', edgecolor='none')

# normCustom=SqueezedNorm(vmin=-800, vmax=600, mid=0, s1=1.7, s2=4)
# Plot the surface.
surf = ax.plot_surface(x_mesh, y_mesh, valuesTotal, cmap=cm.coolwarm, rstride=1, cstride=1,
                       linewidth=0, antialiased=False)

# Customize the z axis.
ax.set_zlim(minCurrent, maxCurrent)
ax.zaxis.set_major_locator(LinearLocator(10))
ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))

fig.colorbar(surf, shrink=0.5, aspect=5)

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
