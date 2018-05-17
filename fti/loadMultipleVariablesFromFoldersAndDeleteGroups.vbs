

filesNamesDataInput = Array("testsInitData\oldHousingP3.vbs", "testsInitData\newHousingP3.vbs")
' filesNamesDataInput = Array("testsInitData\oldHousingP3.vbs", "testsInitData\HousingP2.vbs")
' filesNamesDataInput = Array("testsInitData\TRbladeholderFatigue.vbs")
' --------------------------------------------------

' Delete all the previous groups
Call Data.Root.Clear()


For Each fileNameDataInput in filesNamesDataInput

  Include(CurrentScriptPath&fileNameDataInput) 'Old housing P3

  For Each folderInfo in fileNamesBigArrayFolders
    'Iterables 
    If Ubound(Filter(iterators, folderInfo(1))) > -1 Then
      For Each nameOfFile in folderInfo(2)
        For Each oFile In oFSO.GetFolder(folderInfo(0)).Files
          If oFile.Name = nameOfFile Then
            Call DataFileLoad(oFile,"") 'Each new variable is loaded and it is stored alone in a new group'
          End if
        Next
      Next

      For j = 2 To Data.Root.ChannelGroups.Count Step 1
        'Collapse all the channels in the newly created groups to an unique group
        For Each channel in Data.Root.ChannelGroups(2).Channels
          Call Data.Move(channel,Data.Root.ChannelGroups(1).Channels) 
        Next
        Call Data.Root.ChannelGroups.Remove(2) 'Remove the group that have been emptied'
      Next

      if loadScript_resampleFlag Then
        ' Resample magnitudes data and save them in csv format to be post-processed using Python
        id_reSampleGroup = Data.Root.ChannelGroups.Count + 1

        ' Create new group where all the re-sampled data is stored
        Call GroupCreate("Re-sampled; "&newFreq&"Hz",id_reSampleGroup)
        Call Data.Root.ChannelGroups(id_reSampleGroup).Activate()

        '  add downsampled channels to this group
        For Each originalChannel in Data.Root.ChannelGroups(1).Channels
          ' originalChannel = "[1]/"&dictVaDiadem(var)
          If Ubound(Filter(dictVaDiadem.Keys, originalChannel.Name)) > -1 Then 'If current variable exists in the choice of variables'

            newChannel = "/"&originalChannel.Name&"__"&newFreq&"Hz__"&folderInfo(1)
            Call ChnResampleFreqBased("",originalChannel, newChannel,newFreq,"Automatic",0,0)

            ' export operation to csv
            If loadScript_saveFlagResampledDataCSV Then
                nameOfFile = "rs__"&dictVaDiadem(originalChannel.Name)&"__"&newFreq&"Hz__"&folderInfo(1)&".csv"
                Call DataFileSaveSel(csvFolder & nameOfFile,"CSV",newChannel)
            End If

          End If

        Next

      End If
      
      If loadScript_saveAllDataFlagPerStep Then
        Call DataFileSaveSel(workingFolder&"allData__step"&folderInfo(1)&".TDM","TDM", Data.Root.ChannelGroups(1).Channels)
      End If

      If loadScript_saveFlagResampledDataTDM Then
        Call DataFileSaveSel(workingFolder&"resampled__"&newFreq&"Hz__step"&folderInfo(1)&".TDM","TDM", Data.Root.ChannelGroups(2).Channels)
      End If

      ' Delete both folders for the group, the one that contains resampled data and the one with the original data
      Call Data.Root.ChannelGroups.Remove(1)
      if loadScript_resampleFlag Then
        Call Data.Root.ChannelGroups.Remove(1)
      End If

    End If
  Next

Next 

'-------------------------------------'

call MsgBox ("Execution finished")

Sub Include(sInstFile)
  Dim f, s, oFSO
  Set oFSO = CreateObject("Scripting.FileSystemObject")
  On Error Resume Next
  If oFSO.FileExists(sInstFile) Then
    Set f = oFSO.OpenTextFile(sInstFile)
    s = f.ReadAll
    f.Close
    ExecuteGlobal s
  End If
  On Error Goto 0
  Set f = Nothing
  Set oFSO = Nothing
End Sub