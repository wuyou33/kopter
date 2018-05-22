Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

' Names of the files that require to be imported from each of the files, fileName.tdms
' fileNames = Array(_
'                     "Brücke_(V_V)" _
'                   , "Druck_HP_1" _
'                   , "Druck_HP_2" _
'                   , "Druck_HP_2_[bar]" _
'                   , "Durchfluss_HP1" _
'                   , "Durchfluss_HP2" _
'                   , "Laser_Piston" _
'                   , "Laser_Steuerventilhebel" _
'                   , "Temperatur_HP_1" _
'                   , "Temperatur_HP_2" _
'                   )


' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0169\01_TDMS_data_Set-complete\02_STEPS"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "\", "1201", Array("STEP_1201.TDM")) _
  ,  Array(commonAddress & "\", "1202", Array("STEP_1202.TDM")) _
  ,  Array(commonAddress & "\", "1203", Array("STEP_1203.TDM")) _
  ,  Array(commonAddress & "\", "1204", Array("STEP_1204.TDM")) _
  ,  Array(commonAddress & "\", "1205", Array("STEP_1205.TDM")) _
  ,  Array(commonAddress & "\", "1206", Array("STEP_1206.TDM")) _
  ,  Array(commonAddress & "\", "1207", Array("STEP_1207.TDM")) _
  ,  Array(commonAddress & "\", "1208", Array("STEP_1208.TDM")) _
  ,  Array(commonAddress & "\", "1209", Array("STEP_1209.TDM")) _
  ,  Array(commonAddress & "\", "1210", Array("STEP_1210.TDM")) _
  ,  Array(commonAddress & "\", "1301", Array("STEP_1301.TDM")) _
  ,  Array(commonAddress & "\", "1302", Array("STEP_1302.TDM")) _
  ,  Array(commonAddress & "\", "1303", Array("STEP_1303.TDM")) _
  ,  Array(commonAddress & "\", "1304", Array("STEP_1304.TDM")) _
  ,  Array(commonAddress & "\", "1305", Array("STEP_1305.TDM")) _
  ,  Array(commonAddress & "\", "1306", Array("STEP_1306.TDM")) _
  ,  Array(commonAddress & "\", "1307", Array("STEP_1307.TDM")) _
  ,  Array(commonAddress & "\", "1308", Array("STEP_1308.TDM")) _
  ,  Array(commonAddress & "\", "1309", Array("STEP_1309.TDM")) _
  ,  Array(commonAddress & "\", "1310", Array("STEP_1310.TDM")) _
  ,  Array(commonAddress & "\", "1311", Array("STEP_1311.TDM")) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Distance Sensor w\o offset (mm)_Mean", "DistanceSensor"
dictVaDiadem.Add "Centrifugal force w\o offset (N)_Mean", "CF"
dictVaDiadem.Add "Bending moment (Loadcell) w\o offset (Nm)_Mean", "BendingMoment"
dictVaDiadem.Add "My_STG_Blade w\o offset (Nm)_Mean", "MyBlade"
dictVaDiadem.Add "My_STG_loadcell (Nm)_Mean", "MyLoadcell"
dictVaDiadem.Add "Mz_STG_Blade w\o offset (Nm)_Mean", "MzBlade"

newFreq = 100 'Hz'

loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"
' iterators = Array("1201","1202","1203","1204","1205","1206","1207","1208","1209","1210","1301","1302","1303","1304","1305","1306","1307","1308","1309","1310")
' iterators = Array("15","16","17","18")
' iterators = Array("19","20")
iterators = Array("1311")

filterFreq = 0.001 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = True
FlagHighPass = False 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False