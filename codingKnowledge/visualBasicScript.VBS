For Each oFile In oFSO.GetFolder(sFolder).Files
  If UCase(oFSO.GetExtensionName(oFile.Name)) = "LTR" Then
    ProcessFiles oFSO, oFile
  End if
Next


' --------------------------------

Include("\\Server\Share\File") ' Path to code file

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

' ----------------------------------'

'Collapse all the channels in the newly created groups to an unique group
If sortFolderFlags Then
  For j = 2 To Data.Root.ChannelGroups.Count Step 1
    For Each channel in Data.Root.ChannelGroups(2).Channels
      Call Data.Move(channel,Data.Root.ChannelGroups(1).Channels) 
    Next
    Call Data.Root.ChannelGroups.Remove(2) 'Remove the group that have been emptied'
  Next
End If