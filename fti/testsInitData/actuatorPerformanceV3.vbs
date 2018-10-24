Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\02_STEPS\csv100\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\02_STEPS\csv100\"

filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
                  , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
                  , "Force_Piston_Eye_HP2_[N].tdms", "Input_force_[N].tdms", "Laser_Piston_[mm].tdms"_
                  , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_without_offset_[N].tdms", "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

filesNames2 = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
                  , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
                  , "Force_Piston_Eye_HP2_[N].tdms", "Input_force_[N].tdms", "Laser_Piston_[mm].tdms"_
                  , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_.tdms", "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

filesNames3 = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
                  , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
                  , "Force_Piston_Eye_HP2_[N].tdms", "Input_w_o_offset.tdms", "Laser_Piston_[mm].tdms"_
                  , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_w_o_offset.tdms", "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

filesNames4 = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
                  , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
                  , "Force_Piston_Eye_HP2_[N].tdms", "Input_force_with_offset[N].tdms", "Laser_Piston_[mm].tdms"_
                  , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_without_offset_[N].tdms", "Temperatur_HP_1_[°C].tdms", "Temperatur_HP_2_[°C].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0223\01_Data_set\01_RAW\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "Step 1.1\2018-10-10_144346\", "1-Step-1.1", filesNames4) _
  , Array(commonAddress & "Step 1.2\2018-10-11_101715\", "2-Step-1.2", filesNames2) _
  , Array(commonAddress & "Step 1.3\2018-10-10_154135\", "3-Step-1.3", filesNames2) _
  , Array(commonAddress & "Step 1.4\2018-10-10_144646\", "4-Step-1.4", filesNames) _
  , Array(commonAddress & "Step 1.5\2018-10-11_095700\", "5-Step-1.5", filesNames2) _
  , Array(commonAddress & "Step 1.6\2018-10-10_150951\", "6-Step-1.6", filesNames) _
  , Array(commonAddress & "Step 2.4\2018-10-11_102720\", "7-Step-2.4", filesNames2) _
  , Array(commonAddress & "Step 2.1\1.5 mm Displacement\2018-10-19_145010\", "8-Step-2.1-1.5Displ", filesNames3) _
  , Array(commonAddress & "Step 2.1\Neutral position\2018-10-19_103728\", "9-Step-2.1-NeutralPos", filesNames3) _
  )

' The variable iterators is used to load and operate only selected steps from above
iterators = Array("1-Step-1.1")
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
loadScript_saveFlagResampledDataTDM = True 'possible values: True or False

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