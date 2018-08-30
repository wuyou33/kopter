import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

# plt.axis([0, 10, 0, 1])

# for i in range(10):
#     y = np.random.random()
#     plt.scatter(i, y)
#     plt.pause(0.05)



# set up figure and animation
fig = plt.figure()
ax = fig.add_subplot(111, aspect='equal', autoscale_on=False,
                     xlim=(0, 10), ylim=(0, 1))
ax.grid()

line, = ax.plot([], [], 'o-', lw=2) varClassesGetSegmentsDict.update({var : varClass})

nFrames = 200
indexFrames = range(0, len(varClassesGetSegmentsDict['CNT_DST_BST_COL'].time), nFrames)

pdb.set_trace()

fig, ax = plt.subplots()
xdata, ydata = [], []
ln, = plt.plot([], [], 'ro', animated=True)

def init():
    ax.set_xlim(0.0, varClassesGetSegmentsDict['CNT_DST_BST_COL'].time[-1])
    ax.set_ylim(min(varClassesGetSegmentsDict['CNT_DST_BST_COL'].data), max(varClassesGetSegmentsDict['CNT_DST_BST_COL'].data))
    return ln,

def update(frame):
    global varClassesGetSegmentsDict

    currentTime = varClassesGetSegmentsDict['CNT_DST_BST_COL'].time[frame]
    currentValue = varClassesGetSegmentsDict['CNT_DST_BST_COL'].data[frame]
    
    xdata.append(frame)
    ydata.append(np.sin(frame))
    ln.set_data(xdata, ydata)
# scatterArt = ax.scatter([], [])
# time_text = ax.text(0.02, 0.95, '', transform=ax.transAxes)
# energy_text = ax.text(0.02, 0.90, '', transform=ax.transAxes)

x_values, y_values = [], []
for i in range(10):
    x_values += [i]
    y_values += [np.random.random()]

def init():
    # pass
    """initialize animation"""
    line.set_data([], [])
    # time_text.set_text('')
    # energy_text.set_text('')
    return line

def animate(i):
    """perform animation step"""
    # global pendulum, dt
    global dt, x_values, y_values
    # pendulum.step(dt)
    
    # line.set_data([])
    line.set_data(x_values[i], y_values[i])
    # line.set_data(*pendulum.position())
    # time_text.set_text('time = %.1f' % pendulum.time_elapsed)
    # energy_text.set_text('energy = %.3f J' % pendulum.energy())
    # return line, time_text, energy_text
    return line

# choose the interval based on dt and the time to animate one step
from time import time
dt = 1./30 # 30 fps
t0 = time()
animate(0)
t1 = time()
interval = 1000 * dt - (t1 - t0)
# dt = 5

ani = animation.FuncAnimation(fig, animate, frames=300,
                              interval=interval, blit=True, init_func=init)
plt.show()