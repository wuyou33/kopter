vars = Array("07","08")

i = 7
For Each var in vars
	
	' Call DataFileSaveSel("L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0164\01_TDMS_data_Set-complete\02_STEPS\raw_split"&"\raw__step"&var&".TDM","TDM","'["&i&"]/Inner pitch link_Mean' - '["&i&"]/Inner pitch link [N]_Mean'")
	Call DataFileSaveSel("L:\MSH-Project Management Files\Functional Engineering\Test Division\Test_Daten\J17-03-Bench Tests\P3-J17-03-BT0164\01_TDMS_data_Set-complete\02_STEPS\raw_split"&"\raw__step"&var&".TDM","TDM","'["&i&"]/Inner pitch link_Mean' - '["&i&"]/Pitch link main [N]_Mean'")
	i = i + 1
Next
' filesNamesDataInput = Array("loadMultipleVariablesFromFoldersAndDeleteGroups.vbs", "ResamplingAndExportToCSV_Alejandro.VBS")
' --------------------------------------------------

' Delete all the previous groups
Call Data.Root.Clear()


For Each fileNameDataInput in filesNamesDataInput

  Include(CurrentScriptPath&fileNameDataInput) 'Old housing P3

Next

' Get fragments of variables from DIAdem3

startIndex = 1192 * (1/0.00195312)
length = 2*1/0.00195312
Call ChnFlagSet("[19]/CNT_FRC_CNRD_BLU", startIndex, length, True)
Call ChnFlagSet("[19]/CNT_FRC_CNRD_BLK", startIndex, length, True)
Call ChnFlagSet("[19]/CNT_FRC_CNRD_GLD", startIndex, length, True)
Call ChnFlagSet("[19]/CNT_FRC_BST_COL", startIndex, length, True)
Call ChnFlagSet("[19]/CNT_FRC_BST_LAT", startIndex, length, True)
Call ChnFlagSet("[19]/CNT_FRC_BST_LNG", startIndex, length, True)
