Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\02_STEPS\csv100\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\02_STEPS\csv100\"

filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
                  , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
                  , "Force_Piston_Eye_HP2_[N].tdms", "Laser_Piston_[mm].tdms", "Laser_Steuerventilhebel_[mm].tdms"_
                  , "Input_force_[N].tdms", "Input_w_o_offset.tdms", "Input_force_with_offset[N].tdms", "Input_force_w_o_offset.tdms"_
                  , "Output_force_without_offset_[N].tdms", "Output_force_.tdms", "Output_force_w_o_offset.tdms"_
                  , "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

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
  , Array(commonAddress & "Step3.1-2\2018-10-27_105320\", "17-Step-3.1-3", filesNames) _
  , Array(commonAddress & "Step3.1-2\2018-10-27_180436\", "18-Step-3.1-4", filesNames) _
  , Array(commonAddress & "Step3.2-1\2018-10-25_191435\", "19-Step-3.2-1", filesNames) _
  , Array(commonAddress & "Step3.2-1\2018-10-26_064832\", "20-Step-3.2-2", filesNames) _
  , Array(commonAddress & "Step 3.2-2 hot\2018-10-29_181826\", "27-Step-3.2-hot", filesNames) _
  , Array(commonAddress & "Step 3.2-2 cold\2018-10-29_065426\", "28-Step-3.2-cold", filesNames) _
  , Array(commonAddress & "Step3.3-1\2018-10-26_083917\", "21-Step-3.3-1", filesNames) _
  , Array(commonAddress & "Step3.3-1\2018-10-26_161229\", "22-Step-3.3-2", filesNames) _
  , Array(commonAddress & "Step3.4-1\2018-10-26_183222\", "23-Step-3.4-1", filesNames) _
  , Array(commonAddress & "Step3.4-1\2018-10-27_054821\", "24-Step-3.4-2", filesNames) _
  , Array(commonAddress & "Step3.4-1\2018-10-27_062515\", "25-Step-3.4-3", filesNames) _
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
  )

' All steps
' 1-Step-1.1,29-Step-1.1-Repeat,2-Step-1.2,3-Step-1.3,30-Step-1.3-Repeat,4-Step-1.4,5-Step-1.5,6-Step-1.6,7-Step-2.4,11-Step-2.4-Repeat,26-Step-2.4-Repeat2,8-Step-2.1-1.5Displ,9-Step-2.1-NeutralPos,10-Step-2.2,12-Step-2.5,13-Step-2.6-1,14-Step-2.6-2,15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,19-Step-3.2-1,20-Step-3.2-2,27-Step-3.2-hot,28-Step-3.2-cold,21-Step-3.3-1,22-Step-3.3-2,23-Step-3.4-1,24-Step-3.4-2,25-Step-3.4-3,31-Step-3.7-1,32-Step-3.7-2,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot,39-Step-3.1-50FH-cold,40-Step-3.1-50FH-hot,41-Step-3.2-50FH-cold-1,42-Step-3.2-50FH-cold-2,43-Step-3.2-50FH-hot,44-Step-3.1-60FH-cold,45-Step-3.1-60FH-hot
' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("12-Step-2.5", "13-Step-2.6-1", "14-Step-2.6-2", "15-Step-3.1-1", "16-Step-3.1-2", "17-Step-3.1-3", "18-Step-3.1-4", "19-Step-3.2-1", "20-Step-3.2-2", "21-Step-3.3-1", "22-Step-3.3-2", "23-Step-3.4-1", "24-Step-3.4-2", "25-Step-3.4-3")
' iterators = Array("15-Step-3.1-1", "16-Step-3.1-2", "17-Step-3.1-3", "18-Step-3.1-4", "19-Step-3.2-1", "20-Step-3.2-2", "21-Step-3.3-1", "22-Step-3.3-2", "23-Step-3.4-1", "24-Step-3.4-2", "25-Step-3.4-3")
' iterators = Array("41-Step-3.2-50FH-cold-1","42-Step-3.2-50FH-cold-2","43-Step-3.2-50FH-hot")
iterators = Array("44-Step-3.1-60FH-cold", "45-Step-3.1-60FH-hot")
' iterators = Array("1-Step-1.1", "2-Step-1.2", "3-Step-1.3", "4-Step-1.4", "5-Step-1.5", "6-Step-1.6", "7-Step-2.4")
' iterators = Array("8-Step-2.1-1.5Displ", "9-Step-2.1-NeutralPos")
' iterators = Array("SN002-1.3", "SN002-2.4", "SN0012-1.3", "SN0012-2.4")
' iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08")

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