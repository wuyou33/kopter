Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVar = CreateObject("Scripting.Dictionary")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"
' csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\csv_data\"

workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\"
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1\csv_data\"

' These are the folders where the data that wants to be imported is contained.
' commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"
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

' folders = Array(commonAddress & "2018-03-16_110513\" _
'               , commonAddress & "2018-03-19_093423\" _
'               , commonAddress & "2018-03-20_091923\" _
'               , commonAddress & "2018-04-20_120313\" _
'               , commonAddress & "2018-04-23_091424\" _
'               , commonAddress & "2018-04-23_101919\" _
'               , commonAddress & "2018-04-24_083617\" _
'               , commonAddress & "2018-04-24_172859 (Step 1.1 post test)\" _
'               , commonAddress & "2018-05-03_150824\" _
'               )

' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.

dictVar.Add "Druck_HP_1_[bar]", "DruckHP1"
dictVar.Add "Druck_HP_2_[bar]", "DruckHP2"
dictVar.Add "Durchfluss_HP_1_[l_min]", "DurchflussHP1"
dictVar.Add "Durchfluss_HP_2_[l_min]_", "DurchflussHP2"
dictVar.Add "Force_Piston_Eye_HP1_[N]", "ForcePistonEyeHP1"
dictVar.Add "Force_Piston_Eye_HP2_[N]", "ForcePistonEyeHP2"
dictVar.Add "Input_force_[N]", "InputForce"
dictVar.Add "Laser_Piston_[mm]", "LaserPiston"
dictVar.Add "Laser_Steuerventilhebel_[mm]", "LaserSteuerventilhebel"
dictVar.Add "Output_force_[N]", "OutputForce"
dictVar.Add "Temperatur_HP_1_[°C]", "TemperaturHP1"
dictVar.Add "Temperatur_HP_2_[°C]", "TemperaturHP2"

dictVaDiadem.Add "Druck_HP_1_[bar]", "Druck HP_1 [bar]"
dictVaDiadem.Add "Druck_HP_2_[bar]", "Druck HP_2 [bar]"
dictVaDiadem.Add "Durchfluss_HP_1_[l_min]", "Durchfluss HP_1 [l\min]"
dictVaDiadem.Add "Durchfluss_HP_2_[l_min]_", "Durchfluss HP_2 [l\min]"
dictVaDiadem.Add "Force_Piston_Eye_HP1_[N]", "Force Piston Eye HP1 [N]"
dictVaDiadem.Add "Force_Piston_Eye_HP2_[N]", "Force Piston Eye HP2 [N]"
dictVaDiadem.Add "Input_force_[N]", "Input force [N]"
dictVaDiadem.Add "Laser_Piston_[mm]", "Laser Piston [mm]"
dictVaDiadem.Add "Laser_Steuerventilhebel_[mm]", "Laser Steuerventilhebel [mm]"
dictVaDiadem.Add "Output_force_[N]", "Output force [N]"
dictVaDiadem.Add "Temperatur_HP_1_[°C]", "Temperatur HP_1 [°C]"
dictVaDiadem.Add "Temperatur_HP_2_[°C]", "Temperatur HP_2 [°C]"

newFreq = 100 'Hz'
importDataFlag = True
saveAllDataFlag = True 'possible values: True or False
saveFlagResampledData = True 'possible values: True or False

' --------------------------------------------------
If importDataFlag Then
  count_folders = 0
  For Each folder in folders
    count_files = 0
    For Each variableName in dictVar.Keys
      For Each oFile In oFSO.GetFolder(folder).Files
        If oFile.Name = variableName&".tdms" Then

          Call DataFileLoad(oFile,"") 'Each new variable is loaded and it is stored alone in a new group'
          count_files = count_files + 1
        End if
      Next
    Next

    For j = (2+count_folders) To (count_files+count_folders) Step 1
      'Collapse all the channels in an unique group
      Call Data.Move(Data.Root.ChannelGroups(2+count_folders).Channels(1),Data.Root.ChannelGroups(1+count_folders).Channels) 
      Call Data.Root.ChannelGroups.Remove(2+count_folders) 'Remove the group that have been emptied'
    Next
    
    count_folders = count_folders + 1
  Next
End If

If saveAllDataFlag Then
  Call DataFileSave(workingFolder&"allData.TDM","TDM")
End If

'-------------------------------------'
' Resample magnitudes data and save them in csv format to be post-processed using Python
id_reSampleGroup = Data.Root.ChannelGroups.Count + 1

' Create new group where all the re-sampled data is stored
Call GroupCreate("Re-sampled; "&newFreq&"Hz",id_reSampleGroup)
Call Data.Root.ChannelGroups(id_reSampleGroup).Activate()

For id = 1 To count_folders Step 1

  '  add downsampled channels to this group
  For Each var in dictVar.Keys
    originalChannel = "[" & id &"]/"&dictVaDiadem(var)
    newChannel = "/"&dictVaDiadem(var)&"_"&newFreq&"Hz_"&id
    Call ChnResampleFreqBased("",originalChannel, newChannel,newFreq,"Automatic",0,0)

    ' export operation to csv
    If saveFlagResampledData Then
        fileName = "rs_"&dictVar(var)&"_"&newFreq&"Hz_"&id&".csv"
        Call DataFileSaveSel(csvFolder & fileName,"CSV",newChannel)
    End If

  Next
 
Next

call MsgBox ("Execution finished")