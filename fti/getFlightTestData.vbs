'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 04/04/2018
'-- Author: Alejandro Valverde
'-- Comment: Script downsamples chosen channels and export these to csv file for fatigue analysis
'-- Modifications:
'-- 16.03.2018: Alejandro Valverde / Addition of loops for groups and variables.
'-------------------------------------------------------------------------------
' Option Explicit  'Forces the explicit declaration of all the variables in a script.
' Dim testname, firstIndex, lastIndex, id, variables, id_var, saveFlag, newFreq
' Dim idMaxGroup, idMinGroup, idMeanGroup, maxChannel, minChannel, meanChannel

' enter test name for file naming
testname = "Flight test data"

' Where to save the csv files exported
dirSave="P:\12_flightTestData\P2-J17-01-FT0038\data\" 'TR blade holder'

' Enter range of groups to be re-sampled

Set dictOfData = CreateObject("Scripting.Dictionary")
dictOfData.Add 1, Array("CNT_DST_LAT", "CNT_DST_LNG", "CNT_DST_COL", "CNT_DST_PED")

dictOfData.Add 2, Array("ENG_ARI_FAD_ARR_NR", "ENG_ARI_FAD_DST_CP") 'Variables ARINC'

dictOfData.Add 3, Array("VRU_ACC_X", "VRU_ACC_Y", "VRU_ACC_Z",_
                        "VRU_VEL_X", "VRU_VEL_Y", "VRU_VEL_Z",_
                        "VRU_ARR_P", "VRU_ARR_Q", "VRU_ARR_R",_
                        "VRU_ANG_PHI", "VRU_ANG_THETA", "VRU_ANG_PSI",_
                        "Sampletime") 'variables VRU

For Each id_group in dictOfData.Keys

  For Each var in dictOfData.Item(id_group)

    variableToSave = "[" & id_group &"]/"&var

    fileName = var&".csv"

    Call DataFileSaveSel(dirSave & fileName,"CSV",variableToSave)

  Next

Next

call MsgBox ("Execution finished")