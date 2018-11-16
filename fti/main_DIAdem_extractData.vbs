

' filesNamesDataInput = Array("testsInitData\oldHousingP3.vbs", "testsInitData\newHousingP3.vbs")
' filesNamesDataInput = Array("testsInitData\HousingP2.vbs")
' filesNamesDataInput = Array("testsInitData\TRbladeholderFatigue.vbs")
'filesNamesDataInput = Array("testsInitData\steelLinksFatigue.vbs")
Include(CurrentScriptPath&"testToImport.vbs")
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

      If loadScript_resampleFlag Then
        ' Resample magnitudes data and save them in csv format to be post-processed using Python
        id_reSampleGroup = Data.Root.ChannelGroups.Count + 1

        ' Create new group where all the re-sampled data is stored
        Call GroupCreate("Re-sampled; "&newFreq&"Hz",id_reSampleGroup)
        Call Data.Root.ChannelGroups(id_reSampleGroup).Activate()

        newGroupForResamplingCount = 1
      Else
        newGroupForResamplingCount = 0
      End If

      ' Main loop
      For groupID = 1 To Data.Root.ChannelGroups.Count-newGroupForResamplingCount Step 1
        For Each originalChannel in Data.Root.ChannelGroups(groupID).Channels
          ' originalChannel = "[1]/"&dictVaDiadem(var)
          If Ubound(Filter(dictVaDiadem.Keys, originalChannel.Name)) > -1 Then 'If current variable exists in the choice of variables'

            If loadScript_resampleFlag Then

              ' Limit sampling frequency to the minimum between the prescribed frequency and original sampling frequency from channel
              resampling_freq = newFreq
              currentFreq = 1/originalChannel.Properties("wf_increment").Value
              If currentFreq < newFreq Then
                resampling_freq = currentFreq
              End If

              ' If resampled data 
              newChannel = "/"&originalChannel.Name&"__"&resampling_freq&"Hz__"&folderInfo(1)
              Call ChnResampleFreqBased("",originalChannel, newChannel,resampling_freq,"Automatic",0,0)

              ' export operation to csv
              If loadScript_saveFlagResampledDataCSV Then
                  nameOfFile = "rs__"&dictVaDiadem(originalChannel.Name)&"__"&resampling_freq&"Hz__"&folderInfo(1)&".csv"
                  Call DataFileSaveSel(csvFolder & nameOfFile,"CSV",newChannel)
              End If

              ' Flight test operations
              If FlagFTData Then

                If Ubound(Filter(signalsToDif, originalChannel.Name)) > -1 Then
                  diffVariableToSave = "/"&originalChannel.Name&"__"&resampling_freq&"Hz__"&folderInfo(1)&"__diff"

                  'Smooth operation'
                  ' smoothVariableToSave = "/"&originalChannel.Name&"__"&resampling_freq&"Hz__"&folderInfo(1)&"__smooth"
                  ' Call ChnSmooth(newChannel,smoothVariableToSave,numberPointsSmoothering,"symmetric","byMeanValue")
                  ' Call ChnDeriveCalc("",smoothVariableToSave,diffVariableToSave)

                  Call ChnDeriveCalc("",newChannel,diffVariableToSave)
                  Call DataFileSaveSel(csvFolder & "di__"&dictVaDiadem(originalChannel.Name)&"__"&resampling_freq&"Hz__"&folderInfo(1)&".csv","CSV",diffVariableToSave)
                End If

              End If

            Else

              resampling_freq = 1/originalChannel.Properties("wf_increment").Value
              nameOfFile = "rs__"&dictVaDiadem(originalChannel.Name)&"__"&resampling_freq&"Hz__"&folderInfo(1)&".csv"
              Call DataFileSaveSel(csvFolder & nameOfFile,"CSV",originalChannel)

            End If

          End If

        Next

      Next
      
      If loadScript_saveAllDataFlagPerStep Then
        Call DataFileSaveSel(workingFolder&"allData__step"&folderInfo(1)&".TDM","TDM", Data.Root.ChannelGroups(1).Channels)
      End If

      If loadScript_saveFlagResampledDataTDM Then
        Call DataFileSaveSel(workingFolder&"resampled__"&resampling_freq&"Hz__step"&folderInfo(1)&".TDM","TDM", Data.Root.ChannelGroups(2).Channels)
      End If

      ' Delete both folders for the group, the one that contains resampled data and the one with the original data
      n_groups = Data.Root.ChannelGroups.Count
      For groupID = 1 To n_groups Step 1
        Call Data.Root.ChannelGroups.Remove(1)
      Next

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