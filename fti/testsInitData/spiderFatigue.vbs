Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0173\01_TDMS_data_Set-complete\02_STEPS\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0173\01_TDMS_data_Set-complete\02_STEPS\csv_data\"

variables = Array("Force_TR_Pitch_Link_SN27_[N].tdms", "Force_TR_Pitch_Link_SN28_[N].tdms", "Spider_arm_strain_[mm_m].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0173\01_TDMS_data_Set-complete\01_RAW\STG data\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "2018-03-15_160755\" , "07", variables) _
  ,  Array(commonAddress & "2018-03-15_190301\" , "08", variables) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Force TR Pitch Link SN27 [N]", "Force-SN27"
dictVaDiadem.Add "Force TR Pitch Link SN28 [N]", "Force-SN28"
dictVaDiadem.Add "Spider arm strain [mm\m]", "SpiderStrain"

newFreq = 100 'Hz'

loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = True 'possible values: True or False
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"
' iterators = Array("01","02","03","04","05","06","07","08","09","10")
iterators = Array("07", "08")
' iterators = Array("19","20")
' iterators = Array("1311")

' filterFreq = 0.001 'Hz'
filterFreq = 0.1 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = True
FlagHighPass = False 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False