Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0159\06_Dat_Analysis\1000Hz\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0159\06_Dat_Analysis\1000Hz\"

filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms", _ 
                  "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms", _
                  "Force_Piston_Eye_HP2_[N].tdms", "Input_force_[N].tdms", "Laser_Piston_[mm].tdms", _
                  "Laser_Steuerventilhebel_[mm].tdms", "Output_force_[N].tdms", "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0214\01_Data_set-complete\01_RAW\Housing SN 002\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress &"Step 1.1\2018-09-11_134042\", "002-1.1", filesNames) _
  , Array(commonAddress &"Step 1.2\2018-09-11_171409\", "002-1.2", filesNames) _
  , Array(commonAddress &"Step 1.3\2018-09-11_134524\", "002-1.3", filesNames) _
  , Array(commonAddress &"Step 1.3\2018-09-11_134524\", "002-1.3", filesNames) _
  )

' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("1312")
iterators = Array("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08")

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
' dictVaDiadem.Add "Rohr C", "RossC"
' dictVaDiadem.Add "Rohr B", "RossB"
' dictVaDiadem.Add "Rohr A", "RossA"
' dictVaDiadem.Add "Mischh_Kollektiv", "LeverColl"
' dictVaDiadem.Add "Mischh_Laengs", "LeverLong"
' dictVaDiadem.Add "Mischh_seitlich", "LeverLat"
' dictVaDiadem.Add "Steer_Rod blue", "ConnRodblue"
' dictVaDiadem.Add "Steer_Rod gold", "ConnRodgold"
dictVaDiadem.Add "Steer_Rod black", "ConnRodblack"
' dictVaDiadem.Add "Booster Link long", "BoosterLinklong"
' dictVaDiadem.Add "Booster Link col", "BoosterLinkcol"
' dictVaDiadem.Add "Booster Link lat", "BoosterLinklat"
' dictVaDiadem.Add "Holder right", "HolderRight"
' dictVaDiadem.Add "COLL_Position", "COLLPosition"
' dictVaDiadem.Add "LONG_Position", "LONGPosition"
' dictVaDiadem.Add "LAT_Position", "LATPosition"
' dictVaDiadem.Add "Zykluszaehler Fatigue (MU)", "NumberCycles"

newFreq = 1000 'Hz'

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