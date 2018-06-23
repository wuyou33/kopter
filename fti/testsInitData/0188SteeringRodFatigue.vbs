Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

'---------------------------------------------------------------------------------------'
'DEFINITION OF THE TEST DATA LOCATION, NAMES, ETC'
'---------------------------------------------------------------------------------------'

' These are the folders where the data that wants to be imported is contained. Each of the positions of the array "fileNamesBigArrayFolders" define a differnent test step
' Each of the positions of the "fileNamesBigArrayFolders" contains an array with this three positions:
''
' Position #1: Contains a string with the address to the folder where the data from the step is contained. This string can be created by joining a commom higher folder address (variable "commomAddress")
' to a the specific folder name where the data from the test is stored : commonAddress & 'folderName' For example: commonAddress & "2018-03-16_110513\"
''
' Position #2: Contains a string with the number assigned to the test. It is a string containing numeric characters, e.g.: "01", "152"... It is not valid: "step 01", "first step"...
''
' Position #3: Contains an array with all the files names that belong to the test step. This file would have only one define position if all the data for each of the recorded magnitudes is
' contained in the same file, and multiple positions if the data for each of the recorded magnitudes is stored in a independant files.
' commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0188\01_TDMS_data_Set-complete\02_STEPS"
' fileNamesBigArrayFolders = Array( _
'     Array(commonAddress & "\", "1501", Array("STEP_1501.TDM")) _
'   ,  Array(commonAddress & "\", "1502", Array("STEP_1502.TDM")) _
'   ,  Array(commonAddress & "\", "1503", Array("STEP_1503.TDM")) _
'   ,  Array(commonAddress & "\", "1504", Array("STEP_1504.TDM")) _
'   )

commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0188\01_TDMS_data_Set-complete\01_RAW"
variables = Array("Upper_control_rod_strain_[mm_m].tdms", "Upper_control_rod_[N].tdms")
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "\STG data_2018-04-24_122510\", "1501", variables) _
  ,  Array(commonAddress & "\STG data_2018-05-04_152236\", "1502", variables) _
  ,  Array(commonAddress & "\STG data_2018-05-04_155606\", "1503", variables) _
  ,  Array(commonAddress & "\STG data_2018-05-07_134635\", "1504", variables) _
  )

' This dictionary "dictVaDiadem" contains the original variable as names that are displayed by DIAdem as keys. For each key, a corresponding simplified name is assigned
' variable names inside DIAdem -> variable names for the files to be saved
'
' The simplified variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Upper control rod [N]", "UCRForce"
dictVaDiadem.Add "Upper control rod strain [mm\m]", "UCRStrain"

'---------------------------------------------------------------------------------------'


'---------------------------------------------------------------------------------------'
'DEFINITION OF THE FOLDERS FOR THE OUTPUT DATA'
'---------------------------------------------------------------------------------------'
' Where the raw data will be saved in "TMD" format
workingFolder = "P:\11_J67\09_Fatigue\steeringRods\"

' Where the data will be saved in csv format
csvFolder = "P:\11_J67\09_Fatigue\steeringRods\"


'---------------------------------------------------------------------------------------'
'DEFINITION OF THE TEST STEPS TO BE COMPUTED'
'---------------------------------------------------------------------------------------'
' The variable iterators is used to load and operate only selected steps from above. 
' Only the steps specified in this variable will be considered in the post-processing operations

iterators = Array("1501","1502","1503","1504")
' iterators = Array("1501")


'---------------------------------------------------------------------------------------'
'DATA LOADING AND RE-SAMPLING OPTIONS'
'---------------------------------------------------------------------------------------'
'This bit of code defines how the program "loadMultipleVariablesFromFoldersAndDeleteGroups.vbs" will be executed

newFreq = 100 'Defines the re-sampling new frequency, in Hz'

loadScript_resampleFlag = True ' True to proceed with the re-sampling operation
loadScript_saveFlagResampledDataCSV = True 'True to save the filtered signals as csv files in the folder defined in "csvFolder", possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'True to save the filtered signals as TDM files in the folder defined in "workingFolder", possible values: True or False

loadScript_saveAllDataFlagPerStep = False 'True to save the raw original signals as TDM files in the folder defined in "workingFolder". One file per step will be created, possible values: True or False


'---------------------------------------------------------------------------------------'
'DEFINITION OF POST-PROCESSING OPERATIONS OPTIONS'
'---------------------------------------------------------------------------------------'

'Digital filtering of the signal
FlagFilteredData = True ' True to proceed with the filtering operation

filterFreq = 0.1 'Cut-off freq. for both the high-pass and low-pass filters, in Hz'

FlagHighPass = False 'Define True for high-pass filter and False for low-pass'
saveFlagFilteredData = True 'True to save the filtered signals as csv files in the folder defined in "csvFolder", possible values: True or False


' The lines below shall not be modified, they exist for developing purposes only
importDataFlag = True

FlagFTTData = False

FlagMaxMinMeanData = False

saveFlagMaxMinMean = False 'possible values: True or False

fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"