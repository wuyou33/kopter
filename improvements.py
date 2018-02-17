# TO TEST
import os
import pdb #pdb.set_trace()
# Inner search of folders
# file unchanged or more recent?

def loadParameters(fileName):

	attributes = ()

	file = open(fileName, 'r')

	lines = file.readlines()

	#Local folder

	rawLine = lines[1]

	rawLine = rawLine.replace('\n','')
	rawLine = rawLine.replace('\r','')

	directoryAddressClass = inputDataClassDef(rawLine)

	for i in range(4, int((len(lines)))):

		rawLine = lines[i]

		rawLine = rawLine.replace('\n','')
		rawLine = rawLine.replace('\r','')

		if rawLine != '':

			directoryAddressClass.addSharedAddress(rawLine)

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

#### Code
cwd = os.getcwd() #Get working directory

inputDirectories = loadParameters('inputDirectories.txt')