Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\csv_data\"

' Names of the files that require to be imported from each of the files
fileNames = Array(_
                    "Temperatur_HP_1_[°C].tdms" _
                  , "Temperatur_HP_2_[°C].tdms" _
                  , "Druck_HP_1_[bar].tdms" _
                  , "Druck_HP_2_[bar].tdms" _
                  , "Durchfluss_HP_1_[l_min].tdms" _
                  , "Durchfluss_HP_2_[l_min]_.tdms" _
                  , "Force_Piston_Eye_HP1_[N].tdms" _
                  , "Force_Piston_Eye_HP2_[N].tdms" _
                  , "Input_force_[N].tdms" _
                  , "Laser_Piston_[mm].tdms" _
                  , "Laser_Steuerventilhebel_[mm].tdms" _
                  , "Output_force_[N].tdms" _
                  )


' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "2018-03-16_110513\", "01", fileNames) _
  , Array(commonAddress & "2018-03-19_093423\", "02", fileNames) _
  , Array(commonAddress & "2018-03-20_091923\", "03", fileNames) _
  , Array(commonAddress & "2018-04-20_120313\", "04", fileNames) _
  , Array(commonAddress & "2018-04-23_091424\", "05", fileNames) _
  , Array(commonAddress & "2018-04-23_101919\", "06", fileNames) _
  , Array(commonAddress & "2018-04-24_083617\", "07", fileNames) _
  , Array(commonAddress & "2018-04-24_172859 (Step 1.1 post test)\", "08", fileNames) _
  , Array(commonAddress & "2018-05-03_150824\", "09", fileNames) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Temperatur HP_1 [°C]", "TemperaturHP1"
dictVaDiadem.Add "Temperatur HP_2 [°C]", "TemperaturHP2"
dictVaDiadem.Add "Druck HP_1 [bar]", "DruckHP1"
dictVaDiadem.Add "Druck HP_2 [bar]", "DruckHP2"
dictVaDiadem.Add "Durchfluss HP_1 [l\min]", "DurchflussHP1"
dictVaDiadem.Add "Durchfluss HP_2 [l\min]", "DurchflussHP2"
dictVaDiadem.Add "Force Piston Eye HP1 [N]", "ForcePistonEyeHP1"
dictVaDiadem.Add "Force Piston Eye HP2 [N]", "ForcePistonEyeHP2"
dictVaDiadem.Add "Input force [N]", "InputForce"
dictVaDiadem.Add "Laser Piston [mm]", "LaserPiston"
dictVaDiadem.Add "Laser Steuerventilhebel [mm]", "LaserSteuerventilhebel"
dictVaDiadem.Add "Output force [N]", "OutputForce"

newFreq = 100 'Hz'
loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = False 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "rs__"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__" '+iterator 
fileFormatImport = ".csv"
iterators = Array("01","02","03","04","05","06","07","08","09")
' iterators = Array("15","16","17","18")
' iterators = Array(18)

filterFreq = 0.001 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = True
FlagHighPass = False 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False