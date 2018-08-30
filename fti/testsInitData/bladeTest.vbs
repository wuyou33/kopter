Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0207\TEST\02_Data_set-reduced\01_STEPS\csv\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0207\TEST\02_Data_set-reduced\01_STEPS\csv\"


' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0207\TEST\02_Data_set-reduced\01_STEPS"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "\", "01", Array("TRB SN16 - Step1.TDM")) _
    Array(commonAddress & "\", "02", Array("TRB SN16 - Step 2.TDM")) _
    Array(commonAddress & "\", "03", Array("TRB SN16 - Step 3.TDM")) _
  )

' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("1312")
' iterators = Array("1201","1202","1203","1204","1205","1206","1207","1208","1209","1210","1301","1302","1303","1304","1305","1306","1307","1308","1309","1310")',"1311","1312"'
iterators = Array("01","02", "03")
' iterators = Array("19","20")

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Temp-Sens 1", "Temp1"
dictVaDiadem.Add "Temp-Sens 2", "Temp2"
dictVaDiadem.Add "Temp-Sens 3", "Temp3"
dictVaDiadem.Add "Pressure side w\o offset (mV\V)_Mean", "PressureSide"
dictVaDiadem.Add "Suction side w\o offset (mV\V)_Mean", "SuctionSide"
dictVaDiadem.Add "TRB flap (My) w\o offset (mV\V)_Mean", "My"
dictVaDiadem.Add "TRB Lead-Lag (Mz) w\o offset (mV\V)_Mean", "Mz"
dictVaDiadem.Add "TRB Torsion (Mx) w\o offset (mV\V)_Mean", "Tor"

newFreq = 100 'Hz'

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