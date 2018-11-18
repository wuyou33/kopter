Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

'---------------------------------------------------------------------------------------'
'INTRODUCTION
'---------------------------------------------------------------------------------------'
'
' The present script can be used as guidance to write a DIAdem input script to be used as part of the 
' Python&DIAdem Kopter Data Analysis Tool.
' The lines of code written shall be considered as examples.
'---------------------------------------------------------------------------------------'

'---------------------------------------------------------------------------------------'
'DEFINITION OF THE TEST DATA LOCATION, NAMES, ETC'
'---------------------------------------------------------------------------------------'
'
' These are the folders where the data that wants to be imported is contained. Each of the positions of the array "fileNamesBigArrayFolders" define a differnent test step
' Each of the positions of the "fileNamesBigArrayFolders" contains an array with this three positions:
''
' Position #1: Contains a string with the address to the folder where the data from the step is contained. This string can be created by joining a commom higher folder address (variable "commomAddress")
' to a the specific folder name where the data from the test is stored : commonAddress & 'folderName' For example: commonAddress & "2018-03-16_110513\"
''
' Position #2: Contains a string with the label assigned to the test. It is a string which shall start with an integer number followed by a dash "-" and a custom label. 
' E.g.: "01-Step-3.1", "89-FT14", ... It is not valid: "step 01", "first step"...
''
' Position #3: Contains an array with all the files names that belong to the test step. This file would have only one define position if all the data for each of the recorded magnitudes is
' contained in the same file, and multiple positions if the data for each of the recorded magnitudes is stored in a independent files.
commonAddress = "G:\FTI\ProcData\SKYeSH09\P3\J17-Test Data\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_120203\", "1-RC", Array("fti_2018-08-22_120203_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-019\FTI\Run2\", "83-FT19", Array("fti_20181003150150_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-020\FTI\Run1\", "84-FT20", Array("fti_20181004123543_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-020\FTI\Run2\", "85-FT20", Array("fti_20181004141626_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-021\FTI\Run1\", "86-FT21", Array("fti_20181005131723_pp.tdms")) _
    )
' Additionally the following code provides an example of how to import data from a test step which has its data spread over multiple files. The use of the variable
' "filesNames" is just to simplify the code.
filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
                  , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
                  , "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

filesNames2 = Array("Output_force_without_offset_[N].tdms", "Output_force_.tdms", "Output_force_w_o_offset.tdms"_
                  , "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\01_RAW\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "Step 1.1\2018-10-10_144346\", "1-Step-1.1", filesNames) _
  , Array(commonAddress & "Step 1.1 Repeat\2018-10-30_174628\", "29-Step-1.1-Repeat", filesNames) _
  , Array(commonAddress & "Step 1.2\2018-10-11_101715\", "2-Step-1.2", filesNames2) _
  , Array(commonAddress & "Step 1.3\2018-10-10_154135\", "3-Step-1.3", filesNames2) _
  )
''
' This dictionary "dictVaDiadem" is used to specify the variables which shall be imported. It contains the original variable as names that 
' are displayed by DIAdem as keys. For each key, a corresponding simplified name is assigned. Example:
' dictVaDiadem.Add " [variable name as it appears in DIAdem]", "[name which shall be used when saving the variable]"
'
' The simplified variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Distance Sensor w\o offset (mm)_Mean", "DistanceSensor"
dictVaDiadem.Add "Centrifugal force w\o offset (N)_Mean", "CF"
dictVaDiadem.Add "Druck HP_2 [bar]", "Pres2"
dictVaDiadem.Add "Durchfluss HP_1 [l\min]", "VolFlow1"
dictVaDiadem.Add "CNT_DST_BST_LAT", "CNT_DST_BST_LAT"
dictVaDiadem.Add "CNT_DST_BST_LNG", "CNT_DST_BST_LNG"
dictVaDiadem.Add "CNT_DST_COL", "CNT_DST_COL"
dictVaDiadem.Add "CNT_DST_LAT", "CNT_DST_LAT"
'
' Additional operations are possible for flight test data. This option is enabled with the variable "FlagFTData"
FlagFTData = True
' When enabled, DIAdem will differentiate each of the variables defined in the array "signalsToDif". The result will be saved in .csv format with the prefix "di__" 
signalsToDif = Array("CNT_DST_BST_COL", "CNT_DST_BST_LNG", "CNT_DST_BST_LAT","CNT_DST_COL", "CNT_DST_LNG", "CNT_DST_LAT")
'---------------------------------------------------------------------------------------'

'---------------------------------------------------------------------------------------'
'DEFINITION OF THE FOLDERS FOR THE OUTPUT DATA'
'---------------------------------------------------------------------------------------'
' The following two variables are used to define where DIAdem shall save the data. Usually, the same location is defined for the two folders.
'
' Where the raw data will be saved in "TMD" format.
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

' Where the data will be saved in csv format.
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS\csv_data\"
'---------------------------------------------------------------------------------------'

'---------------------------------------------------------------------------------------'
'DEFINITION OF THE TEST STEPS TO BE COMPUTED'
'---------------------------------------------------------------------------------------'
'
' The variable "iterators" is used to load and operate only selected steps. The labels used shall be present in the variable "fileNamesBigArrayFolders"
' Only the steps specified in this variable will be considered.

iterators = Array("1-RC", "83-FT19", "84-FT20", "85-FT20", "86-FT21")
iterators = Array("1-Step-1.1", "29-Step-1.1-Repeat", "2-Step-1.2", "3-Step-1.3")
'---------------------------------------------------------------------------------------'

'---------------------------------------------------------------------------------------'
'DATA LOADING AND RE-SAMPLING OPTIONS'
'---------------------------------------------------------------------------------------'
'This bit of code defines how the main script of the tool will be executed

newFreq = 100 'Defines the re-sampling new frequency, in Hz. Each variable will be re-sampled to the specified frequency only if its original sampling frequency was higher

loadScript_resampleFlag = True ' True to proceed with the re-sampling operation
loadScript_saveFlagResampledDataCSV = True 'True to save the filtered signals as csv files in the folder defined in "csvFolder", possible values: True or False
loadScript_saveFlagResampledDataTDM = False 'True to save the filtered signals as TDM files in the folder defined in "workingFolder", possible values: True or False

loadScript_saveAllDataFlagPerStep = False 'True to save the raw original signals as TDM files in the folder defined in "workingFolder". One file per step will be created, possible values: True or False