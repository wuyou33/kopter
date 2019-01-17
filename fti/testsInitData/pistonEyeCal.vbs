Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "P:\11_J67\16_FTI\pistonEyeCal\"

' Where the data will be saved in csv format
csvFolder = "P:\11_J67\16_FTI\pistonEyeCal\"

filesNames = Array(   "TR Actuator Force_0.tdms"_
                    , "TR Actuator Force_1.tdms"_
                    , "TR Actuator Force_2.tdms"_
                    , "TR Actuator Force_3.tdms"_
                    , "TR Actuator Force_4.tdms"_
                    , "TR Actuator Force_5.tdms"_
                    , "TR Actuator Force_6.tdms"_
                    , "TR Actuator Force_7.tdms"_
                    , "TR Actuator Force_8.tdms"_
                    , "TR Actuator Force_9.tdms"_
                    , "TR Actuator Force_10.tdms"_
                    , "TR Actuator Force_11.tdms"_
                    , "TR Actuator Force_12.tdms"_
                    )

' filesNames = Array("Force_Piston_Eye_HP1_[N].tdms", "Force_Piston_Eye_HP2_[N].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH\13_Testing+Instrumentation\FTI\18_Calibration\AB_P3\2018_04_26_Yaw actuator force\1200-1033063-AA SN5 (blue wire)\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "Tension\Run 1\", "1-Tension1_0", Array("TR Actuator Force_0.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "2-Tension1_1", Array("TR Actuator Force_1.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "3-Tension1_2", Array("TR Actuator Force_2.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "4-Tension1_3", Array("TR Actuator Force_3.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "5-Tension1_4", Array("TR Actuator Force_4.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "6-Tension1_5", Array("TR Actuator Force_5.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "7-Tension1_6", Array("TR Actuator Force_6.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "8-Tension1_7", Array("TR Actuator Force_7.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "9-Tension1_8", Array("TR Actuator Force_8.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "10-Tension1_9", Array("TR Actuator Force_9.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "11-Tension1_10", Array("TR Actuator Force_10.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "12-Tension1_11", Array("TR Actuator Force_11.tdms")) _
  , Array(commonAddress & "Tension\Run 1\", "13-Tension1_12", Array("TR Actuator Force_12.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "14-Tension2_0", Array("TR Actuator Force_0.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "15-Tension2_1", Array("TR Actuator Force_1.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "16-Tension2_2", Array("TR Actuator Force_2.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "17-Tension2_3", Array("TR Actuator Force_3.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "18-Tension2_4", Array("TR Actuator Force_4.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "19-Tension2_5", Array("TR Actuator Force_5.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "20-Tension2_6", Array("TR Actuator Force_6.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "21-Tension2_7", Array("TR Actuator Force_7.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "22-Tension2_8", Array("TR Actuator Force_8.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "23-Tension2_9", Array("TR Actuator Force_9.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "24-Tension2_10", Array("TR Actuator Force_10.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "25-Tension2_11", Array("TR Actuator Force_11.tdms")) _
  , Array(commonAddress & "Tension\Run 2\", "26-Tension2_12", Array("TR Actuator Force_12.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "27-Compression1_0", Array("TR Actuator Force_0.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "28-Compression1_1", Array("TR Actuator Force_1.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "29-Compression1_2", Array("TR Actuator Force_2.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "30-Compression1_3", Array("TR Actuator Force_3.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "31-Compression1_4", Array("TR Actuator Force_4.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "32-Compression1_5", Array("TR Actuator Force_5.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "33-Compression1_6", Array("TR Actuator Force_6.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "34-Compression1_7", Array("TR Actuator Force_7.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "35-Compression1_8", Array("TR Actuator Force_8.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "36-Compression1_9", Array("TR Actuator Force_9.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "37-Compression1_10", Array("TR Actuator Force_10.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "38-Compression1_11", Array("TR Actuator Force_11.tdms")) _
  , Array(commonAddress & "Compression\Run 1\", "39-Compression1_12", Array("TR Actuator Force_12.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "40-Compression2_0", Array("TR Actuator Force_0.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "41-Compression2_1", Array("TR Actuator Force_1.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "42-Compression2_2", Array("TR Actuator Force_2.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "43-Compression2_3", Array("TR Actuator Force_3.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "44-Compression2_4", Array("TR Actuator Force_4.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "45-Compression2_5", Array("TR Actuator Force_5.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "46-Compression2_6", Array("TR Actuator Force_6.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "47-Compression2_7", Array("TR Actuator Force_7.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "48-Compression2_8", Array("TR Actuator Force_8.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "49-Compression2_9", Array("TR Actuator Force_9.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "50-Compression2_10", Array("TR Actuator Force_10.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "51-Compression2_11", Array("TR Actuator Force_11.tdms")) _
  , Array(commonAddress & "Compression\Run 2\", "52-Compression2_12", Array("TR Actuator Force_12.tdms")) _
)

' All steps
' 1-Step-1.1,29-Step-1.1-Repeat,2-Step-1.2,3-Step-1.3,30-Step-1.3-Repeat,4-Step-1.4,5-Step-1.5,6-Step-1.6,7-Step-2.4,11-Step-2.4-Repeat,26-Step-2.4-Repeat2,8-Step-2.1-1.5Displ,9-Step-2.1-NeutralPos,10-Step-2.2,12-Step-2.5,13-Step-2.6-1,14-Step-2.6-2,15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,19-Step-3.2-1,20-Step-3.2-2,27-Step-3.2-hot,28-Step-3.2-cold,21-Step-3.3-1,22-Step-3.3-2,23-Step-3.4-1,24-Step-3.4-2,25-Step-3.4-3,31-Step-3.7-1,32-Step-3.7-2,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot,39-Step-3.1-50FH-cold,40-Step-3.1-50FH-hot,41-Step-3.2-50FH-cold-1,42-Step-3.2-50FH-cold-2,43-Step-3.2-50FH-hot,44-Step-3.1-60FH-cold,45-Step-3.1-60FH-hot
' The variable iterators is used to load and operate only selected steps from above

' iterators = Array("57-Step-3.2-80FH-cold", "58-Step-3.2-80FH-hot", "59-Step-3.1-90FH-cold", "60-Step-3.1-90FH-hot")
' iterators = Array("1-LOWTEMP_Step_1.2", "2-LOWTEMP_Step_1.1", "3-LOWTEMP_Step_1.2")
iterators = Array(_
              "1-Tension1_0"_
            , "2-Tension1_1"_
            , "3-Tension1_2"_
            , "4-Tension1_3"_
            , "5-Tension1_4"_
            , "6-Tension1_5"_
            , "7-Tension1_6"_
            , "8-Tension1_7"_
            , "9-Tension1_8"_
            , "10-Tension1_9"_
            , "11-Tension1_10"_
            , "12-Tension1_11"_
            , "13-Tension1_12"_
            , "14-Tension2_0"_
            , "15-Tension2_1"_
            , "16-Tension2_2"_
            , "17-Tension2_3"_
            , "18-Tension2_4"_
            , "19-Tension2_5"_
            , "20-Tension2_6"_
            , "21-Tension2_7"_
            , "22-Tension2_8"_
            , "23-Tension2_9"_
            , "24-Tension2_10"_
            , "25-Tension2_11"_
            , "26-Tension2_12"_
            , "27-Compression1_0"_
            , "28-Compression1_1"_
            , "29-Compression1_2"_
            , "30-Compression1_3"_
            , "31-Compression1_4"_
            , "32-Compression1_5"_
            , "33-Compression1_6"_
            , "34-Compression1_7"_
            , "35-Compression1_8"_
            , "36-Compression1_9"_
            , "37-Compression1_10"_
            , "38-Compression1_11"_
            , "39-Compression1_12"_
            , "40-Compression2_0"_
            , "41-Compression2_1"_
            , "42-Compression2_2"_
            , "43-Compression2_3"_
            , "44-Compression2_4"_
            , "45-Compression2_5"_
            , "46-Compression2_6"_
            , "47-Compression2_7"_
            , "48-Compression2_8"_
            , "49-Compression2_9"_
            , "50-Compression2_10"_
            , "51-Compression2_11"_
            , "52-Compression2_12"_
)

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Load Cell", "Force"
dictVaDiadem.Add "STG", "STG"

newFreq = 100 'Hz'

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