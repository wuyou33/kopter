Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0214\01_Data_set-complete\02_STEPS\csv\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0214\01_Data_set-complete\02_STEPS\csv\"

filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
                  , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
                  , "Force_Piston_Eye_HP2_[N].tdms", "Input_force_[N].tdms", "Laser_Piston_[mm].tdms"_
                  , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_[N].tdms", "Temperatur_HP_1_[degC].TDM", "Temperatur_HP_2_[degC].TDM")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0214\01_Data_set-complete\01_RAW\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "Housing SN 002\Step 1.1\2018-09-11_134042\", "1-SN002-1.1", filesNames) _
  , Array(commonAddress & "Housing SN 002\Step 1.2\2018-09-11_171409\", "2-SN002-1.2", filesNames) _
  , Array(commonAddress & "Housing SN 002\Step 1.3\2018-09-11_134524\", "3-SN002-1.3", filesNames) _ 'Correct temperatures variables names set'
  , Array(commonAddress & "Housing SN 002\Step 1.6\2018-09-11_153349\", "4-SN002-1.6", filesNames) _
  , Array(commonAddress & "Housing SN 002\Step 2.3 #1\2018-09-11_171409\", "5-SN002-2.3.1", filesNames) _
  , Array(commonAddress & "Housing SN 002\Step 2.3 #2\2018-09-11_175744\", "6-SN002-2.3.2", filesNames) _
  , Array(commonAddress & "Housing SN 002\Step 2.3 #3\2018-09-11_181405\", "7-SN002-2.3.3", filesNames) _
  , Array(commonAddress & "Housing SN 002\Step 2.4\2018-09-11_093806\", "8-SN002-2.4", filesNames) _ 'Correct temperatures variables names 
  , Array(commonAddress & "Housing SN 0012\Step 1.1\2018-09-06_143837\", "9-SN0012-1.1", filesNames) _
  , Array(commonAddress & "Housing SN 0012\Step 1.3\2018-09-07_142954\", "10-SN0012-1.3", filesNames) _ 'Correct temperatures variables names 
  , Array(commonAddress & "Housing SN 0012\Step 1.6\2018-09-06_144434\", "11-SN0012-1.6", filesNames) _
  , Array(commonAddress & "Housing SN 0012\Step 2.3\2018-09-07_104113\", "12-SN0012-2.3", filesNames) _
  , Array(commonAddress & "Housing SN 0012\Step 2.4\2018-09-07_131727\", "13-SN0012-2.4", filesNames) _ 'Correct temperatures variables names 
  )

' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("1312")
' iterators = Array("1-SN002-1.1","2-SN002-1.2","3-SN002-1.3","4-SN002-1.6","5-SN002-2.3.1","6-SN002-2.3.2","7-SN002-2.3.3","8-SN002-2.4"_
'                 , "9-SN0012-1.1", "10-SN0012-1.3", "11-SN0012-1.6", "12-SN0012-2.3", "13-SN0012-2.4" _
'                 )
iterators = Array("3-SN002-1.3", "8-SN002-2.4", "10-SN0012-1.3", "13-SN0012-2.4")
' iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08")

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
' dictVaDiadem.Add "Druck HP_1 [bar]", "Pres1"
' dictVaDiadem.Add "Druck HP_2 [bar]", "Pres2"
' dictVaDiadem.Add "Durchfluss HP_1 [l\min]", "VolFlow1"
' dictVaDiadem.Add "Durchfluss HP_2 [l\min]", "VolFlow2"
' dictVaDiadem.Add "Force Piston Eye HP1 [N]", "ForceEye1"
' dictVaDiadem.Add "Force Piston Eye HP2 [N]", "ForceEye2"
' dictVaDiadem.Add "Input force [N]", "InputForce"
' dictVaDiadem.Add "Laser Piston [mm]", "PistonDispl"
' dictVaDiadem.Add "Laser Steuerventilhebel [mm]", "ValveDispl"
' dictVaDiadem.Add "Output force [N]", "OutputForce"
dictVaDiadem.Add "Temperatur HP_1 [degC]", "Temp1"
dictVaDiadem.Add "Temperatur HP_2 [degC]", "Temp2"

newFreq = 500 'Hz'

loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"

filterFreq = 0.1 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = True
FlagHighPass = True 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False