import os
import sys
import getopt
from shutil import copyfile
import pdb # pdb.set_trace()

#Program
############ 
# Functions

def loadParameters(fileName):

	#Funtion
	def cleanString(stringIn):
		
		if stringIn[-1:] in ('\t', '\n'):

			return cleanString(stringIn[:-1])

		else:

			return stringIn

	attributes = ()

	file = open(fileName, 'r')

	lines = file.readlines()

	#Local folder

	rawLine = lines[1]

	directoryAddressClass = inputDataClassDef(cleanString(rawLine))

	for i in range(4, int((len(lines)))):

		rawLine = lines[i]

		if rawLine != '':

			directoryAddressClass.addSharedAddress(cleanString(rawLine))

	file.close()

	return directoryAddressClass

class inputDataClassDef(object):
	"""docstring for inputData"""
	def __init__(self, localAddress):
		"""
		Initializes the class with local address and empty directory of shared folders
		"""

		if localAddress[0] != 'C':

			raise ValueError('ERROR: Local folder has to be located in C: drive')

		self.__localAddress = localAddress

		self.__sharedAddress_tuple = ()

	def addSharedAddress(self, sharedAddress):

		if os.path.isdir(sharedAddress):

			self.__sharedAddress_tuple += (sharedAddress,)

		else:

			print('WARNING: Address '+sharedAddress+' does not exist or is not a directory, entry skipped')

	def getLocalDirectory(self):

		return self.__localAddress

	def getSharedDirectory_tuple(self):

		return self.__sharedAddress_tuple

def recursiveFunction(currentHighLevelFolder_path_shared):

	# 
	global path_local, path_shared
	cwd = os.getcwd() #Get working directory
	print('\n'+'-> Exploring shared drive, folder: '+cwd.split('\\')[-1])
	for file in os.listdir(cwd):

		if os.path.isdir(file):

			#Create folder in local
			checkLocalVersion(cwd + '\\' + file, currentHighLevelFolder_path_shared)

			#Go inside the folder and continue searching for files
			os.chdir(cwd + '\\' + file)
			recursiveFunction(currentHighLevelFolder_path_shared)
			os.chdir(cwd)

		elif file.startswith('Thumbs.db'): #Does nothing if this file is found
			pass

		elif file.startswith('~$'): #Does nothing for MS Office temporal hidden files
			pass

		elif os.path.isfile(file):

			checkLocalVersion(cwd + '\\' + file, currentHighLevelFolder_path_shared)
			os.chdir(cwd)

		else:

			raise ValueError('ERROR: Error handling file')


def checkLocalVersion(fileOrFolder_path_shared_found, currentHighLevelFolder_path_shared):

	global path_local

	fileOrFolder_path_shared = fileOrFolder_path_shared_found
	fileOrFolder_path_local = fileOrFolder_path_shared_found.replace(currentHighLevelFolder_path_shared, path_local + '\\'+ currentHighLevelFolder_path_shared.split('\\')[-1])

	fileOrFolderName = fileOrFolder_path_shared_found.split('\\')[-1]
	
	if os.path.isfile(fileOrFolder_path_shared): #if this is a file

		if os.path.isfile(fileOrFolder_path_local): #If file already exists in local folder

			if os.path.getmtime(fileOrFolder_path_shared) > os.path.getmtime(fileOrFolder_path_local): #

				os.remove(fileOrFolder_path_local) #Remove old version of file in local drive
				copyfile(fileOrFolder_path_shared, fileOrFolder_path_local) #Copy version on shared drive to local drive
				print('File updated in local drive: ' + fileOrFolderName)


			else:

				print('File skipped (local version is the same or newer): '+fileOrFolderName)

		else:

			copyfile(fileOrFolder_path_shared, fileOrFolder_path_local) #Copy version on shared drive to local drive
			print('File copied to local drive: ' + fileOrFolderName)

	elif os.path.isdir(fileOrFolder_path_shared):#if this is a folder

		if not os.path.isdir(fileOrFolder_path_local): #If folder does not already exists in local folder

			os.mkdir(fileOrFolder_path_local)
			print('Folder created in local drive: '+fileOrFolderName)

	else:
		raise ValueError('ERROR: Error handling file type')


######################
# Code

print('\n'+'------------ Automatic file update --------------------'+'\n')

inputDirectories = loadParameters('inputDirectories.txt') #File loaded from working dir (where the main script is saved)

path_local = inputDirectories.getLocalDirectory()
path_shared = inputDirectories.getSharedDirectory_tuple()

cwd = os.chdir(path_local)

for folderChosen in path_shared:

	if not os.path.isdir(folderChosen):

		print('\n'+'WARNING: Folder not found in shared drive: '+folderChosen.split('\\')[-1])

	elif not os.path.isdir(path_local+'\\'+folderChosen.split('\\')[-1]):

		os.mkdir(path_local+'\\'+folderChosen.split('\\')[-1])
		print('--> Folder created in local drive: '+folderChosen.split('\\')[-1])

#Main loop

for folderChosen in path_shared:

	if not os.path.isdir(folderChosen):

		print('\n'+'WARNING: Folder not found in shared drive: '+folderChosen.split('\\')[-1])

	else:

		os.chdir(folderChosen)
		recursiveFunction(folderChosen)

print('\n'+'\n'+'---> Execution finished')