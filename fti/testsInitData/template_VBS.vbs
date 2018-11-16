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
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress, "1201", Array("STEP_1201.TDM")) _
  ,  Array(commonAddress, "1202", Array("STEP_1202.TDM")) _
  ,  Array(commonAddress, "1203", Array("STEP_1203.TDM")) _
  ,  Array(commonAddress, "1204", Array("STEP_1204.TDM")) _
  ,  Array(commonAddress, "1205", Array("STEP_1205.TDM")) _
  ,  Array(commonAddress, "1206", Array("STEP_1206.TDM")) _
  ,  Array(commonAddress, "1207", Array("STEP_1207.TDM")) _
  ,  Array(commonAddress, "1208", Array("STEP_1208.TDM")) _
  ,  Array(commonAddress, "1209", Array("STEP_1209.TDM")) _
  ,  Array(commonAddress, "1210", Array("STEP_1210.TDM")) _
  ,  Array(commonAddress, "1301", Array("STEP_1301.TDM")) _
  ,  Array(commonAddress, "1302", Array("STEP_1302.TDM")) _
  ,  Array(commonAddress, "1303", Array("STEP_1303.TDM")) _
  ,  Array(commonAddress, "1304", Array("STEP_1304.TDM")) _
  ,  Array(commonAddress, "1305", Array("STEP_1305.TDM")) _
  ,  Array(commonAddress, "1306", Array("STEP_1306.TDM")) _
  ,  Array(commonAddress, "1307", Array("STEP_1307.TDM")) _
  ,  Array(commonAddress, "1308", Array("STEP_1308.TDM")) _
  ,  Array(commonAddress, "1309", Array("STEP_1309.TDM")) _
  ,  Array(commonAddress, "1310", Array("STEP_1310.TDM")) _
  ,  Array(commonAddress, "1311", Array("STEP_1311.TDM")) _
  ,  Array(commonAddress, "1312", Array("STEP_1312.TDM")) _
  )

' This dictionary "dictVaDiadem" contains the original variable as names that are displayed by DIAdem as keys. For each key, a corresponding simplified name is assigned
' variable names inside DIAdem -> variable names for the files to be saved
'
' The simplified variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Distance Sensor w\o offset (mm)_Mean", "DistanceSensor"
dictVaDiadem.Add "Centrifugal force w\o offset (N)_Mean", "CF"
dictVaDiadem.Add "Bending moment (Loadcell) w\o offset (Nm)_Mean", "BendingMoment"
dictVaDiadem.Add "My_STG_Blade w\o offset (Nm)_Mean", "MyBlade"
dictVaDiadem.Add "My_STG_loadcell (Nm)_Mean", "MyLoadcell"
dictVaDiadem.Add "Mz_STG_Blade w\o offset (Nm)_Mean", "MzBlade"
'
' Additional operations are possible for flight test data. This option is enabled with the variable "FlagFTData"
FlagFTData = True
' When enabled, DIAdem will diffenciate each of the variables defined in the array "signalsToDif". The result will be saved in .csv format with the prefix "di__" 
signalsToDif = Array("CNT_DST_BST_COL", "CNT_DST_BST_LNG", "CNT_DST_BST_LAT","CNT_DST_COL", "CNT_DST_LNG", "CNT_DST_LAT")
'---------------------------------------------------------------------------------------'

'---------------------------------------------------------------------------------------'
'DEFINITION OF THE FOLDERS FOR THE OUTPUT DATA'
'---------------------------------------------------------------------------------------'
' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

'---------------------------------------------------------------------------------------'
'DEFINITION OF THE TEST STEPS TO BE COMPUTED'
'---------------------------------------------------------------------------------------'
' The variable iterators is used to load and operate only selected steps from above. 
' Only the steps specified in this variable will be considered in the post-processing operations

iterators = Array("1201","1202","1203","1204","1205","1206","1207","1208","1209","1210","1301","1302","1303","1304","1305","1306","1307","1308","1309","1310")',"1311","1312"'

'---------------------------------------------------------------------------------------'
'DATA LOADING AND RE-SAMPLING OPTIONS'
'---------------------------------------------------------------------------------------'
'This bit of code defines how the program "loadMultipleVariablesFromFoldersAndDeleteGroups.vbs" will be executed

newFreq = 100 'Defines the re-sampling new frequency, in Hz. Each variable will be re-sampled to the specified frequency only if its original sampling frequency was higher

loadScript_resampleFlag = True ' True to proceed with the re-sampling operation
loadScript_saveFlagResampledDataCSV = True 'True to save the filtered signals as csv files in the folder defined in "csvFolder", possible values: True or False
loadScript_saveFlagResampledDataTDM = False 'True to save the filtered signals as TDM files in the folder defined in "workingFolder", possible values: True or False

loadScript_saveAllDataFlagPerStep = False 'True to save the raw original signals as TDM files in the folder defined in "workingFolder". One file per step will be created, possible values: True or False

'---------------------------------------------------------------------------------------'
'DEFINITION OF POST-PROCESSING OPERATIONS OPTIONS'
' This section shall not be modified by the user. ONLY DEVELOPING PURPOSES
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