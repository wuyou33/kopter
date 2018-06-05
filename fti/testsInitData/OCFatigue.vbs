Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0168\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0168\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

variables = Array("Tension_[N].tdms", "Bending_[N].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0168\01_TDMS_data_Set-complete\01_RAW\STG data\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "2018-03-08_161931\" , "06", variables) _
  ,  Array(commonAddress & "2018-03-08_164810\" , "07", variables) _
  ,  Array(commonAddress & "2018-03-09_161519\" , "08", variables) _
  ,  Array(commonAddress & "2018-03-12_152310\" , "10", variables) _
  ,  Array(commonAddress & "2018-03-13_160750\" , "12", variables) _
  ,  Array(commonAddress & "2018-03-14_161001\" , "13", variables) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Tension [N]", "Tension"
dictVaDiadem.Add "Bending [N]", "Bending"

newFreq = 100 'Hz'

loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"
' iterators = Array("01","02","03","04","05","06","07","08","09","10")
iterators = Array("06", "07", "08", "10", "12", "13")
' iterators = Array("19","20")
' iterators = Array("1311")

' filterFreq = 0.001 'Hz'
filterFreq = 0.1 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = True
FlagHighPass = True 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False