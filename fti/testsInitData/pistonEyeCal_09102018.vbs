Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
' workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_09102018\"

' Where the data will be saved in csv format
' csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_09102018\"

' filesNames = Array("Force_Piston_Eye_HP1_[N].tdms", "Force_Piston_Eye_HP2_[N].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH\13_Testing+Instrumentation\FTI\18_Calibration\AD_Bench Tests\2018_10_11_Piston Eye_Recab\20181009_Calibration 1st Method 2 x ramp up&down\"
fileNamesBigArrayFolders = Array( _
      Array(commonAddress & "Piston eye 1\Compression\Run 1\", "1-PE9_Compression1_0", Array("Piston Gauge 1 Compr_0.tdms", "Piston Rods Gauge 1 Compr_0.tdms", "Piston - Actuator_0.tdms", "Piston actuator G1_0.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "2-PE9_Compression1_1", Array("Piston Gauge 1 Compr_1.tdms", "Piston Rods Gauge 1 Compr_1.tdms", "Piston - Actuator_1.tdms", "Piston actuator G1_1.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "3-PE9_Compression1_2", Array("Piston Gauge 1 Compr_2.tdms", "Piston Rods Gauge 1 Compr_2.tdms", "Piston - Actuator_2.tdms", "Piston actuator G1_2.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "4-PE9_Compression1_3", Array("Piston Gauge 1 Compr_3.tdms", "Piston Rods Gauge 1 Compr_3.tdms", "Piston - Actuator_3.tdms", "Piston actuator G1_3.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "5-PE9_Compression1_4", Array("Piston Gauge 1 Compr_4.tdms", "Piston Rods Gauge 1 Compr_4.tdms", "Piston - Actuator_4.tdms", "Piston actuator G1_4.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "6-PE9_Compression1_5", Array("Piston Gauge 1 Compr_5.tdms", "Piston Rods Gauge 1 Compr_5.tdms", "Piston - Actuator_5.tdms", "Piston actuator G1_5.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "7-PE9_Compression1_6", Array("Piston Gauge 1 Compr_6.tdms", "Piston Rods Gauge 1 Compr_6.tdms", "Piston - Actuator_6.tdms", "Piston actuator G1_6.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "8-PE9_Compression1_7", Array("Piston Gauge 1 Compr_7.tdms", "Piston Rods Gauge 1 Compr_7.tdms", "Piston - Actuator_7.tdms", "Piston actuator G1_7.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "9-PE9_Compression1_8", Array("Piston Gauge 1 Compr_8.tdms", "Piston Rods Gauge 1 Compr_8.tdms", "Piston - Actuator_8.tdms", "Piston actuator G1_8.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "10-PE9_Compression1_9", Array("Piston Gauge 1 Compr_9.tdms", "Piston Rods Gauge 1 Compr_9.tdms", "Piston - Actuator_9.tdms", "Piston actuator G1_9.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 1\", "11-PE9_Compression1_10", Array("Piston Gauge 1 Compr_10.tdms", "Piston Rods Gauge 1 Compr_10.tdms", "Piston - Actuator_10.tdms", "Piston actuator G1_10.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "12-PE9_Compression2_0", Array("Piston Gauge 1 Compr_0.tdms", "Piston Rods Gauge 1 Comp_0.tdms", "Piston - Actuator_0.tdms", "Piston actuator G1_0.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "13-PE9_Compression2_1", Array("Piston Gauge 1 Compr_1.tdms", "Piston Rods Gauge 1 Comp_1.tdms", "Piston - Actuator_1.tdms", "Piston actuator G1_1.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "14-PE9_Compression2_2", Array("Piston Gauge 1 Compr_2.tdms", "Piston Rods Gauge 1 Comp_2.tdms", "Piston - Actuator_2.tdms", "Piston actuator G1_2.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "15-PE9_Compression2_3", Array("Piston Gauge 1 Compr_3.tdms", "Piston Rods Gauge 1 Comp_3.tdms", "Piston - Actuator_3.tdms", "Piston actuator G1_3.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "16-PE9_Compression2_4", Array("Piston Gauge 1 Compr_4.tdms", "Piston Rods Gauge 1 Comp_4.tdms", "Piston - Actuator_4.tdms", "Piston actuator G1_4.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "17-PE9_Compression2_5", Array("Piston Gauge 1 Compr_5.tdms", "Piston Rods Gauge 1 Comp_5.tdms", "Piston - Actuator_5.tdms", "Piston actuator G1_5.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "18-PE9_Compression2_6", Array("Piston Gauge 1 Compr_6.tdms", "Piston Rods Gauge 1 Comp_6.tdms", "Piston - Actuator_6.tdms", "Piston actuator G1_6.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "19-PE9_Compression2_7", Array("Piston Gauge 1 Compr_7.tdms", "Piston Rods Gauge 1 Comp_7.tdms", "Piston - Actuator_7.tdms", "Piston actuator G1_7.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "20-PE9_Compression2_8", Array("Piston Gauge 1 Compr_8.tdms", "Piston Rods Gauge 1 Comp_8.tdms", "Piston - Actuator_8.tdms", "Piston actuator G1_8.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "21-PE9_Compression2_9", Array("Piston Gauge 1 Compr_9.tdms", "Piston Rods Gauge 1 Comp_9.tdms", "Piston - Actuator_9.tdms", "Piston actuator G1_9.tdms")) _
    , Array(commonAddress & "Piston eye 1\Compression\Run 2\", "22-PE9_Compression2_10", Array("Piston Gauge 1 Compr_10.tdms", "Piston Rods Gauge 1 Comp_10.tdms", "Piston - Actuator_10.tdms", "Piston actuator G1_10.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "23-PE9_Tension1_0", Array("Piston Gauge 1 Compr_0.tdms", "Piston Rods Gauge 1 Compr_0.tdms", "Piston - Actuator_0.tdms", "Piston actuator G1_0.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "24-PE9_Tension1_1", Array("Piston Gauge 1 Compr_1.tdms", "Piston Rods Gauge 1 Compr_1.tdms", "Piston - Actuator_1.tdms", "Piston actuator G1_1.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "25-PE9_Tension1_2", Array("Piston Gauge 1 Compr_2.tdms", "Piston Rods Gauge 1 Compr_2.tdms", "Piston - Actuator_2.tdms", "Piston actuator G1_2.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "26-PE9_Tension1_3", Array("Piston Gauge 1 Compr_3.tdms", "Piston Rods Gauge 1 Compr_3.tdms", "Piston - Actuator_3.tdms", "Piston actuator G1_3.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "27-PE9_Tension1_4", Array("Piston Gauge 1 Compr_4.tdms", "Piston Rods Gauge 1 Compr_4.tdms", "Piston - Actuator_4.tdms", "Piston actuator G1_4.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "28-PE9_Tension1_5", Array("Piston Gauge 1 Compr_5.tdms", "Piston Rods Gauge 1 Compr_5.tdms", "Piston - Actuator_5.tdms", "Piston actuator G1_5.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "29-PE9_Tension1_6", Array("Piston Gauge 1 Compr_6.tdms", "Piston Rods Gauge 1 Compr_6.tdms", "Piston - Actuator_6.tdms", "Piston actuator G1_6.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "30-PE9_Tension1_7", Array("Piston Gauge 1 Compr_7.tdms", "Piston Rods Gauge 1 Compr_7.tdms", "Piston - Actuator_7.tdms", "Piston actuator G1_7.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "31-PE9_Tension1_8", Array("Piston Gauge 1 Compr_8.tdms", "Piston Rods Gauge 1 Compr_8.tdms", "Piston - Actuator_8.tdms", "Piston actuator G1_8.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "32-PE9_Tension1_9", Array("Piston Gauge 1 Compr_9.tdms", "Piston Rods Gauge 1 Compr_9.tdms", "Piston - Actuator_9.tdms", "Piston actuator G1_9.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 1\", "33-PE9_Tension1_10", Array("Piston Gauge 1 Compr_10.tdms", "Piston Rods Gauge 1 Compr_10.tdms", "Piston - Actuator_10.tdms", "Piston actuator G1_10.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "34-PE9_Tension2_0", Array("Piston Gauge 1 Compr_0.tdms", "Piston Rods Gauge 1 Compr_0.tdms", "Piston - Actuator_0.tdms", "Piston actuator G1_0.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "35-PE9_Tension2_1", Array("Piston Gauge 1 Compr_1.tdms", "Piston Rods Gauge 1 Compr_1.tdms", "Piston - Actuator_1.tdms", "Piston actuator G1_1.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "36-PE9_Tension2_2", Array("Piston Gauge 1 Compr_2.tdms", "Piston Rods Gauge 1 Compr_2.tdms", "Piston - Actuator_2.tdms", "Piston actuator G1_2.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "37-PE9_Tension2_3", Array("Piston Gauge 1 Compr_3.tdms", "Piston Rods Gauge 1 Compr_3.tdms", "Piston - Actuator_3.tdms", "Piston actuator G1_3.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "38-PE9_Tension2_4", Array("Piston Gauge 1 Compr_4.tdms", "Piston Rods Gauge 1 Compr_4.tdms", "Piston - Actuator_4.tdms", "Piston actuator G1_4.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "39-PE9_Tension2_5", Array("Piston Gauge 1 Compr_5.tdms", "Piston Rods Gauge 1 Compr_5.tdms", "Piston - Actuator_5.tdms", "Piston actuator G1_5.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "40-PE9_Tension2_6", Array("Piston Gauge 1 Compr_6.tdms", "Piston Rods Gauge 1 Compr_6.tdms", "Piston - Actuator_6.tdms", "Piston actuator G1_6.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "41-PE9_Tension2_7", Array("Piston Gauge 1 Compr_7.tdms", "Piston Rods Gauge 1 Compr_7.tdms", "Piston - Actuator_7.tdms", "Piston actuator G1_7.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "42-PE9_Tension2_8", Array("Piston Gauge 1 Compr_8.tdms", "Piston Rods Gauge 1 Compr_8.tdms", "Piston - Actuator_8.tdms", "Piston actuator G1_8.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "43-PE9_Tension2_9", Array("Piston Gauge 1 Compr_9.tdms", "Piston Rods Gauge 1 Compr_9.tdms", "Piston - Actuator_9.tdms", "Piston actuator G1_9.tdms")) _
    , Array(commonAddress & "Piston eye 1\Tension\Run 2\", "44-PE9_Tension2_10", Array("Piston Gauge 1 Compr_10.tdms", "Piston Rods Gauge 1 Compr_10.tdms", "Piston - Actuator_10.tdms", "Piston actuator G1_10.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "45-PE10_Compression1_0", Array("Actuator Gauge 2 Comp_0.tdms", "Piston Rods Gauge 2 Compr_0.tdms", "Piston - Actuator_0.tdms", "Piston actuator G1_0.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "46-PE10_Compression1_1", Array("Actuator Gauge 2 Comp_1.tdms", "Piston Rods Gauge 2 Compr_1.tdms", "Piston - Actuator_1.tdms", "Piston actuator G1_1.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "47-PE10_Compression1_2", Array("Actuator Gauge 2 Comp_2.tdms", "Piston Rods Gauge 2 Compr_2.tdms", "Piston - Actuator_2.tdms", "Piston actuator G1_2.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "48-PE10_Compression1_3", Array("Actuator Gauge 2 Comp_3.tdms", "Piston Rods Gauge 2 Compr_3.tdms", "Piston - Actuator_3.tdms", "Piston actuator G1_3.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "49-PE10_Compression1_4", Array("Actuator Gauge 2 Comp_4.tdms", "Piston Rods Gauge 2 Compr_4.tdms", "Piston - Actuator_4.tdms", "Piston actuator G1_4.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "50-PE10_Compression1_5", Array("Actuator Gauge 2 Comp_5.tdms", "Piston Rods Gauge 2 Compr_5.tdms", "Piston - Actuator_5.tdms", "Piston actuator G1_5.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "51-PE10_Compression1_6", Array("Actuator Gauge 2 Comp_6.tdms", "Piston Rods Gauge 2 Compr_6.tdms", "Piston - Actuator_6.tdms", "Piston actuator G1_6.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "52-PE10_Compression1_7", Array("Actuator Gauge 2 Comp_7.tdms", "Piston Rods Gauge 2 Compr_7.tdms", "Piston - Actuator_7.tdms", "Piston actuator G1_7.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "53-PE10_Compression1_8", Array("Actuator Gauge 2 Comp_8.tdms", "Piston Rods Gauge 2 Compr_8.tdms", "Piston - Actuator_8.tdms", "Piston actuator G1_8.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "54-PE10_Compression1_9", Array("Actuator Gauge 2 Comp_9.tdms", "Piston Rods Gauge 2 Compr_9.tdms", "Piston - Actuator_9.tdms", "Piston actuator G1_9.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 1\", "55-PE10_Compression1_10", Array("Actuator Gauge 2 Comp_10.tdms", "Piston Rods Gauge 2 Compr_10.tdms", "Piston - Actuator_10.tdms", "Piston actuator G1_10.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "56-PE10_Compression2_0", Array("Piston Gauge 1 Compr_0.tdms", "Piston Rods Gauge 2 Compr_0.tdms", "Piston - Actuator_0.tdms", "_0.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "57-PE10_Compression2_1", Array("Piston Gauge 1 Compr_1.tdms", "Piston Rods Gauge 2 Compr_1.tdms", "Piston - Actuator_1.tdms", "_1.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "58-PE10_Compression2_2", Array("Piston Gauge 1 Compr_2.tdms", "Piston Rods Gauge 2 Compr_2.tdms", "Piston - Actuator_2.tdms", "_2.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "59-PE10_Compression2_3", Array("Piston Gauge 1 Compr_3.tdms", "Piston Rods Gauge 2 Compr_3.tdms", "Piston - Actuator_3.tdms", "_3.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "60-PE10_Compression2_4", Array("Piston Gauge 1 Compr_4.tdms", "Piston Rods Gauge 2 Compr_4.tdms", "Piston - Actuator_4.tdms", "_4.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "61-PE10_Compression2_5", Array("Piston Gauge 1 Compr_5.tdms", "Piston Rods Gauge 2 Compr_5.tdms", "Piston - Actuator_5.tdms", "_5.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "62-PE10_Compression2_6", Array("Piston Gauge 1 Compr_6.tdms", "Piston Rods Gauge 2 Compr_6.tdms", "Piston - Actuator_6.tdms", "_6.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "63-PE10_Compression2_7", Array("Piston Gauge 1 Compr_7.tdms", "Piston Rods Gauge 2 Compr_7.tdms", "Piston - Actuator_7.tdms", "_7.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "64-PE10_Compression2_8", Array("Piston Gauge 1 Compr_8.tdms", "Piston Rods Gauge 2 Compr_8.tdms", "Piston - Actuator_8.tdms", "_8.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "65-PE10_Compression2_9", Array("Piston Gauge 1 Compr_9.tdms", "Piston Rods Gauge 2 Compr_9.tdms", "Piston - Actuator_9.tdms", "_9.tdms")) _
    , Array(commonAddress & "Piston eye 2\Compression\Run 2\", "66-PE10_Compression2_10", Array("Piston Gauge 1 Compr_10.tdms", "Piston Rods Gauge 2 Compr_10.tdms", "Piston - Actuator_10.tdms", "_10.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "67-PE10_Tension1_0", Array("Piston Gauge 1 Compr_0.tdms", "Piston Rods Gauge 1 Compr_0.tdms", "Piston - Actuator_0.tdms", "Piston - Actuator G2_0.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "68-PE10_Tension1_1", Array("Piston Gauge 1 Compr_1.tdms", "Piston Rods Gauge 1 Compr_1.tdms", "Piston - Actuator_1.tdms", "Piston - Actuator G2_1.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "69-PE10_Tension1_2", Array("Piston Gauge 1 Compr_2.tdms", "Piston Rods Gauge 1 Compr_2.tdms", "Piston - Actuator_2.tdms", "Piston - Actuator G2_2.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "70-PE10_Tension1_3", Array("Piston Gauge 1 Compr_3.tdms", "Piston Rods Gauge 1 Compr_3.tdms", "Piston - Actuator_3.tdms", "Piston - Actuator G2_3.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "71-PE10_Tension1_4", Array("Piston Gauge 1 Compr_4.tdms", "Piston Rods Gauge 1 Compr_4.tdms", "Piston - Actuator_4.tdms", "Piston - Actuator G2_4.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "72-PE10_Tension1_5", Array("Piston Gauge 1 Compr_5.tdms", "Piston Rods Gauge 1 Compr_5.tdms", "Piston - Actuator_5.tdms", "Piston - Actuator G2_5.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "73-PE10_Tension1_6", Array("Piston Gauge 1 Compr_6.tdms", "Piston Rods Gauge 1 Compr_6.tdms", "Piston - Actuator_6.tdms", "Piston - Actuator G2_6.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "74-PE10_Tension1_7", Array("Piston Gauge 1 Compr_7.tdms", "Piston Rods Gauge 1 Compr_7.tdms", "Piston - Actuator_7.tdms", "Piston - Actuator G2_7.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "75-PE10_Tension1_8", Array("Piston Gauge 1 Compr_8.tdms", "Piston Rods Gauge 1 Compr_8.tdms", "Piston - Actuator_8.tdms", "Piston - Actuator G2_8.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "76-PE10_Tension1_9", Array("Piston Gauge 1 Compr_9.tdms", "Piston Rods Gauge 1 Compr_9.tdms", "Piston - Actuator_9.tdms", "Piston - Actuator G2_9.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 1\", "77-PE10_Tension1_10", Array("Piston Gauge 1 Compr_10.tdms", "Piston Rods Gauge 1 Compr_10.tdms", "Piston - Actuator_10.tdms", "Piston - Actuator G2_10.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "78-PE10_Tension2_0", Array("Piston Gauge 1 Compr_0.tdms", "Piston Gauge 2_0.tdms", "Piston - Actuator_0.tdms", "Piston actuator G2_0.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "79-PE10_Tension2_1", Array("Piston Gauge 1 Compr_1.tdms", "Piston Gauge 2_1.tdms", "Piston - Actuator_1.tdms", "Piston actuator G2_1.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "80-PE10_Tension2_2", Array("Piston Gauge 1 Compr_2.tdms", "Piston Gauge 2_2.tdms", "Piston - Actuator_2.tdms", "Piston actuator G2_2.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "81-PE10_Tension2_3", Array("Piston Gauge 1 Compr_3.tdms", "Piston Gauge 2_3.tdms", "Piston - Actuator_3.tdms", "Piston actuator G2_3.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "82-PE10_Tension2_4", Array("Piston Gauge 1 Compr_4.tdms", "Piston Gauge 2_4.tdms", "Piston - Actuator_4.tdms", "Piston actuator G2_4.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "83-PE10_Tension2_5", Array("Piston Gauge 1 Compr_5.tdms", "Piston Gauge 2_5.tdms", "Piston - Actuator_5.tdms", "Piston actuator G2_5.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "84-PE10_Tension2_6", Array("Piston Gauge 1 Compr_6.tdms", "Piston Gauge 2_6.tdms", "Piston - Actuator_6.tdms", "Piston actuator G2_6.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "85-PE10_Tension2_7", Array("Piston Gauge 1 Compr_7.tdms", "Piston Gauge 2_7.tdms", "Piston - Actuator_7.tdms", "Piston actuator G2_7.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "86-PE10_Tension2_8", Array("Piston Gauge 1 Compr_8.tdms", "Piston Gauge 2_8.tdms", "Piston - Actuator_8.tdms", "Piston actuator G2_8.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "87-PE10_Tension2_9", Array("Piston Gauge 1 Compr_9.tdms", "Piston Gauge 2_9.tdms", "Piston - Actuator_9.tdms", "Piston actuator G2_9.tdms")) _
    , Array(commonAddress & "Piston eye 2\Tension\Run 2\", "88-PE10_Tension2_10", Array("Piston Gauge 1 Compr_10.tdms", "Piston Gauge 2_10.tdms", "Piston - Actuator_10.tdms", "Piston actuator G2_10.tdms")) _
)

' All steps
' 1-Step-1.1,29-Step-1.1-Repeat,2-Step-1.2,3-Step-1.3,30-Step-1.3-Repeat,4-Step-1.4,5-Step-1.5,6-Step-1.6,7-Step-2.4,11-Step-2.4-Repeat,26-Step-2.4-Repeat2,8-Step-2.1-1.5Displ,9-Step-2.1-NeutralPos,10-Step-2.2,12-Step-2.5,13-Step-2.6-1,14-Step-2.6-2,15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,19-Step-3.2-1,20-Step-3.2-2,27-Step-3.2-hot,28-Step-3.2-cold,21-Step-3.3-1,22-Step-3.3-2,23-Step-3.4-1,24-Step-3.4-2,25-Step-3.4-3,31-Step-3.7-1,32-Step-3.7-2,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot,39-Step-3.1-50FH-cold,40-Step-3.1-50FH-hot,41-Step-3.2-50FH-cold-1,42-Step-3.2-50FH-cold-2,43-Step-3.2-50FH-hot,44-Step-3.1-60FH-cold,45-Step-3.1-60FH-hot
' The variable iterators is used to load and operate only selected steps from above

' iterators = Array("57-Step-3.2-80FH-cold", "58-Step-3.2-80FH-hot", "59-Step-3.1-90FH-cold", "60-Step-3.1-90FH-hot")
' iterators = Array("1-LOWTEMP_Step_1.2", "2-LOWTEMP_Step_1.1", "3-LOWTEMP_Step_1.2")
iterators = Array(_
    "1-PE9_Compression1_0" _
  , "2-PE9_Compression1_1" _
  , "3-PE9_Compression1_2" _
  , "4-PE9_Compression1_3" _
  , "5-PE9_Compression1_4" _
  , "6-PE9_Compression1_5" _
  , "7-PE9_Compression1_6" _
  , "8-PE9_Compression1_7" _
  , "9-PE9_Compression1_8" _
  , "10-PE9_Compression1_9" _
  , "11-PE9_Compression1_10" _
  , "12-PE9_Compression2_0" _
  , "13-PE9_Compression2_1" _
  , "14-PE9_Compression2_2" _
  , "15-PE9_Compression2_3" _
  , "16-PE9_Compression2_4" _
  , "17-PE9_Compression2_5" _
  , "18-PE9_Compression2_6" _
  , "19-PE9_Compression2_7" _
  , "20-PE9_Compression2_8" _
  , "21-PE9_Compression2_9" _
  , "22-PE9_Compression2_10" _
  , "23-PE9_Tension1_0" _
  , "24-PE9_Tension1_1" _
  , "25-PE9_Tension1_2" _
  , "26-PE9_Tension1_3" _
  , "27-PE9_Tension1_4" _
  , "28-PE9_Tension1_5" _
  , "29-PE9_Tension1_6" _
  , "30-PE9_Tension1_7" _
  , "31-PE9_Tension1_8" _
  , "32-PE9_Tension1_9" _
  , "33-PE9_Tension1_10" _
  , "34-PE9_Tension2_0" _
  , "35-PE9_Tension2_1" _
  , "36-PE9_Tension2_2" _
  , "37-PE9_Tension2_3" _
  , "38-PE9_Tension2_4" _
  , "39-PE9_Tension2_5" _
  , "40-PE9_Tension2_6" _
  , "41-PE9_Tension2_7" _
  , "42-PE9_Tension2_8" _
  , "43-PE9_Tension2_9" _
  , "44-PE9_Tension2_10" _
  , "45-PE10_Compression1_0" _
  , "46-PE10_Compression1_1" _
  , "47-PE10_Compression1_2" _
  , "48-PE10_Compression1_3" _
  , "49-PE10_Compression1_4" _
  , "50-PE10_Compression1_5" _
  , "51-PE10_Compression1_6" _
  , "52-PE10_Compression1_7" _
  , "53-PE10_Compression1_8" _
  , "54-PE10_Compression1_9" _
  , "55-PE10_Compression1_10" _
  , "56-PE10_Compression2_0" _
  , "57-PE10_Compression2_1" _
  , "58-PE10_Compression2_2" _
  , "59-PE10_Compression2_3" _
  , "60-PE10_Compression2_4" _
  , "61-PE10_Compression2_5" _
  , "62-PE10_Compression2_6" _
  , "63-PE10_Compression2_7" _
  , "64-PE10_Compression2_8" _
  , "65-PE10_Compression2_9" _
  , "66-PE10_Compression2_10" _
  , "67-PE10_Tension1_0" _
  , "68-PE10_Tension1_1" _
  , "69-PE10_Tension1_2" _
  , "70-PE10_Tension1_3" _
  , "71-PE10_Tension1_4" _
  , "72-PE10_Tension1_5" _
  , "73-PE10_Tension1_6" _
  , "74-PE10_Tension1_7" _
  , "75-PE10_Tension1_8" _
  , "76-PE10_Tension1_9" _
  , "77-PE10_Tension1_10" _
  , "78-PE10_Tension2_0" _
  , "79-PE10_Tension2_1" _
  , "80-PE10_Tension2_2" _
  , "81-PE10_Tension2_3" _
  , "82-PE10_Tension2_4" _
  , "83-PE10_Tension2_5" _
  , "84-PE10_Tension2_6" _
  , "85-PE10_Tension2_7" _
  , "86-PE10_Tension2_8" _
  , "87-PE10_Tension2_9" _
  , "88-PE10_Tension2_10" _
)

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Load Cell", "Force"
dictVaDiadem.Add "STG", "STG"

newFreq = 3000 'Hz'

loadScript_resampleFlag = True
loadScript_saveFlagResampledDataCSV = True 'possible values: True or False
loadScript_saveAllDataFlagPerStep = False 'possible values: True or False
loadScript_saveFlagResampledDataTDM = False 'possible values: True or False

' Post-processing
fileNameWithoutIterator_pre = "resampled"
fileNameWithoutIterator_post = "__"&newFreq&"Hz__step" '+iterator 
fileFormatImport = ".TDM"

filterFreq = 0.1 'Hz'

' Executiong flags
importDataFlag = True

FlagFTTData = False

FlagFilteredData = False
FlagHighPass = True 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False