Set oFSO = CreateObject("Scripting.FileSystemObject")

workingFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"
csvFolder = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\csv_data\"

commonAddress = "L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0115 Booster P3\1200-1031112-AE SN2\Step 3.1 (New housing)\"
folders = Array(commonAddress & "2018-03-16_110513\" _
              , commonAddress & "2018-03-19_093423\" _
              , commonAddress & "2018-03-20_091923\" _
              , commonAddress & "2018-04-20_120313\" _
              , commonAddress & "2018-04-23_091424\" _
              , commonAddress & "2018-04-23_101919\" _
              , commonAddress & "2018-04-24_083617\" _
              , commonAddress & "2018-04-24_172859 (Step 1.1 post test)\" _
              , commonAddress & "2018-05-03_150824\" _
              )

variableNames = Array("Druck_HP_1_[bar]" _
                    , "Druck_HP_2_[bar]" _
                    , "Durchfluss_HP_1_[l_min]" _
                    , "Durchfluss_HP_2_[l_min]_" _
                    , "Force_Piston_Eye_HP1_[N]" _
                    , "Force_Piston_Eye_HP2_[N]" _
                    , "Input_force_[N]" _
                    , "Laser_Piston_[mm]" _
                    , "Laser_Steuerventilhebel_[mm]" _
                    , "Output_force_[N]" _
                    , "Temperatur_HP_1_[°C]" _
                    , "Temperatur_HP_2_[°C]" _
                    )

' --------------------------------------------------

count_folders = 0
For Each folder in folders
  count_files = 0
  For Each variableName in variableNames
    For Each oFile In oFSO.GetFolder(folder).Files
      If oFile.Name = variableName&".tdms" Then

        Call DataFileLoad(oFile,"")
        count_files = count_files + 1
      End if
    Next
  Next

  For j = (2+count_folders) To (count_files+count_folders) Step 1
    Call Data.Move(Data.Root.ChannelGroups(j).Channels(1),Data.Root.ChannelGroups(1+count_folders).Channels)
    Call Data.Root.ChannelGroups.Remove(2+count_folders)
  Next
  
  count_folders = count_folders + 1
Next

Call DataFileSave(workingFolder&"allData.TDM","TDM")

' Resample magnitudes data and save them in csv format to be post-processed using Python
For id 1 To count_folders Step 1

  '  add downsampled channels to this group
  For Each var in variableNames
    originalChannel = "[" & id &"]/"&var
    newChannel = "/"&var&"_"&newFreq&"Hz_"&id
    Call ChnResampleFreqBased("",originalChannel, newChannel,newFreq,"Automatic",0,0)

    ' export operation to csv
    If saveFlagResampledData Then
        fileName = "rs_"&var&"_"&newFreq&"Hz_"&id&".csv"
        Call DataFileSaveSel(csvFolder & fileName,"CSV",newChannel)
    End If

  Next
 
Next