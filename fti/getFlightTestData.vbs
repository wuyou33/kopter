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
dirSave="P:\12_flightTestData\P2-J17-01-FT0106\data\" 'TR blade holder'
' fileLoad = "E:\FTI\ProcData\SKYeSH09\P2\J17-01-Flight Tests\P2-J17-01-FT0102\FTI\fti_2018-01-25_084649\fti_2018-01-25_084649_pp.tdms"
fileLoad = "E:\FTI\ProcData\SKYeSH09\P2\J17-01-Flight Tests\P2-J17-01-FT0106\FTI\fti_2018-01-30_084242\fti_2018-01-30_084242_pp.tdms"
newFreqNonSIDsignal = 1000
newFreqSIDsignal = 500
Call DataFileLoad(fileLoad,"")
Set dictOfData = CreateObject("Scripting.Dictionary")

' Enter range of groups to be re-sampled

signalsForSID = Array("CNT_DST_LNG", "CNT_DST_BST_LNG", "CNT_DST_LAT", "CNT_DST_BST_LAT", "CNT_DST_COL", "CNT_DST_BST_COL", "CNT_DST_PED", "CNT_DST_BST_PED")

signalsForSIDdiff = Array("CNT_DST_BST_LNG", "CNT_DST_BST_LAT", "CNT_DST_BST_COL", "CNT_DST_LNG", "CNT_DST_LAT", "CNT_DST_COL")

' dictOfData.Add GroupIndexGet("Signals"), Array(_
'                         "CNT_DST_LAT", "CNT_DST_LNG", "CNT_DST_COL", "CNT_DST_PED",_
'                         "CNT_DST_BST_LNG", "CNT_DST_BST_COL", "CNT_DST_BST_LAT",_
'                         "CNT_FRC_BST_LNG", "CNT_FRC_BST_COL", "CNT_FRC_BST_LAT",_
'                         "CNT_FRC_STRD_BLU", "CNT_FRC_STRD_GRN", "CNT_FRC_STRD_RED"_
'                         )
                        
' dictOfData.Add GroupIndexGet("Signals"), Array("CNT_DST_BST_LNG", "CNT_DST_BST_LAT", "CNT_DST_BST_COL")
' dictOfData.Add GroupIndexGet("Signals"), Array("CNT_DST_LNG", "CNT_DST_LAT", "CNT_DST_COL")
dictOfData.Add GroupIndexGet("Signals"), Array("CNT_FRC_BST_LNG", "CNT_FRC_BST_COL", "CNT_FRC_BST_LAT")

' dictOfData.Add GroupIndexGet("ARINC"), Array("ENG_ARI_FAD_ARR_NR", "ENG_ARI_FAD_DST_CP") 'Variables ARINC'

' dictOfData.Add GroupIndexGet("VRU"), Array("VRU_ACC_X", "VRU_ACC_Y", "VRU_ACC_Z",_
'                         "VRU_VEL_X", "VRU_VEL_Y", "VRU_VEL_Z",_
'                         "VRU_ARR_P", "VRU_ARR_Q", "VRU_ARR_R",_
'                         "VRU_ANG_PHI", "VRU_ANG_THETA", "VRU_ANG_PSI") 'variables VRU

' OFFSET CORRECTIOn
Call ChnOffset("[" & GroupIndexGet("Signals") &"]/"&"CNT_DST_BST_LNG","[" & GroupIndexGet("Signals") &"]/"&"CNT_DST_BST_LNG",-101.875,"free offset")
Call ChnOffset("[" & GroupIndexGet("Signals") &"]/"&"CNT_DST_BST_LAT","[" & GroupIndexGet("Signals") &"]/"&"CNT_DST_BST_LAT",-87.385,"free offset")
Call ChnOffset("[" & GroupIndexGet("Signals") &"]/"&"CNT_DST_BST_COL","[" & GroupIndexGet("Signals") &"]/"&"CNT_DST_BST_COL",-106.725,"free offset")

For Each id_group in dictOfData.Keys

  For Each var in dictOfData.Item(id_group)

        variableToSave = "[" & id_group &"]/"&var
        timeVariableToSave = "[" & id_group &"]/"&var&"_time"
        fileName = var&".csv"

    If Ubound(Filter(signalsForSID, var)) > -1 Then

        ' For the SID signals
        variableToSaveRS = "[" & id_group &"]/"&var&"__"&newFreqSIDsignal&"Hz"
        variableToSaveRSSmooth = "[" & id_group &"]/"&var&"__smoothAfterRS"

        Call ChnResampleFreqBased("",variableToSave, variableToSaveRS,newFreqSIDsignal,"Automatic",0,0)
        Call ChnSmooth(variableToSaveRS,variableToSaveRSSmooth,12,"maxNumber","byMeanValue")

        If Ubound(Filter(signalsForSIDdiff, var)) > -1 Then
            variableToSaveRSSmoothDiff = variableToSaveRSSmooth&"__diff"
            variableToSaveRSSmoothDiffSmooth = variableToSaveRSSmooth&"__diff__smooth"
            Call ChnDeriveCalc("",variableToSaveRSSmooth,variableToSaveRSSmoothDiff)
            Call ChnSmooth(variableToSaveRSSmoothDiff,variableToSaveRSSmoothDiffSmooth,12,"maxNumber","byMeanValue")
            Call WfChnToChn(variableToSaveRSSmoothDiffSmooth,0,"WfXAbsolute")
            Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Properties("displaytype").Value = "numeric"
            Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Name = var&"_time"&"_dif"
            Call DataFileSaveSel(dirSave & "DIF_"&fileName,"CSV","'"&variableToSaveRSSmoothDiffSmooth&"', '"&timeVariableToSave&"_dif"&"'")
        End If

    Else

        variableToSaveRSSmooth = "[" & id_group &"]/"&var&"__"&newFreqNonSIDsignal&"Hz"

        Call ChnResampleFreqBased("",variableToSave, variableToSaveRSSmooth,newFreqNonSIDsignal,"Automatic",0,0)

    End If

        Call WfChnToChn(variableToSaveRSSmooth,0,"WfXAbsolute")
        Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Properties("displaytype").Value = "numeric"
        Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Name = var&"_time"
        Call DataFileSaveSel(dirSave & fileName,"CSV","'"&variableToSaveRSSmooth&"', '"&timeVariableToSave&"'")

  Next

Next

call MsgBox ("Execution finished")