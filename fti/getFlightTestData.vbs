'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 04/04/2018
'-- Author: Alejandro Valverde
'-- Comment: Script downsamples chosen channels and export these to csv file for fatigue analysis
'-- Modifications:
'-- 16.03.2018: Alejandro Valverde / Addition of loops for groups and variables.
'-------------------------------------------------------------------------------

' Delete all the previous groups
Call Data.Root.Clear()

' enter test name for file naming

' Where to save the csv files exported
dirSave="P:\12_flightTestData\P2-J17-01-FT0102\data_rs\" 'TR blade holder'
fileLoad = "E:\FTI\ProcData\SKYeSH09\P2\J17-01-Flight Tests\P2-J17-01-FT0102\FTI\fti_2018-01-25_084649\fti_2018-01-25_084649_pp.tdms"
newFreq = 200
ResampleFlag = False
Call DataFileLoad(fileLoad,"")

' Enter range of groups to be re-sampled

Set dictOfData = CreateObject("Scripting.Dictionary")
' dictOfData.Add GroupIndexGet("Signals"), Array(_
'                         "CNT_DST_LAT", "CNT_DST_LNG", "CNT_DST_COL", "CNT_DST_PED",_
'                         "CNT_DST_BST_LNG", "CNT_DST_BST_COL", "CNT_DST_BST_LAT",_
'                         "CNT_FRC_BST_LNG", "CNT_FRC_BST_COL", "CNT_FRC_BST_LAT",_
'                         "CNT_FRC_STRD_BLU", "CNT_FRC_STRD_GRN", "CNT_FRC_STRD_RED"_
'                         )
                        
dictOfData.Add GroupIndexGet("Signals"), Array("CNT_FRC_STRD_BLU", "CNT_FRC_STRD_GRN", "CNT_FRC_STRD_RED")

' dictOfData.Add GroupIndexGet("ARINC"), Array("ENG_ARI_FAD_ARR_NR", "ENG_ARI_FAD_DST_CP") 'Variables ARINC'

' dictOfData.Add GroupIndexGet("VRU"), Array("VRU_ACC_X", "VRU_ACC_Y", "VRU_ACC_Z",_
'                         "VRU_VEL_X", "VRU_VEL_Y", "VRU_VEL_Z",_
'                         "VRU_ARR_P", "VRU_ARR_Q", "VRU_ARR_R",_
'                         "VRU_ANG_PHI", "VRU_ANG_THETA", "VRU_ANG_PSI") 'variables VRU

For Each id_group in dictOfData.Keys

  For Each var in dictOfData.Item(id_group)

    variableToSave = "[" & id_group &"]/"&var
    variableToSaveRS = "[" & id_group &"]/"&var&"__"&newFreq&"Hz"
    timeVariableToSave = "[" & id_group &"]/"&var&"_time"
    fileName = var&".csv"

    IF ResampleFlag Then

        Call ChnResampleFreqBased("",variableToSave, variableToSaveRS,newFreq,"Automatic",0,0)

        Call WfChnToChn(variableToSaveRS,0,"WfXAbsolute")
        
        Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Properties("displaytype").Value = "numeric"
        
        Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Name = var&"_time"

        Call DataFileSaveSel(dirSave & fileName,"CSV","'"&variableToSaveRS&"', '"&timeVariableToSave&"'")

    Else
        Call WfChnToChn(variableToSave,0,"WfXAbsolute")
        Data.Root.ChannelGroups(id_group).Channels("NoName").Properties("displaytype").Value = "numeric"
        Data.Root.ChannelGroups(id_group).Channels("NoName").Name = var&"_time"
        Call DataFileSaveSel(dirSave & fileName,"CSV","'"&variableToSave&"', '"&timeVariableToSave&"'")

    End If

  Next

Next

call MsgBox ("Execution finished")