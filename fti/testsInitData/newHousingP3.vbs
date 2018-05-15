Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"

' Where the data will be saved in csv format
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\csv_data\"

' Names of the files that require to be imported from each of the files
fileNames = Array(_
                    "Temperatur_HP_1_[°C]" _
                  , "Temperatur_HP_2_[°C]" _
                  , "Druck_HP_1_[bar]" _
                  , "Druck_HP_2_[bar]" _
                  , "Durchfluss_HP_1_[l_min]" _
                  , "Durchfluss_HP_2_[l_min]_" _
                  , "Force_Piston_Eye_HP1_[N]" _
                  , "Force_Piston_Eye_HP2_[N]" _
                  , "Input_force_[N]" _
                  , "Laser_Piston_[mm]" _
                  , "Laser_Steuerventilhebel_[mm]" _
                  , "Output_force_[N]" _
                  )


' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "2018-03-16_110513\", 1, fileNames) _
  , Array(commonAddress & "2018-03-19_093423\", 2, fileNames) _
  , Array(commonAddress & "2018-03-20_091923\", 3, fileNames) _
  , Array(commonAddress & "2018-04-20_120313\", 4, fileNames) _
  , Array(commonAddress & "2018-04-23_091424\", 5, fileNames) _
  , Array(commonAddress & "2018-04-23_101919\", 6, fileNames) _
  , Array(commonAddress & "2018-04-24_083617\", 7, fileNames) _
  , Array(commonAddress & "2018-04-24_172859 (Step 1.1 post test)\", 8, fileNames) _
  , Array(commonAddress & "2018-05-03_150824\", 9, fileNames) _
  )

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
dictVaDiadem.Add "Temperatur HP_1 [°C]", "TemperaturHP1"
dictVaDiadem.Add "Temperatur HP_2 [°C]", "TemperaturHP2"
dictVaDiadem.Add "Druck HP_1 [bar]", "DruckHP1"
dictVaDiadem.Add "Druck HP_2 [bar]", "DruckHP2"
dictVaDiadem.Add "Durchfluss HP_1 [l\min]", "DurchflussHP1"
dictVaDiadem.Add "Durchfluss HP_2 [l\min]", "DurchflussHP2"
dictVaDiadem.Add "Force Piston Eye HP1 [N]", "ForcePistonEyeHP1"
dictVaDiadem.Add "Force Piston Eye HP2 [N]", "ForcePistonEyeHP2"
dictVaDiadem.Add "Input force [N]", "InputForce"
dictVaDiadem.Add "Laser Piston [mm]", "LaserPiston"
dictVaDiadem.Add "Laser Steuerventilhebel [mm]", "LaserSteuerventilhebel"
dictVaDiadem.Add "Output force [N]", "OutputForce"