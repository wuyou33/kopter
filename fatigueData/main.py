import os
import sys
import pdb #pdb.set_trace()

from moduleFunctions import *

plotSettings = importPlottingOptions()

file = open('Probe_3_Zyklische Ergebnisse.csv', 'r')
lines = file.readlines()

cycleN, maxF, meanF, minF = [], [], [], []

lineN = 0
for line in lines:

	currentLineSplit = line.split(';')

	if lineN > 1:
		
		cycleN += [returnNumber(currentLineSplit[0])]
		maxF += [returnNumber(currentLineSplit[20])]
		meanF += [returnNumber(currentLineSplit[21])]
		minF += [returnNumber(currentLineSplit[22])]

	lineN += 1
		

file.close()

dataFromRun = dataFromRunClass(1)

dataFromRun.add_data(cycleN, maxF, meanF, minF)

plotSingleRun(dataFromRun, plotSettings)