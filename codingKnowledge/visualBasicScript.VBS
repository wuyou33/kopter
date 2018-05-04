For Each oFile In oFSO.GetFolder(sFolder).Files
  If UCase(oFSO.GetExtensionName(oFile.Name)) = "LTR" Then
    ProcessFiles oFSO, oFile
  End if
Next

