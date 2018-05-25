Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0164\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0164\01_TDMS_data_Set-complete\02_STEPS\csv_data\"


' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0164\01_TDMS_data_Set-complete\02_STEPS\raw_split\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress , "01", Array("raw__step01.TDM")) _
  ,  Array(commonAddress , "02", Array("raw__step02.TDM")) _
  ,  Array(commonAddress , "03", Array("raw__step03.TDM")) _
  ,  Array(commonAddress , "04", Array("raw__step04.TDM")) _
  ,  Array(commonAddress , "05", Array("raw__step05.TDM")) _
  ,  Array(commonAddress , "06", Array("raw__step06.TDM")) _
  ,  Array(commonAddress , "07", Array("raw__step07.TDM")) _
  ,  Array(commonAddress , "08", Array("raw__step08.TDM")) _
  ,  Array(commonAddress , "09", Array("raw__step09.TDM")) _
  ,  Array(commonAddress , "10", Array("raw__step10.TDM")) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Pitch link main [N]_Mean", "PitchLinkMain"
' dictVaDiadem.Add "Inner pitch link [N]_Mean", "PitchLinkFlexible"

newFreq = 100 'Hz'

loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = False 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"
' iterators = Array("01","02","03","04","05","06","07","08","09","10")
iterators = Array("01")
' iterators = Array("19","20")
' iterators = Array("1311")

' filterFreq = 0.001 'Hz'
filterFreq = 1.0 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = True
FlagHighPass = False 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False