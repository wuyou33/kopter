Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\"
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\csv_data\"

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
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "2018-01-30_103559\", "01", fileNames) _
  , Array(commonAddress & "2018-01-31_115139\", "02", fileNames) _
  , Array(commonAddress & "2018-02-13_083036\", "03", fileNames) _
  , Array(commonAddress & "2018-02-14_140513\", "04", fileNames) _
  , Array(commonAddress & "2018-02-15_101019\", "05", fileNames) _
  , Array(commonAddress & "2018-02-16_150804\", "06", fileNames) _
  , Array(commonAddress & "2018-02-19_084519\", "07", fileNames) _
  , Array(commonAddress & "2018-02-22_110842\", "08", fileNames) _
  , Array(commonAddress & "2018-02-23_093532\", "09", fileNames) _
  , Array(commonAddress & "2018-02-26_095412\", "10", fileNames) _
  , Array(commonAddress & "2018-02-27_095219\", "11", fileNames) _
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
loadScript_saveAllDataFlagPerStep = True 'possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "rs__"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__" '+iterator 
fileFormatImport = ".csv"
iterators = Array("01","02","03","04","05","06","07","08","09","10","11")
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