
workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\"
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\csv_data\"

' These are the folders where the data that wants to be imported is contained.
' Data
commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\"
folders = Array(commonAddress & "2018-01-30_103559\" _
              , commonAddress & "2018-01-31_115139\" _
              , commonAddress & "2018-02-13_083036\" _
              , commonAddress & "2018-02-14_140513\" _
              , commonAddress & "2018-02-15_101019\" _
              , commonAddress & "2018-02-16_150804\" _
              , commonAddress & "2018-02-19_084519\" _
              , commonAddress & "2018-02-22_110842\" _
              , commonAddress & "2018-02-23_093532\" _
              , commonAddress & "2018-02-26_095412\" _
              , commonAddress & "2018-02-27_095219\" _
              )

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