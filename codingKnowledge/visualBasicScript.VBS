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