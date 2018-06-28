Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0159\06_Dat_Analysis\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0159\06_Dat_Analysis\"


' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0159\Recorded Data\Fatigue Test\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress +"fti_2018-03-01_115223\", "01", Array("fti_2018-03-01_115223.tdms")) _
  , Array(commonAddress +"fti_2018-03-01_151305\", "02", Array("fti_2018-03-01_151305.tdms")) _
  , Array(commonAddress +"fti_2018-03-01_164524\", "03", Array("fti_2018-03-01_164524.tdms")) _
  , Array(commonAddress +"fti_2018-03-02_082047\", "04", Array("fti_2018-03-02_082047.tdms")) _
  , Array(commonAddress +"fti_2018-03-02_102428\", "05", Array("fti_2018-03-02_102428.tdms")) _
  , Array(commonAddress +"fti_2018-03-02_131228\", "06", Array("fti_2018-03-02_131228.tdms")) _
  , Array(commonAddress +"fti_2018-03-02_150017\", "07", Array("fti_2018-03-02_150017.tdms")) _
  , Array(commonAddress +"fti_2018-03-02_155825\", "08", Array("fti_2018-03-02_155825.tdms")) _
  , Array(commonAddress +"fti_2018-03-05_081439\", "09", Array("fti_2018-03-05_081439.tdms")) _
  , Array(commonAddress +"fti_2018-03-05_100103\", "10", Array("fti_2018-03-05_100103.tdms")) _
  , Array(commonAddress +"fti_2018-03-05_121259\", "11", Array("fti_2018-03-05_121259.tdms")) _
  , Array(commonAddress +"fti_2018-03-05_150751\", "12", Array("fti_2018-03-05_150751.tdms")) _
  , Array(commonAddress +"fti_2018-03-06_084300\", "13", Array("fti_2018-03-06_084300.tdms")) _
  , Array(commonAddress +"fti_2018-03-06_102802\", "14", Array("fti_2018-03-06_102802.tdms")) _
  , Array(commonAddress +"fti_2018-03-07_100109\", "15", Array("fti_2018-03-07_100109.tdms")) _
  , Array(commonAddress +"fti_2018-03-07_115628\", "16", Array("fti_2018-03-07_115628.tdms")) _
  , Array(commonAddress +"fti_2018-03-07_135950\", "17", Array("fti_2018-03-07_135950.tdms")) _
  , Array(commonAddress +"fti_2018-03-07_165039\", "18", Array("fti_2018-03-07_165039.tdms")) _
  , Array(commonAddress +"fti_2018-03-08_080650\", "19", Array("fti_2018-03-08_080650.tdms")) _
  , Array(commonAddress +"fti_2018-03-08_110047\", "20", Array("fti_2018-03-08_110047.tdms")) _
  , Array(commonAddress +"fti_2018-03-08_143940\", "21", Array("fti_2018-03-08_143940.tdms")) _
  , Array(commonAddress +"fti_2018-03-08_170647\", "22", Array("fti_2018-03-08_170647.tdms")) _
  , Array(commonAddress +"fti_2018-03-08_184324\", "23", Array("fti_2018-03-08_184324.tdms")) _
  , Array(commonAddress +"fti_2018-03-09_092304\", "24", Array("fti_2018-03-09_092304.tdms")) _
  , Array(commonAddress +"fti_2018-03-09_115338\", "25", Array("fti_2018-03-09_115338.tdms")) _
  , Array(commonAddress +"fti_2018-03-09_143115\", "26", Array("fti_2018-03-09_143115.tdms")) _
  , Array(commonAddress +"fti_2018-03-12_094552\", "27", Array("fti_2018-03-12_094552.tdms")) _
  , Array(commonAddress +"fti_2018-03-12_103634\", "28", Array("fti_2018-03-12_103634.tdms")) _
  )

' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("1312")
' iterators = Array("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
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
' dictVaDiadem.Add "Steer_Rod blue", "SteerRodblue"
' dictVaDiadem.Add "Steer_Rod gold", "SteerRodgold"
' dictVaDiadem.Add "Steer_Rod black", "SteerRodblack"
' dictVaDiadem.Add "Booster Link long", "BoosterLinklong"
' dictVaDiadem.Add "Booster Link col", "BoosterLinkcol"
' dictVaDiadem.Add "Booster Link lat", "BoosterLinklat"
dictVaDiadem.Add "Holder right", "HolderRight"
' dictVaDiadem.Add "COLL_Position", "COLLPosition"
' dictVaDiadem.Add "LONG_Position", "LONGPosition"
' dictVaDiadem.Add "LAT_Position", "LATPosition"
' dictVaDiadem.Add "Zykluszaehler Fatigue (MU)", "NumberCycles"

newFreq = 200 'Hz'

loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = False 'possible values: True or False

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