'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 04/04/2018
'-- Author: Alejandro Valverde
'-- Comment: Script downsamples chosen channels and export these to csv file for fatigue analysis
'-- Modifications:
'-- 16.03.2018: Alejandro Valverde / Addition of loops for groups and variables.
'-------------------------------------------------------------------------------

' Delete all the previous groups
' Call Data.Root.Clear()

' enter test name for file naming

' Where to save the csv files exported
dirSave="P:\12_flightTestData\P3-FT04\Freq_actuator\freq\" 'TR blade holder'
' fileLoad = "E:\FTI\ProcData\SKYeSH09\P2\J17-01-Flight Tests\P2-J17-01-FT0102\FTI\fti_2018-01-25_084649\fti_2018-01-25_084649_pp.tdms"
fileLoad = "E:\FTI\ProcData\SKYeSH09\P2\J17-01-Flight Tests\P2-J17-01-FT0106\FTI\fti_2018-01-30_084242\fti_2018-01-30_084242_pp.tdms"

' Call DataFileLoad(fileLoad,"")
Set dictOfData = CreateObject("Scripting.Dictionary")
P3importFlag = True


If P3importFlag Then 'P3 flight test data'
  ' ------------------------------ P3 import data ------------------------------

  signalsForDivideInSegments = Array("CopyYHYD_PRS_1", "CopyYHYD_PRS_2", "CopyYCNT_DST_LAT", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG", "CopyYCNT_DST_BST_LAT")
  signalsToDif = Array("CopyYCNT_DST_LNG", "CopyYCNT_DST_LAT","CopyYCNT_DST_BST_LNG", "CopyYCNT_DST_BST_LAT")

  ' dictOfData.Add GroupIndexGet("31"), Array("CopyYHYD_PRS_1", "CopyYHYD_PRS_2", "CopyYCNT_DST_LAT", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG", "CopyYCNT_DST_BST_LAT") 'Cyclic whirl'
  ' dictOfData.Add GroupIndexGet("30"), Array("CopyYHYD_PRS_1", "CopyYHYD_PRS_2", "CopyYCNT_DST_LAT", "CopyYCNT_DST_BST_LAT") 'LAT sweep'
  ' dictOfData.Add GroupIndexGet("29"), Array("CopyYHYD_PRS_1", "CopyYHYD_PRS_2", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG") 'LNG sweep'
  ' dictOfData.Add GroupIndexGet("32star"), Array("CopyYHYD_PRS_2", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG") 'LNG sweep'
  ' dictOfData.Add GroupIndexGet("32"), Array("CopyYHYD_PRS_2", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG") 'LNG sweep'
  ' dictOfData.Add GroupIndexGet("33"), Array("CopyYHYD_PRS_2", "CopyYCNT_DST_LAT", "CopyYCNT_DST_BST_LAT") 'LAT sweep'
  ' dictOfData.Add GroupIndexGet("35"), Array("CopyYHYD_PRS_1", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG") 'LNG sweep'
  ' dictOfData.Add GroupIndexGet("34"), Array("CopyYHYD_PRS_2", "CopyYCNT_DST_LAT", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG", "CopyYCNT_DST_BST_LAT") 'Cyclic whirl'
  ' dictOfData.Add GroupIndexGet("36"), Array("CopyYHYD_PRS_1", "CopyYCNT_DST_LAT", "CopyYCNT_DST_BST_LAT") 'LAT sweep'
  ' dictOfData.Add GroupIndexGet("37"), Array("CopyYHYD_PRS_1", "CopyYCNT_DST_LAT", "CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG", "CopyYCNT_DST_BST_LAT") 'Cyclic whirl'
  dictOfData.Add GroupIndexGet("freq"), Array("CopyYCNT_DST_LNG", "CopyYCNT_DST_BST_LNG") 'LNG sweep'

  ' Call ChnOffset("[" & GroupIndexGet("67 - Rotors Flight Control") &"]/"&"CNT_DST_BST_LNG","[" & GroupIndexGet("67 - Rotors Flight Control") &"]/"&"CNT_DST_BST_LNG",-94.5,"free offset")
  ' Call ChnOffset("[" & GroupIndexGet("67 - Rotors Flight Control") &"]/"&"CNT_DST_BST_LAT","[" & GroupIndexGet("67 - Rotors Flight Control") &"]/"&"CNT_DST_BST_LAT",-96.2,"free offset")
  ' Call ChnOffset("[" & GroupIndexGet("67 - Rotors Flight Control") &"]/"&"CNT_DST_BST_COL","[" & GroupIndexGet("67 - Rotors Flight Control") &"]/"&"CNT_DST_BST_COL",-99.8,"free offset")

  ' ------------------------------------------------------------
  signalsForSID = Array()
  signalsForSIDdiff = Array()
Else 'P2 import data'
  ' ------------------- P2 import data ---------------------
  newFreqNonSIDsignal = 1000
  newFreqSIDsignal = 500

  ' Variables to import

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
' ------------------------------------------------------------
End If

' ------------------- Inner loop ----------------------------
For Each id_group in dictOfData.Keys

  For Each var in dictOfData.Item(id_group)

        variableToSave = "[" & id_group &"]/"&var
        timeVariableToSave = "[" & id_group &"]/"&var&"_time"
        diffVariableToSave = "[" & id_group &"]/"&var&"_diff"
        fileName = var&".csv"

    If Ubound(Filter(signalsForSID, var)) > -1 And Not(P3importFlag) Then

      ' For the SID signals
      variableToSaveRS = "[" & id_group &"]/"&var&"__"&newFreqSIDsignal&"Hz"
      variableToSaveRSSmooth = "[" & id_group &"]/"&var&"__smoothAfterRS"

      Call ChnResampleFreqBased("",variableToSave, variableToSaveRS,newFreqSIDsignal,"Automatic",0,0)
      Call ChnSmooth(variableToSaveRS,variableToSaveRSSmooth,12,"maxNumber","byMeanValue")

      If Ubound(Filter(signalsForSIDdiff, var)) > -1 Then 'Differenciate signals'
        variableToSaveRSSmoothDiff = variableToSaveRSSmooth&"__diff"
        variableToSaveRSSmoothDiffSmooth = variableToSaveRSSmooth&"__diff__smooth"
        Call ChnDeriveCalc("",variableToSaveRSSmooth,variableToSaveRSSmoothDiff)
        Call ChnSmooth(variableToSaveRSSmoothDiff,variableToSaveRSSmoothDiffSmooth,12,"maxNumber","byMeanValue")

        ' Get time vector
        Call WfChnToChn(variableToSaveRSSmoothDiffSmooth,0,"WfXAbsolute")
        Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Properties("displaytype").Value = "numeric"
        Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Name = var&"_time"&"_dif"
        Call DataFileSaveSel(dirSave & "DIF_"&fileName,"CSV","'"&variableToSaveRSSmoothDiffSmooth&"', '"&timeVariableToSave&"_dif"&"'")
      End If

    ElseIf Ubound(Filter(signalsForDivideInSegments, var)) > -1 And P3importFlag Then
      
      'Differenciate
      If Ubound(Filter(signalsToDif, var)) > -1 Then
        Call ChnDeriveCalc("",variableToSave,diffVariableToSave)
      End If
      
      'Move channel
      Call Data.Move(Data.Root.ChannelGroups(id_group).Channels(var),Data.Root.ChannelGroups(id_group).Channels,1)

      ' Get time vector
      Call WfChnToChn(variableToSave,0,"WfXAbsolute")
      Data.Root.ChannelGroups(id_group).Channels(1).Properties("displaytype").Value = "numeric"
      Data.Root.ChannelGroups(id_group).Channels(1).Name = var&"_time"
      Call DataFileSaveSel(dirSave & "sg__"&fileName,"CSV","'"&variableToSave&"', '"&timeVariableToSave&"'")

      ' Dif save
      If Ubound(Filter(signalsToDif, var)) > -1 Then
        Call DataFileSaveSel(dirSave & "dif__"&fileName,"CSV","'"&diffVariableToSave&"', '"&timeVariableToSave&"'")
      End If

    Else

      variableToSaveRSSmooth = "[" & id_group &"]/"&var&"__"&newFreqNonSIDsignal&"Hz"
      Call ChnResampleFreqBased("",variableToSave, variableToSaveRSSmooth,newFreqNonSIDsignal,"Automatic",0,0)

      Call WfChnToChn(variableToSaveRSSmooth,0,"WfXAbsolute")
      Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Properties("displaytype").Value = "numeric"
      Data.Root.ChannelGroups(id_group).Channels("xSamplingChn").Name = var&"_time"
      Call DataFileSaveSel(dirSave & fileName,"CSV","'"&variableToSaveRSSmooth&"', '"&timeVariableToSave&"'")
      
    End If

  Next

Next

call MsgBox ("Execution finished")


' How to obtain data points with 

' Dim MyFolders()
' Call InitMyFolders
' '-------------------------------------------------------------------------------
' Sub InitMyFolders
'   ReDim MyFolders(1)
'   MyFolders(0)="P:\12_flightTestData\P3-FT04\Freq_actuator\"
' End Sub
' '-------------------------------------------------------------------------------
' Call WfChnToChn("[25]/CopyYCNT_DST_LNG",0,"WfXRelative")
' Call Data.Move(Data.Root.ChannelGroups(25).Channels("CopyYCNT_DST_LNG"),Data.Root.ChannelGroups(25).Channels,3)
' Data.Root.ChannelGroups(25).Channels("CopyYCNT_DST_LNG").Name = "CopyYCNT_DST_LNG"
' Call DataFileSaveSel(MyFolders(0)&"CNT_DST_LNG_section.CSV","CSV","'[25]/CopyYCNT_DST_LNG', '[25]/CopyXMasterTime_64 Hz'")
