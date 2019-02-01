Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
' workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_26042018\"

' Where the data will be saved in csv format
' csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_26042018\"

' filesNames = Array("Force_Piston_Eye_HP1_[N].tdms", "Force_Piston_Eye_HP2_[N].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH\13_Testing+Instrumentation\FTI\18_Calibration\AB_P3\2018_04_26_Yaw actuator force\"
fileNamesBigArrayFolders = Array( _
     Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "1-PE05_Compression1_0", Array("TR Actuator Force_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "2-PE05_Compression1_1", Array("TR Actuator Force_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "3-PE05_Compression1_2", Array("TR Actuator Force_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "4-PE05_Compression1_3", Array("TR Actuator Force_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "5-PE05_Compression1_4", Array("TR Actuator Force_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "6-PE05_Compression1_5", Array("TR Actuator Force_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "7-PE05_Compression1_6", Array("TR Actuator Force_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "8-PE05_Compression1_7", Array("TR Actuator Force_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "9-PE05_Compression1_8", Array("TR Actuator Force_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "10-PE05_Compression1_9", Array("TR Actuator Force_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "11-PE05_Compression1_10", Array("TR Actuator Force_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "12-PE05_Compression1_11", Array("TR Actuator Force_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 1\", "13-PE05_Compression1_12", Array("TR Actuator Force_12.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "14-PE05_Compression2_0", Array("TR Actuator Force_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "15-PE05_Compression2_1", Array("TR Actuator Force_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "16-PE05_Compression2_2", Array("TR Actuator Force_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "17-PE05_Compression2_3", Array("TR Actuator Force_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "18-PE05_Compression2_4", Array("TR Actuator Force_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "19-PE05_Compression2_5", Array("TR Actuator Force_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "20-PE05_Compression2_6", Array("TR Actuator Force_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "21-PE05_Compression2_7", Array("TR Actuator Force_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "22-PE05_Compression2_8", Array("TR Actuator Force_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "23-PE05_Compression2_9", Array("TR Actuator Force_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "24-PE05_Compression2_10", Array("TR Actuator Force_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "25-PE05_Compression2_11", Array("TR Actuator Force_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Compression\Run 2\", "26-PE05_Compression2_12", Array("TR Actuator Force_12.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "27-PE05_Tension1_0", Array("TR Actuator Force_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "28-PE05_Tension1_1", Array("TR Actuator Force_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "29-PE05_Tension1_2", Array("TR Actuator Force_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "30-PE05_Tension1_3", Array("TR Actuator Force_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "31-PE05_Tension1_4", Array("TR Actuator Force_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "32-PE05_Tension1_5", Array("TR Actuator Force_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "33-PE05_Tension1_6", Array("TR Actuator Force_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "34-PE05_Tension1_7", Array("TR Actuator Force_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "35-PE05_Tension1_8", Array("TR Actuator Force_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "36-PE05_Tension1_9", Array("TR Actuator Force_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "37-PE05_Tension1_10", Array("TR Actuator Force_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "38-PE05_Tension1_11", Array("TR Actuator Force_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 1\", "39-PE05_Tension1_12", Array("TR Actuator Force_12.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "40-PE05_Tension2_0", Array("TR Actuator Force_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "41-PE05_Tension2_1", Array("TR Actuator Force_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "42-PE05_Tension2_2", Array("TR Actuator Force_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "43-PE05_Tension2_3", Array("TR Actuator Force_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "44-PE05_Tension2_4", Array("TR Actuator Force_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "45-PE05_Tension2_5", Array("TR Actuator Force_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "46-PE05_Tension2_6", Array("TR Actuator Force_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "47-PE05_Tension2_7", Array("TR Actuator Force_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "48-PE05_Tension2_8", Array("TR Actuator Force_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "49-PE05_Tension2_9", Array("TR Actuator Force_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "50-PE05_Tension2_10", Array("TR Actuator Force_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "51-PE05_Tension2_11", Array("TR Actuator Force_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN5 (blue wire)\Tension\Run 2\", "52-PE05_Tension2_12", Array("TR Actuator Force_12.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "53-PE06_Compression1_0", Array("TR Actuator Force_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "54-PE06_Compression1_1", Array("TR Actuator Force_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "55-PE06_Compression1_2", Array("TR Actuator Force_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "56-PE06_Compression1_3", Array("TR Actuator Force_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "57-PE06_Compression1_4", Array("TR Actuator Force_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "58-PE06_Compression1_5", Array("TR Actuator Force_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "59-PE06_Compression1_6", Array("TR Actuator Force_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "60-PE06_Compression1_7", Array("TR Actuator Force_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "61-PE06_Compression1_8", Array("TR Actuator Force_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "62-PE06_Compression1_9", Array("TR Actuator Force_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "63-PE06_Compression1_10", Array("TR Actuator Force_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "64-PE06_Compression1_11", Array("TR Actuator Force_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 1\", "65-PE06_Compression1_12", Array("TR Actuator Force_12.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "66-PE06_Compression2_0", Array("TR Actuator Force_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "67-PE06_Compression2_1", Array("TR Actuator Force_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "68-PE06_Compression2_2", Array("TR Actuator Force_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "69-PE06_Compression2_3", Array("TR Actuator Force_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "70-PE06_Compression2_4", Array("TR Actuator Force_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "71-PE06_Compression2_5", Array("TR Actuator Force_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "72-PE06_Compression2_6", Array("TR Actuator Force_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "73-PE06_Compression2_7", Array("TR Actuator Force_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "74-PE06_Compression2_8", Array("TR Actuator Force_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "75-PE06_Compression2_9", Array("TR Actuator Force_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "76-PE06_Compression2_10", Array("TR Actuator Force_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "77-PE06_Compression2_11", Array("TR Actuator Force_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Compression\Run 2\", "78-PE06_Compression2_12", Array("TR Actuator Force_12.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "79-PE06_Tension1_0", Array("Piston rod_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "80-PE06_Tension1_1", Array("Piston rod_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "81-PE06_Tension1_2", Array("Piston rod_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "82-PE06_Tension1_3", Array("Piston rod_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "83-PE06_Tension1_4", Array("Piston rod_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "84-PE06_Tension1_5", Array("Piston rod_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "85-PE06_Tension1_6", Array("Piston rod_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "86-PE06_Tension1_7", Array("Piston rod_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "87-PE06_Tension1_8", Array("Piston rod_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "88-PE06_Tension1_9", Array("Piston rod_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "89-PE06_Tension1_10", Array("Piston rod_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "90-PE06_Tension1_11", Array("Piston rod_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 1\", "91-PE06_Tension1_12", Array("Piston rod_12.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "92-PE06_Tension2_0", Array("Piston rod_0.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "93-PE06_Tension2_1", Array("Piston rod_1.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "94-PE06_Tension2_2", Array("Piston rod_2.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "95-PE06_Tension2_3", Array("Piston rod_3.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "96-PE06_Tension2_4", Array("Piston rod_4.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "97-PE06_Tension2_5", Array("Piston rod_5.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "98-PE06_Tension2_6", Array("Piston rod_6.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "99-PE06_Tension2_7", Array("Piston rod_7.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "100-PE06_Tension2_8", Array("Piston rod_8.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "101-PE06_Tension2_9", Array("Piston rod_9.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "102-PE06_Tension2_10", Array("Piston rod_10.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "103-PE06_Tension2_11", Array("Piston rod_11.tdms")) _
  ,  Array(commonAddress & "1200-1033063-AA SN6 (red wire)\Tension\Run 2\", "104-PE06_Tension2_12", Array("Piston rod_12.tdms")) _
)

' All steps
' 1-Step-1.1,29-Step-1.1-Repeat,2-Step-1.2,3-Step-1.3,30-Step-1.3-Repeat,4-Step-1.4,5-Step-1.5,6-Step-1.6,7-Step-2.4,11-Step-2.4-Repeat,26-Step-2.4-Repeat2,8-Step-2.1-1.5Displ,9-Step-2.1-NeutralPos,10-Step-2.2,12-Step-2.5,13-Step-2.6-1,14-Step-2.6-2,15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,19-Step-3.2-1,20-Step-3.2-2,27-Step-3.2-hot,28-Step-3.2-cold,21-Step-3.3-1,22-Step-3.3-2,23-Step-3.4-1,24-Step-3.4-2,25-Step-3.4-3,31-Step-3.7-1,32-Step-3.7-2,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot,39-Step-3.1-50FH-cold,40-Step-3.1-50FH-hot,41-Step-3.2-50FH-cold-1,42-Step-3.2-50FH-cold-2,43-Step-3.2-50FH-hot,44-Step-3.1-60FH-cold,45-Step-3.1-60FH-hot
' The variable iterators is used to load and operate only selected steps from above

' iterators = Array("57-Step-3.2-80FH-cold", "58-Step-3.2-80FH-hot", "59-Step-3.1-90FH-cold", "60-Step-3.1-90FH-hot")
' iterators = Array("1-LOWTEMP_Step_1.2", "2-LOWTEMP_Step_1.1", "3-LOWTEMP_Step_1.2")
iterators = Array(_
               "1-PE05_Compression1_0"_
             , "2-PE05_Compression1_1"_
             , "3-PE05_Compression1_2"_
             , "4-PE05_Compression1_3"_
             , "5-PE05_Compression1_4"_
             , "6-PE05_Compression1_5"_
             , "7-PE05_Compression1_6"_
             , "8-PE05_Compression1_7"_
             , "9-PE05_Compression1_8"_
             , "10-PE05_Compression1_9"_
             , "11-PE05_Compression1_10"_
             , "12-PE05_Compression1_11"_
             , "13-PE05_Compression1_12"_
             , "14-PE05_Compression2_0"_
             , "15-PE05_Compression2_1"_
             , "16-PE05_Compression2_2"_
             , "17-PE05_Compression2_3"_
             , "18-PE05_Compression2_4"_
             , "19-PE05_Compression2_5"_
             , "20-PE05_Compression2_6"_
             , "21-PE05_Compression2_7"_
             , "22-PE05_Compression2_8"_
             , "23-PE05_Compression2_9"_
             , "24-PE05_Compression2_10"_
             , "25-PE05_Compression2_11"_
             , "26-PE05_Compression2_12"_
             , "27-PE05_Tension1_0"_
             , "28-PE05_Tension1_1"_
             , "29-PE05_Tension1_2"_
             , "30-PE05_Tension1_3"_
             , "31-PE05_Tension1_4"_
             , "32-PE05_Tension1_5"_
             , "33-PE05_Tension1_6"_
             , "34-PE05_Tension1_7"_
             , "35-PE05_Tension1_8"_
             , "36-PE05_Tension1_9"_
             , "37-PE05_Tension1_10"_
             , "38-PE05_Tension1_11"_
             , "39-PE05_Tension1_12"_
             , "40-PE05_Tension2_0"_
             , "41-PE05_Tension2_1"_
             , "42-PE05_Tension2_2"_
             , "43-PE05_Tension2_3"_
             , "44-PE05_Tension2_4"_
             , "45-PE05_Tension2_5"_
             , "46-PE05_Tension2_6"_
             , "47-PE05_Tension2_7"_
             , "48-PE05_Tension2_8"_
             , "49-PE05_Tension2_9"_
             , "50-PE05_Tension2_10"_
             , "51-PE05_Tension2_11"_
             , "52-PE05_Tension2_12"_
             , "53-PE06_Compression1_0"_
             , "54-PE06_Compression1_1"_
             , "55-PE06_Compression1_2"_
             , "56-PE06_Compression1_3"_
             , "57-PE06_Compression1_4"_
             , "58-PE06_Compression1_5"_
             , "59-PE06_Compression1_6"_
             , "60-PE06_Compression1_7"_
             , "61-PE06_Compression1_8"_
             , "62-PE06_Compression1_9"_
             , "63-PE06_Compression1_10"_
             , "64-PE06_Compression1_11"_
             , "65-PE06_Compression1_12"_
             , "66-PE06_Compression2_0"_
             , "67-PE06_Compression2_1"_
             , "68-PE06_Compression2_2"_
             , "69-PE06_Compression2_3"_
             , "70-PE06_Compression2_4"_
             , "71-PE06_Compression2_5"_
             , "72-PE06_Compression2_6"_
             , "73-PE06_Compression2_7"_
             , "74-PE06_Compression2_8"_
             , "75-PE06_Compression2_9"_
             , "76-PE06_Compression2_10"_
             , "77-PE06_Compression2_11"_
             , "78-PE06_Compression2_12"_
             , "79-PE06_Tension1_0"_
             , "80-PE06_Tension1_1"_
             , "81-PE06_Tension1_2"_
             , "82-PE06_Tension1_3"_
             , "83-PE06_Tension1_4"_
             , "84-PE06_Tension1_5"_
             , "85-PE06_Tension1_6"_
             , "86-PE06_Tension1_7"_
             , "87-PE06_Tension1_8"_
             , "88-PE06_Tension1_9"_
             , "89-PE06_Tension1_10"_
             , "90-PE06_Tension1_11"_
             , "91-PE06_Tension1_12"_
             , "92-PE06_Tension2_0"_
             , "93-PE06_Tension2_1"_
             , "94-PE06_Tension2_2"_
             , "95-PE06_Tension2_3"_
             , "96-PE06_Tension2_4"_
             , "97-PE06_Tension2_5"_
             , "98-PE06_Tension2_6"_
             , "99-PE06_Tension2_7"_
             , "100-PE06_Tension2_8"_
             , "101-PE06_Tension2_9"_
             , "102-PE06_Tension2_10"_
             , "103-PE06_Tension2_11"_
             , "104-PE06_Tension2_12"_
)

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "Load Cell", "Force"
dictVaDiadem.Add "STG", "STG"

newFreq = 5000 'Hz'

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