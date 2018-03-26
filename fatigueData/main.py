import os
import sys
import pdb #pdb.set_trace()

# Import settings
from moduleFunctions import *
plotSettings = importPlottingOptions()
cwd = os.getcwd() #Get working directory

# What to do?
actuatorFlag = True
gaugesFlag = True

# Gauges data analysis
testFrequency = 6.0 #HZ

dataMainPitchLink = dataFromGaugesSingleMagnitudeClass('PitchLinkMain', testFrequency)
dataInnerPitchLink = dataFromGaugesSingleMagnitudeClass('InnerPitchLink', testFrequency)
# dataClasses = (dataMainPitchLink, dataInnerPitchLink)
dataClasses = (dataMainPitchLink,)
inputFolderAddress = loadFileAddresses('filesToLoad_gauges.txt')

for folderName in inputFolderAddress.getTupleFiles(): #For each folder with min, max or mean values
	os.chdir(folderName) #Go to folder
	folderCurrent = os.getcwd() #Get working directory
	fieldOfFiles = folderCurrent.split('\\')[-1]

	listOfFilesSortedInFolder = sortFilesInFolderByLastNumberInName(os.listdir(folderCurrent))

	for dataClass in dataClasses: #For each class variable

		print('---> Importing data for variable: ' + dataClass.get_description() + ', '+fieldOfFiles+ ' values')

		for fileName in listOfFilesSortedInFolder: #For each file in folder

			if dataClass.get_description() in fileName: #Restring to only file matching type of variable of class

				print('-> Reading: ' + fileName)
				dataClass.importDataForClass(fileName, fieldOfFiles)

		dataClass.getTimeList(fieldOfFiles)
		
		dataClass.reStartXvalues()

		# pdb.set_trace()

# Plotting
pdb.set_trace()
for dataClass in dataClasses: #For each class variable
	dataClass.plot(plotSettings)

os.chdir(cwd)
#Import data from actuator
if actuatorFlag:
	inputFilesAddress = loadFileAddresses('filesToLoad_actuator.txt')

	dataFromRuns, previousNCycles = [], 0

	for file in inputFilesAddress.getTupleFiles():

		dataFromRun_temp = importDataActuator(file)

		dataFromRun_temp.setAbsoluteNCycles(previousNCycles)

		previousNCycles = dataFromRun_temp.get_absoluteNCycles()[-1]

		dataFromRuns += [dataFromRun_temp]

	#################################

	#Plot data
	plotSingleRun(dataFromRuns[0], plotSettings)
	plotAllRuns(dataFromRuns, plotSettings)

plt.show(block = True)