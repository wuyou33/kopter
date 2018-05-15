
Include("P:\kopter\fti\testsInitData\newHousingP3.vbs") 'New housing P3
' Include(".\testsInitData\oldHousingP3.vbs") 'Old housing P3

newFreq = 100 'Hz'
resampleFlag = True
saveFlagResampledData = False 'possible values: True or False
saveAllDataFlagPerStep = True 'possible values: True or False
saveFlagResampledDataTDM = True 'possible values: True or False

' --------------------------------------------------
count_folders = 0
For Each folder in folders
  'Iterables 
  count_folders = count_folders + 1
  count_files = 0
  For Each nameOfFile in fileNames
    For Each oFile In oFSO.GetFolder(folder).Files
      If oFile.Name = nameOfFile&".tdms" Then

        Call DataFileLoad(oFile,"") 'Each new variable is loaded and it is stored alone in a new group'
        count_files = count_files + 1
      End if
    Next
  Next

  For j = 2 To count_files Step 1
    'Collapse all the channels in the newly created groups to an unique group
    For Each channel in Data.Root.ChannelGroups(2).Channels
      Call Data.Move(channel,Data.Root.ChannelGroups(1).Channels) 
    Next
    Call Data.Root.ChannelGroups.Remove(2) 'Remove the group that have been emptied'
  Next

  if resampleFlag Then
    ' Resample magnitudes data and save them in csv format to be post-processed using Python
    id_reSampleGroup = Data.Root.ChannelGroups.Count + 1

    ' Create new group where all the re-sampled data is stored
    Call GroupCreate("Re-sampled; "&newFreq&"Hz",id_reSampleGroup)
    Call Data.Root.ChannelGroups(id_reSampleGroup).Activate()

    '  add downsampled channels to this group
    For Each originalChannel in Data.Root.ChannelGroups(1).Channels
      ' originalChannel = "[1]/"&dictVaDiadem(var)
      newChannel = "/"&originalChannel.Name&"_"&newFreq&"Hz_"&count_folders
      Call ChnResampleFreqBased("",originalChannel, newChannel,newFreq,"Automatic",0,0)

      ' export operation to csv
      If saveFlagResampledData Then
          fileName = "rs_"&dictVaDiadem(originalChannel.Name)&"_"&newFreq&"Hz_"&count_folders&".csv"
          Call DataFileSaveSel(csvFolder & fileName,"CSV",newChannel)
      End If

    Next

  End If
  
  If saveAllDataFlagPerStep Then
    Call DataFileSaveSel(workingFolder&"allData_step"&count_folders&".TDM","TDM", Data.Root.ChannelGroups(1).Channels)
  End If

  If saveFlagResampledDataTDM Then
    Call DataFileSaveSel(workingFolder&"resampled_"&newFreq&"Hz_step"&count_folders&".TDM","TDM", Data.Root.ChannelGroups(2).Channels)
  End If

  ' Delete both folders for the group, the one that contains resampled data and the one with the original data
  Call Data.Root.ChannelGroups.Remove(1)
  if resampleFlag Then
    Call Data.Root.ChannelGroups.Remove(1)
  End If

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