Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
' workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_29012019\"

' Where the data will be saved in csv format
' csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_29012019\"

' filesNames = Array("Force_Piston_Eye_HP1_[N].tdms", "Force_Piston_Eye_HP2_[N].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0249\01_Data\2019_01_29_PistonEye_Actuator_SN24\"
fileNamesBigArrayFolders = Array( _
     Array(commonAddress & "Compression\Compression 1\", "1-PE24_Compression1_0", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "2-PE24_Compression1_1", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "3-PE24_Compression1_2", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "4-PE24_Compression1_3", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "5-PE24_Compression1_4", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "6-PE24_Compression1_5", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "7-PE24_Compression1_6", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "8-PE24_Compression1_7", Array("Piston eye _7.tdms", "Piston eye_7.tdms", "Piston Eye _7.tdms", "Piston Eye_7.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "9-PE24_Compression1_8", Array("Piston eye _8.tdms", "Piston eye_8.tdms", "Piston Eye _8.tdms", "Piston Eye_8.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "10-PE24_Compression1_9", Array("Piston eye _9.tdms", "Piston eye_9.tdms", "Piston Eye _9.tdms", "Piston Eye_9.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "11-PE24_Compression1_10", Array("Piston eye _10.tdms", "Piston eye_10.tdms", "Piston Eye _10.tdms", "Piston Eye_10.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "12-PE24_Compression1_11", Array("Piston eye _11.tdms", "Piston eye_11.tdms", "Piston Eye _11.tdms", "Piston Eye_11.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 1\", "13-PE24_Compression1_12", Array("Piston eye _12.tdms", "Piston eye_12.tdms", "Piston Eye _12.tdms", "Piston Eye_12.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "14-PE24_Compression2_0", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "15-PE24_Compression2_1", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "16-PE24_Compression2_2", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "17-PE24_Compression2_3", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "18-PE24_Compression2_4", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "19-PE24_Compression2_5", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "20-PE24_Compression2_6", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "21-PE24_Compression2_7", Array("Piston eye _7.tdms", "Piston eye_7.tdms", "Piston Eye _7.tdms", "Piston Eye_7.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "22-PE24_Compression2_8", Array("Piston eye _8.tdms", "Piston eye_8.tdms", "Piston Eye _8.tdms", "Piston Eye_8.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "23-PE24_Compression2_9", Array("Piston eye _9.tdms", "Piston eye_9.tdms", "Piston Eye _9.tdms", "Piston Eye_9.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "24-PE24_Compression2_10", Array("Piston eye _10.tdms", "Piston eye_10.tdms", "Piston Eye _10.tdms", "Piston Eye_10.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "25-PE24_Compression2_11", Array("Piston eye _11.tdms", "Piston eye_11.tdms", "Piston Eye _11.tdms", "Piston Eye_11.tdms")) _
  ,  Array(commonAddress & "Compression\Compression 2\", "26-PE24_Compression2_12", Array("Piston eye _12.tdms", "Piston eye_12.tdms", "Piston Eye _12.tdms", "Piston Eye_12.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "27-PE24_Tension1_0", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "28-PE24_Tension1_1", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "29-PE24_Tension1_2", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "30-PE24_Tension1_3", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "31-PE24_Tension1_4", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "32-PE24_Tension1_5", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "33-PE24_Tension1_6", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "34-PE24_Tension1_7", Array("Piston eye _7.tdms", "Piston eye_7.tdms", "Piston Eye _7.tdms", "Piston Eye_7.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "35-PE24_Tension1_8", Array("Piston eye _8.tdms", "Piston eye_8.tdms", "Piston Eye _8.tdms", "Piston Eye_8.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "36-PE24_Tension1_9", Array("Piston eye _9.tdms", "Piston eye_9.tdms", "Piston Eye _9.tdms", "Piston Eye_9.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "37-PE24_Tension1_10", Array("Piston eye _10.tdms", "Piston eye_10.tdms", "Piston Eye _10.tdms", "Piston Eye_10.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "38-PE24_Tension1_11", Array("Piston eye _11.tdms", "Piston eye_11.tdms", "Piston Eye _11.tdms", "Piston Eye_11.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 1\", "39-PE24_Tension1_12", Array("Piston eye _12.tdms", "Piston eye_12.tdms", "Piston Eye _12.tdms", "Piston Eye_12.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "40-PE24_Tension2_0", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "41-PE24_Tension2_1", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "42-PE24_Tension2_2", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "43-PE24_Tension2_3", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "44-PE24_Tension2_4", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "45-PE24_Tension2_5", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "46-PE24_Tension2_6", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "47-PE24_Tension2_7", Array("Piston eye _7.tdms", "Piston eye_7.tdms", "Piston Eye _7.tdms", "Piston Eye_7.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "48-PE24_Tension2_8", Array("Piston eye _8.tdms", "Piston eye_8.tdms", "Piston Eye _8.tdms", "Piston Eye_8.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "49-PE24_Tension2_9", Array("Piston eye _9.tdms", "Piston eye_9.tdms", "Piston Eye _9.tdms", "Piston Eye_9.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "50-PE24_Tension2_10", Array("Piston eye _10.tdms", "Piston eye_10.tdms", "Piston Eye _10.tdms", "Piston Eye_10.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "51-PE24_Tension2_11", Array("Piston eye _11.tdms", "Piston eye_11.tdms", "Piston Eye _11.tdms", "Piston Eye_11.tdms")) _
  ,  Array(commonAddress & "Tension\Tension 2\", "52-PE24_Tension2_12", Array("Piston eye _12.tdms", "Piston eye_12.tdms", "Piston Eye _12.tdms", "Piston Eye_12.tdms")) _
)

' All steps
' 1-Step-1.1,29-Step-1.1-Repeat,2-Step-1.2,3-Step-1.3,30-Step-1.3-Repeat,4-Step-1.4,5-Step-1.5,6-Step-1.6,7-Step-2.4,11-Step-2.4-Repeat,26-Step-2.4-Repeat2,8-Step-2.1-1.5Displ,9-Step-2.1-NeutralPos,10-Step-2.2,12-Step-2.5,13-Step-2.6-1,14-Step-2.6-2,15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,19-Step-3.2-1,20-Step-3.2-2,27-Step-3.2-hot,28-Step-3.2-cold,21-Step-3.3-1,22-Step-3.3-2,23-Step-3.4-1,24-Step-3.4-2,25-Step-3.4-3,31-Step-3.7-1,32-Step-3.7-2,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot,39-Step-3.1-50FH-cold,40-Step-3.1-50FH-hot,41-Step-3.2-50FH-cold-1,42-Step-3.2-50FH-cold-2,43-Step-3.2-50FH-hot,44-Step-3.1-60FH-cold,45-Step-3.1-60FH-hot
' The variable iterators is used to load and operate only selected steps from above

' iterators = Array("57-Step-3.2-80FH-cold", "58-Step-3.2-80FH-hot", "59-Step-3.1-90FH-cold", "60-Step-3.1-90FH-hot")
' iterators = Array("1-LOWTEMP_Step_1.2", "2-LOWTEMP_Step_1.1", "3-LOWTEMP_Step_1.2")
iterators = Array(_
               "1-PE24_Compression1_0"_
             , "2-PE24_Compression1_1"_
             , "3-PE24_Compression1_2"_
             , "4-PE24_Compression1_3"_
             , "5-PE24_Compression1_4"_
             , "6-PE24_Compression1_5"_
             , "7-PE24_Compression1_6"_
             , "8-PE24_Compression1_7"_
             , "9-PE24_Compression1_8"_
             , "10-PE24_Compression1_9"_
             , "11-PE24_Compression1_10"_
             , "12-PE24_Compression1_11"_
             , "13-PE24_Compression1_12"_
             , "14-PE24_Compression2_0"_
             , "15-PE24_Compression2_1"_
             , "16-PE24_Compression2_2"_
             , "17-PE24_Compression2_3"_
             , "18-PE24_Compression2_4"_
             , "19-PE24_Compression2_5"_
             , "20-PE24_Compression2_6"_
             , "21-PE24_Compression2_7"_
             , "22-PE24_Compression2_8"_
             , "23-PE24_Compression2_9"_
             , "24-PE24_Compression2_10"_
             , "25-PE24_Compression2_11"_
             , "26-PE24_Compression2_12"_
             , "27-PE24_Tension1_0"_
             , "28-PE24_Tension1_1"_
             , "29-PE24_Tension1_2"_
             , "30-PE24_Tension1_3"_
             , "31-PE24_Tension1_4"_
             , "32-PE24_Tension1_5"_
             , "33-PE24_Tension1_6"_
             , "34-PE24_Tension1_7"_
             , "35-PE24_Tension1_8"_
             , "36-PE24_Tension1_9"_
             , "37-PE24_Tension1_10"_
             , "38-PE24_Tension1_11"_
             , "39-PE24_Tension1_12"_
             , "40-PE24_Tension2_0"_
             , "41-PE24_Tension2_1"_
             , "42-PE24_Tension2_2"_
             , "43-PE24_Tension2_3"_
             , "44-PE24_Tension2_4"_
             , "45-PE24_Tension2_5"_
             , "46-PE24_Tension2_6"_
             , "47-PE24_Tension2_7"_
             , "48-PE24_Tension2_8"_
             , "49-PE24_Tension2_9"_
             , "50-PE24_Tension2_10"_
             , "51-PE24_Tension2_11"_
             , "52-PE24_Tension2_12"_
)

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Load Cell", "Force"
dictVaDiadem.Add "STG", "STG"

newFreq = 5000 'Hz'

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

FlagFilteredData = False
FlagHighPass = True 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False