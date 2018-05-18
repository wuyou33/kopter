Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P2-J17-03-BT0058\Step 3.1.1\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P2-J17-03-BT0058\Step 3.1.1\csv_data\"

' Names of the files that require to be imported from each of the files, fileName.tdms
fileNames = Array(_
                    "Brücke_(V_V).tdms" _
                  , "Druck_HP_1.tdms" _
                  , "Druck_HP_2.tdms" _
                  , "Durchfluss_HP1.tdms" _
                  , "Durchfluss_HP2.tdms" _
                  , "Laser_Piston.tdms" _
                  , "Laser_Steuerventilhebel.tdms" _
                  , "Temperatur_HP_1.tdms" _
                  , "Temperatur_HP_2.tdms" _
                  )


' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P2-J17-03-BT0058\Step 3.1.1\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "03_03_2016_155352\", "01", fileNames) _
  , Array(commonAddress & "07_03_2016_093302\", "02", fileNames) _
  , Array(commonAddress & "11_02_2016_154031\", "03", fileNames) _
  , Array(commonAddress & "15_02_2016_111414\", "04", fileNames) _
  , Array(commonAddress & "16_02_2016_170542\", "05", fileNames) _
  , Array(commonAddress & "25_02_2016_104752\", "06", fileNames) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Input Force", "InputForce"
dictVaDiadem.Add "Output Force", "OutputForce"
dictVaDiadem.Add "Druck HP_1", "DruckHP1"
dictVaDiadem.Add "Druck HP_2", "DruckHP2"
dictVaDiadem.Add "Durchfluss HP1", "DurchflussHP1"
dictVaDiadem.Add "Durchfluss HP2", "DurchflussHP2"
dictVaDiadem.Add "Laser Piston", "LaserPiston"
dictVaDiadem.Add "Laser Steuerventilhebel", "LaserSteuerventilhebel"
dictVaDiadem.Add "Temperatur HP_1", "TemperaturHP1"
dictVaDiadem.Add "Temperatur HP_2", "TemperaturHP2"


newFreq = 100 'Hz'
loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = True 'possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"
iterators = Array("01","03","04","06")
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