import os
import sys
import pdb #pdb.set_trace()

from moduleFunctions import *

#Import data
inputFilesAddress = loadFileAddresses('filesToLoad.txt')
plotSettings = importPlottingOptions()

dataFromRuns, previousNCycles = [], 0

for file in inputFilesAddress.getTupleFiles():

	dataFromRun_temp = importData(file)

	dataFromRun_temp.setAbsoluteNCycles(previousNCycles)

	previousNCycles = dataFromRun_temp.get_absoluteNCycles()[-1]

	dataFromRuns += [dataFromRun_temp]

#################################

#Plot data
plotSingleRun(dataFromRuns[0], plotSettings)
plotAllRuns(dataFromRuns, plotSettings)
plt.show(block = True)