Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\02_STEPS\csv100\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\02_STEPS\csv100\"

filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms"_
                  , "Durchfluss_HP_1_[l_min].tdms", "Durchfluss_HP_2_[l_min]_.tdms"_
                  , "Piston_eye_1_w_o_offset.tdms", "Piston_eye_2_w_o_offset.tdms" _
                  , "Laser_Piston_[mm].tdms", "Laser_Steuerventilhebel_[mm].tdms"_
                  , "Input_force_[N].tdms", "Input_w_o_offset.tdms", "Input_force_with_offset[N].tdms", "Input_force_w_o_offset.tdms"_
                  , "Output_force_without_offset_[N].tdms", "Output_force_.tdms", "Output_force_w_o_offset.tdms"_
                  , "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

' filesNames = Array("Force_Piston_Eye_HP1_[N].tdms", "Force_Piston_Eye_HP2_[N].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\01_RAW\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "Step 1.1\2018-10-10_144346\", "1-Step-1.1", filesNames) _
  , Array(commonAddress & "Step 1.1 Repeat\2018-10-30_174628\", "29-Step-1.1-Repeat", filesNames) _
  , Array(commonAddress & "Step 1.2\2018-10-11_101715\", "2-Step-1.2", filesNames) _
  , Array(commonAddress & "Step 1.3\2018-10-10_154135\", "3-Step-1.3", filesNames) _
  , Array(commonAddress & "Step 1.3 Repeat\2018-10-30_184444\", "30-Step-1.3-Repeat", filesNames) _
  , Array(commonAddress & "Step 1.4\2018-10-10_144646\", "4-Step-1.4", filesNames) _
  , Array(commonAddress & "Step 1.5\2018-10-11_095700\", "5-Step-1.5", filesNames) _
  , Array(commonAddress & "Step 1.6\2018-10-10_150951\", "6-Step-1.6", filesNames) _
  , Array(commonAddress & "Step 2.4\2018-10-11_102720\", "7-Step-2.4", filesNames) _
  , Array(commonAddress & "Step 2.4 Repeat\2018-10-16_173210\", "11-Step-2.4-Repeat", filesNames) _
  , Array(commonAddress & "Step 2.4 Repeat 2\2018-10-30_175157\", "26-Step-2.4-Repeat2", filesNames) _
  , Array(commonAddress & "Step 2.1\1.5 mm Displacement\2018-10-19_145010\", "8-Step-2.1-1.5Displ", filesNames) _
  , Array(commonAddress & "Step 2.1\Neutral position\2018-10-19_103728\", "9-Step-2.1-NeutralPos", filesNames) _
  , Array(commonAddress & "Step 2.2\2018-10-18_140722\", "10-Step-2.2", filesNames) _
  , Array(commonAddress & "Step 2.5\2018-10-18_151703\", "12-Step-2.5", filesNames) _
  , Array(commonAddress & "Step 2.6 - P1 = 231 bar\2018-10-18_144102\", "13-Step-2.6-1", filesNames) _
  , Array(commonAddress & "Step 2.6 - P2 =231 bar\2018-10-18_142929\", "14-Step-2.6-2", filesNames) _
  , Array(commonAddress & "Step 3.1-1\2018-10-25_090553\", "15-Step-3.1-1", filesNames) _
  , Array(commonAddress & "Step 3.1-1\2018-10-25_165152\", "16-Step-3.1-2", filesNames) _
  , Array(commonAddress & "Step 3.1-2\2018-10-27_105320\", "17-Step-3.1-3", filesNames) _
  , Array(commonAddress & "Step 3.1-2\2018-10-27_180436\", "18-Step-3.1-4", filesNames) _
  , Array(commonAddress & "Step 3.2-1\2018-10-25_191435\", "19-Step-3.2-1", filesNames) _
  , Array(commonAddress & "Step 3.2-1\2018-10-26_064832\", "20-Step-3.2-2", filesNames) _
  , Array(commonAddress & "Step 3.2-2 hot\2018-10-29_181826\", "27-Step-3.2-hot", filesNames) _
  , Array(commonAddress & "Step 3.2-2 cold\2018-10-29_065426\", "28-Step-3.2-cold", filesNames) _
  , Array(commonAddress & "Step 3.3-1\2018-10-26_083917\", "21-Step-3.3-1", filesNames) _
  , Array(commonAddress & "Step 3.3-1\2018-10-26_161229\", "22-Step-3.3-2", filesNames) _
  , Array(commonAddress & "Step 3.4-1\2018-10-26_183222\", "23-Step-3.4-1", filesNames) _
  , Array(commonAddress & "Step 3.4-1\2018-10-27_054821\", "24-Step-3.4-2", filesNames) _
  , Array(commonAddress & "Step 3.4-1\2018-10-27_062515\", "25-Step-3.4-3", filesNames) _
  , Array(commonAddress & "Step 3.7 Part 1\2018-10-30_063221\", "31-Step-3.7-1", filesNames) _
  , Array(commonAddress & "Step 3.7 Part 2\2018-10-30_124303\", "32-Step-3.7-2", filesNames) _
  , Array(commonAddress & "Step 3.1 40 FH\Cold\2018-11-13_143336\", "33-Step-3.1-40FH-cold-1", filesNames) _
  , Array(commonAddress & "Step 3.1 40 FH\Cold\2018-11-14_092019\", "34-Step-3.1-40FH-cold-2", filesNames) _
  , Array(commonAddress & "Step 3.1 40 FH\Hot - 100C\2018-11-14_132712\", "35-Step-3.1-40FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.2 40 FH\Cold\2018-11-14_141248\", "36-Step-3.2-40FH-cold-1", filesNames) _
  , Array(commonAddress & "Step 3.2 40 FH\Cold\2018-11-15_081624\", "37-Step-3.2-40FH-cold-2", filesNames) _
  , Array(commonAddress & "Step 3.2 40 FH\Hot - 100 C\2018-11-15_165240\", "38-Step-3.2-40FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.1 50 FH\Cold\2018-11-16_093714\", "39-Step-3.1-50FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.1 50 FH\Hot - 100 C\2018-11-16_163712\", "40-Step-3.1-50FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.2 50 FH\Cold\2018-11-19_111604\", "41-Step-3.2-50FH-cold-1", filesNames) _
  , Array(commonAddress & "Step 3.2 50 FH\Cold\2018-11-20_084410\", "42-Step-3.2-50FH-cold-2", filesNames) _
  , Array(commonAddress & "Step 3.2 50 FH\Hot - 100 C\2018-11-20_142553\", "43-Step-3.2-50FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.1 60 FH\Cold\2018-11-21_084053\", "44-Step-3.1-60FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.1 60 FH\Hot - 100 C\2018-11-21_154444\", "45-Step-3.1-60FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.2 60 FH\Hot - 100 C\2018-11-23_140033\", "46-Step-3.2-60FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.2 60 FH\Cold\2018-11-22_093727", "47-Step-3.2-60FH-cold1", filesNames) _
  , Array(commonAddress & "Step 3.2 60 FH\Cold\2018-11-23_091202", "48-Step-3.2-60FH-cold2", filesNames) _
  , Array(commonAddress & "Step 3.7 FH 60\2018-11-26_100022", "49-Step-3.7-60FH", filesNames) _
  , Array(commonAddress & "Step 3.7 FH 60\2018-11-29_092228", "50-Step-3.7-60FH", filesNames) _
  , Array(commonAddress & "Step 3.1 70 FH\Cold\2018-12-04_095356", "51-Step-3.1-70FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.1 70 FH\Hot - 100 C\2018-12-04_170225", "52-Step-3.1-70FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.2 70 FH\Cold\2018-12-05_103102", "53-Step-3.2-70FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.2 70 FH\Hot - 100 C\2018-12-05_165158", "54-Step-3.2-70FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.1 80 FH\Cold\2018-12-06_090011", "55-Step-3.1-80FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.1 80 FH\Hot - 100 C\2018-12-06_160724", "56-Step-3.1-80FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.2 80 FH\Cold\2018-12-07_090438", "57-Step-3.2-80FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.2 80 FH\Hot - 100 C\Last 560 cycles\2018-12-07_165612", "58-Step-3.2-80FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.1 90 FH\Cold\2018-12-10_082712", "59-Step-3.1-90FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.1 90 FH\Hot - 100 C\2018-12-10_153438", "60-Step-3.1-90FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.2 FH 90\Cold\2018-12-11_090635", "61-Step-3.2-90FH-cold", filesNames) _
  , Array(commonAddress & "Step 3.2 FH 90\Hot - 100 C\2018-12-11_144937", "62-Step-3.2-90FH-hot", filesNames) _
  , Array(commonAddress & "Step 3.7 FH 90\2018-12-12_081451", "63-Step-3.7-90FH", filesNames) _
  , Array(commonAddress & "Step 3.7 FH 90\2018-12-13_081650", "64-Step-3.7-90FH", filesNames) _
  , Array(commonAddress & "Step 3.1 FH 100\Cold\2018-12-18_094228", "65-Step-3.1-100FH_cold", filesNames) _
  , Array(commonAddress & "Step 3.1 FH 100\Hot - 100 C\2018-12-18_165324", "66-Step-3.1-100FH_hot", filesNames) _
  , Array(commonAddress & "Step 3.2 100 FH\Cold\2018-12-19_090913", "67-Step-3.2-100FH_cold", filesNames) _
  , Array(commonAddress & "Step 3.2 100 FH\Hot - 100 C\2018-12-19_145750", "68-Step-3.2-100FH_hot", filesNames) _
  , Array(commonAddress & "Step 3.1 110 FH\Cold\2019-01-16_071341", "69-Step-3.1-110FH_cold", filesNames) _
  , Array(commonAddress & "Step 3.1 110 FH\Hot - 100 C\2019-01-16_141425", "70-Step-3.1-110FH_hot", filesNames) _
  , Array(commonAddress & "Step 3.2 110 FH\Cold\2019-01-17_104409", "71-Step-3.2-110FH_cold", filesNames) _
  , Array(commonAddress & "Step 3.2 110 FH\Hot - 100 C\2019-01-17_161807", "72-Step-3.2-110FH_hot", filesNames) _
  , Array(commonAddress & "Step 3.1. 120 FH\Cold\2019-01-18_072043", "73-Step-3.1-120FH_cold", filesNames) _
  , Array(commonAddress & "Step 3.1. 120 FH\Hot - 100 C\2019-01-18_142012", "74-Step-3.1-120FH_hot", filesNames) _
  , Array(commonAddress & "Step 3.2 120 FH\Cold\2019-01-22_104802", "75-Step-3.2-120FH_cold_1", filesNames) _
  , Array(commonAddress & "Step 3.2 120 FH\Cold\2019-01-21_145533", "76-Step-3.2-120FH_cold_2", filesNames) _
  , Array(commonAddress & "Step 3.2 120 FH\Hot - 100 C\2019-01-22_141200", "77-Step-3.2-120FH_hot", filesNames) _
  )

' All steps
' 1-Step-1.1,29-Step-1.1-Repeat,2-Step-1.2,3-Step-1.3,30-Step-1.3-Repeat,4-Step-1.4,5-Step-1.5,6-Step-1.6,7-Step-2.4,11-Step-2.4-Repeat,26-Step-2.4-Repeat2,8-Step-2.1-1.5Displ,9-Step-2.1-NeutralPos,10-Step-2.2,12-Step-2.5,13-Step-2.6-1,14-Step-2.6-2,15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,19-Step-3.2-1,20-Step-3.2-2,27-Step-3.2-hot,28-Step-3.2-cold,21-Step-3.3-1,22-Step-3.3-2,23-Step-3.4-1,24-Step-3.4-2,25-Step-3.4-3,31-Step-3.7-1,32-Step-3.7-2,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot,39-Step-3.1-50FH-cold,40-Step-3.1-50FH-hot,41-Step-3.2-50FH-cold-1,42-Step-3.2-50FH-cold-2,43-Step-3.2-50FH-hot,44-Step-3.1-60FH-cold,45-Step-3.1-60FH-hot
' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("12-Step-2.5", "13-Step-2.6-1", "14-Step-2.6-2", "15-Step-3.1-1", "16-Step-3.1-2", "17-Step-3.1-3", "18-Step-3.1-4", "19-Step-3.2-1", "20-Step-3.2-2", "21-Step-3.3-1", "22-Step-3.3-2", "23-Step-3.4-1", "24-Step-3.4-2", "25-Step-3.4-3")
' iterators = Array("15-Step-3.1-1", "16-Step-3.1-2", "17-Step-3.1-3", "18-Step-3.1-4", "19-Step-3.2-1", "20-Step-3.2-2", "21-Step-3.3-1", "22-Step-3.3-2", "23-Step-3.4-1", "24-Step-3.4-2", "25-Step-3.4-3")
' iterators = Array("41-Step-3.2-50FH-cold-1","42-Step-3.2-50FH-cold-2","43-Step-3.2-50FH-hot")
' iterators = Array("44-Step-3.1-60FH-cold", "45-Step-3.1-60FH-hot")
' iterators = Array("46-Step-3.2-60FH-hot", "47-Step-3.2-60FH-cold1", "48-Step-3.2-60FH-cold2")
' iterators = Array("1-Step-1.1", "2-Step-1.2", "3-Step-1.3", "4-Step-1.4", "5-Step-1.5", "6-Step-1.6", "7-Step-2.4")
' iterators = Array("8-Step-2.1-1.5Displ", "9-Step-2.1-NeutralPos")
' iterators = Array("SN002-1.3", "SN002-2.4", "SN0012-1.3", "SN0012-2.4")
' iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08")
iterators2 = Array(_
             "1-Step-1.1" _
            , "29-Step-1.1-Repeat" _
            , "2-Step-1.2" _
            , "3-Step-1.3" _
            , "30-Step-1.3-Repeat" _
            , "4-Step-1.4" _
            , "5-Step-1.5" _
            , "6-Step-1.6" _
            , "7-Step-2.4" _
            , "11-Step-2.4-Repeat" _
            , "26-Step-2.4-Repeat2" _
            , "8-Step-2.1-1.5Displ" _
            , "9-Step-2.1-NeutralPos" _
            , "10-Step-2.2" _
            , "12-Step-2.5" _
            , "13-Step-2.6-1" _
            , "14-Step-2.6-2" _
            , "15-Step-3.1-1" _
            , "16-Step-3.1-2" _
            , "17-Step-3.1-3" _
            , "18-Step-3.1-4" _
            , "19-Step-3.2-1" _
            , "20-Step-3.2-2" _
            , "27-Step-3.2-hot" _
            , "28-Step-3.2-cold" _
            , "21-Step-3.3-1" _
            , "22-Step-3.3-2" _
            , "23-Step-3.4-1" _
            , "24-Step-3.4-2" _
            , "25-Step-3.4-3" _
            , "31-Step-3.7-1" _
            , "32-Step-3.7-2" _
            , "33-Step-3.1-40FH-cold-1" _
            , "34-Step-3.1-40FH-cold-2" _
            , "35-Step-3.1-40FH-hot" _
            , "36-Step-3.2-40FH-cold-1" _
            , "37-Step-3.2-40FH-cold-2" _
            , "38-Step-3.2-40FH-hot" _
            , "39-Step-3.1-50FH-cold" _
            , "40-Step-3.1-50FH-hot" _
            , "41-Step-3.2-50FH-cold-1" _
            , "42-Step-3.2-50FH-cold-2" _
            , "43-Step-3.2-50FH-hot" _
            , "44-Step-3.1-60FH-cold" _
            , "45-Step-3.1-60FH-hot" _
            , "46-Step-3.2-60FH-hot" _
            , "47-Step-3.2-60FH-cold1" _
            , "48-Step-3.2-60FH-cold2" _
            , "49-Step-3.7-60FH" _
            , "50-Step-3.7-60FH" _
            , "51-Step-3.1-70FH-cold" _
            , "52-Step-3.1-70FH-hot" _
            , "53-Step-3.2-70FH-cold" _
            , "54-Step-3.2-70FH-hot" _
            , "55-Step-3.1-80FH-cold" _
            , "56-Step-3.1-80FH-hot" _
            , "57-Step-3.2-80FH-cold" _
            , "58-Step-3.2-80FH-hot" _
            , "59-Step-3.1-90FH-cold" _
            , "60-Step-3.1-90FH-hot" _
            , "63-Step-3.7-90FH" _
            , "64-Step-3.7-90FH" _
            , "65-Step-3.1-100FH_cold" _
            , "66-Step-3.1-100FH_hot" _
            , "67-Step-3.2-100FH_cold" _
            , "68-Step-3.2-100FH_hot" _
            , "69-Step-3.1-110FH_cold" _
            , "70-Step-3.1-110FH_hot" _
            , "71-Step-3.2-110FH_cold"_
            , "72-Step-3.2-110FH_hot"_
            , "73-Step-3.1-120FH_cold"_
            , "74-Step-3.1-120FH_hot"_
            , "75-Step-3.2-120FH_cold_1"_
            , "76-Step-3.2-120FH_cold_2"_
            , "77-Step-3.2-120FH_hot"_
            )

' iterators = Array("57-Step-3.2-80FH-cold", "58-Step-3.2-80FH-hot", "59-Step-3.1-90FH-cold", "60-Step-3.1-90FH-hot")
iterators = Array(_
              "71-Step-3.2-110FH_cold"_
            , "72-Step-3.2-110FH_hot"_
            , "73-Step-3.1-120FH_cold"_
            , "74-Step-3.1-120FH_hot"_
            , "75-Step-3.2-120FH_cold_1"_
            , "76-Step-3.2-120FH_cold_2"_
            , "77-Step-3.2-120FH_hot"_
            )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Druck HP_1 [bar]", "Pres1"
dictVaDiadem.Add "Druck HP_2 [bar]", "Pres2"
dictVaDiadem.Add "Durchfluss HP_1 [l\min]", "VolFlow1"
dictVaDiadem.Add "Durchfluss HP_2 [l\min]", "VolFlow2"
dictVaDiadem.Add "Force Piston Eye HP1 [N]", "ForceEye1"
dictVaDiadem.Add "Force Piston Eye HP2 [N]", "ForceEye2"

dictVaDiadem.Add "Piston eye 1 w\o offset", "ForceEyeCal1"
dictVaDiadem.Add "Piston eye 2 w\o offset", "ForceEyeCal2"

dictVaDiadem.Add "Input force [N]", "InputForce"
dictVaDiadem.Add "Input force with offset[N]", "InputForce" 'Step 1
dictVaDiadem.Add "Input w\o offset", "InputForce" 'Step 8,9'
dictVaDiadem.Add "Input force w\o offset", "InputForce" 'Step 8,9'
dictVaDiadem.Add "Laser Piston [mm]", "PistonDispl"
dictVaDiadem.Add "Laser Steuerventilhebel [mm]", "ValveDispl"
dictVaDiadem.Add "Output force without offset [N]", "OutputForce"
dictVaDiadem.Add "Output force", "OutputForce"
dictVaDiadem.Add "Output force w\o offset", "OutputForce" 'Step 8,9'
dictVaDiadem.Add "Temperatur HP_1 [°C]", "Temp1"
dictVaDiadem.Add "Temperatur HP_2 [°C]", "Temp2"

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