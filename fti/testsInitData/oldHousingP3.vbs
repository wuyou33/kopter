Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\AE_csv_data\"
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\AE_csv_data\"

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
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "Step 3.1\2018-01-30_103559\", "1-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-01-31_115139\", "2-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-13_083036\", "3-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-14_140513\", "4-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-15_101019\", "5-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-16_150804\", "6-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-19_084519\", "7-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-22_110842\", "8-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-23_093532\", "9-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-26_095412\", "10-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 3.1\2018-02-27_095219\", "11-AE-Step-3.1", fileNames) _
  , Array(commonAddress & "Step 2.4\2018-01-22_152852\", "12-AE-Step-2.4", fileNames) _
  , Array(commonAddress & "Step 2.5\System 1_150bar\2018-01-22_155848\", "13-AE-Step-2.5", fileNames) _
  , Array(commonAddress & "Step 2.5\System 2_150bar\2018-01-22_163330\", "14-AE-Step-2.5", fileNames) _
  , Array(commonAddress & "Step 1.3\2018-01-18_145856\", "15-AE-Step-1.3", fileNames) _
  , Array(commonAddress & "Step 2.3\2018-01-22_141907\", "16-AE-Step-2.3", fileNames) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Temperatur HP_1 [°C]", "Temp1"
dictVaDiadem.Add "Temperatur HP_2 [°C]", "Temp2"
dictVaDiadem.Add "Druck HP_1 [bar]", "Pres1"
dictVaDiadem.Add "Druck HP_2 [bar]", "Pres2"
dictVaDiadem.Add "Durchfluss HP_1 [l\min]", "VolFlow1"
dictVaDiadem.Add "Durchfluss HP_2 [l\min]", "VolFlow2"
dictVaDiadem.Add "Force Piston Eye HP1 [N]", "ForceEye1"
dictVaDiadem.Add "Force Piston Eye HP2 [N]", "ForceEye2"
dictVaDiadem.Add "Input force [N]", "InputForce"
dictVaDiadem.Add "Laser Steuerventilhebel [mm]", "ValveDispl"
dictVaDiadem.Add "Output force [N]", "OutputForce"
dictVaDiadem.Add "Laser Piston [mm]", "PistonDispl"

newFreq = 100 'Hz'
loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = False 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"
iterators2 = Array(_ 
                    "1-AE-Step-3.1" _
                  , "2-AE-Step-3.1" _
                  , "3-AE-Step-3.1" _
                  , "4-AE-Step-3.1" _
                  , "5-AE-Step-3.1" _
                  , "6-AE-Step-3.1" _
                  , "7-AE-Step-3.1" _
                  , "8-AE-Step-3.1" _
                  , "9-AE-Step-3.1" _
                  , "10-AE-Step-3.1" _
                  , "11-AE-Step-3.1" _
                  , "12-AE-Step-2.4" _
                  , "13-AE-Step-2.5" _
                  , "14-AE-Step-2.5" _
                  , "15-AE-Step-1.3" _
                  , "16-AE-Step-2.3" _
                  )
iterators = Array("16-AE-Step-2.3")
' iterators = Array(18)

signalsToDif = Array("Laser Piston [mm]")
FlagFTData = True

filterFreq = 0.001 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = False
FlagHighPass = False 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False