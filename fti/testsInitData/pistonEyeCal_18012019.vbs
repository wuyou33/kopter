Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
' workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
workingFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019_highSamplRate\"

' Where the data will be saved in csv format
' csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019\"
csvFolder = "P:\11_J67\16_FTI\pistonEyeCal_18012019_highSamplRate\"

' filesNames = Array("Force_Piston_Eye_HP1_[N].tdms", "Force_Piston_Eye_HP2_[N].tdms")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "L:\MSH\13_Testing+Instrumentation\FTI\18_Calibration\AD_Bench Tests\2019_01_18_PistonEye_Actuator_SN17&18\"
fileNamesBigArrayFolders = Array( _
     Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 1\", "1-PE17_Tension1_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 1\", "2-PE17_Tension1_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 1\", "3-PE17_Tension1_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 1\", "4-PE17_Tension1_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 1\", "5-PE17_Tension1_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 1\", "6-PE17_Tension1_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 1\", "7-PE17_Tension1_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 2\", "8-PE17_Tension2_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 2\", "9-PE17_Tension2_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 2\", "10-PE17_Tension2_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 2\", "11-PE17_Tension2_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 2\", "12-PE17_Tension2_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 2\", "13-PE17_Tension2_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 2\", "14-PE17_Tension2_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 3\", "15-PE17_Tension3_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 3\", "16-PE17_Tension3_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 3\", "17-PE17_Tension3_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 3\", "18-PE17_Tension3_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 3\", "19-PE17_Tension3_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 3\", "20-PE17_Tension3_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Tension Analysis\Piston Eye Tension 3\", "21-PE17_Tension3_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 1\", "22-PE17_Compression1_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 1\", "23-PE17_Compression1_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 1\", "24-PE17_Compression1_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 1\", "25-PE17_Compression1_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 1\", "26-PE17_Compression1_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 1\", "27-PE17_Compression1_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 1\", "28-PE17_Compression1_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 2\", "29-PE17_Compression2_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 2\", "30-PE17_Compression2_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 2\", "31-PE17_Compression2_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 2\", "32-PE17_Compression2_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 2\", "33-PE17_Compression2_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 2\", "34-PE17_Compression2_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 2\", "35-PE17_Compression2_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 3\", "36-PE17_Compression3_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 3\", "37-PE17_Compression3_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 3\", "38-PE17_Compression3_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 3\", "39-PE17_Compression3_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 3\", "40-PE17_Compression3_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 3\", "41-PE17_Compression3_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 17\Compression Analysis\Piston Eye Compression 3\", "42-PE17_Compression3_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 1\", "43-PE18_Tension1_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 1\", "44-PE18_Tension1_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 1\", "45-PE18_Tension1_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 1\", "46-PE18_Tension1_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 1\", "47-PE18_Tension1_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 1\", "48-PE18_Tension1_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 1\", "49-PE18_Tension1_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 2\", "50-PE18_Tension2_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 2\", "51-PE18_Tension2_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 2\", "52-PE18_Tension2_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 2\", "53-PE18_Tension2_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 2\", "54-PE18_Tension2_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 2\", "55-PE18_Tension2_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 2\", "56-PE18_Tension2_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 3\", "57-PE18_Tension3_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 3\", "58-PE18_Tension3_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 3\", "59-PE18_Tension3_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 3\", "60-PE18_Tension3_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 3\", "61-PE18_Tension3_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 3\", "62-PE18_Tension3_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Tension Analysis\Piston Eye Tension 3\", "63-PE18_Tension3_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 1\", "64-PE18_Compression1_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 1\", "65-PE18_Compression1_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 1\", "66-PE18_Compression1_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 1\", "67-PE18_Compression1_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 1\", "68-PE18_Compression1_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 1\", "69-PE18_Compression1_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 1\", "70-PE18_Compression1_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 2\", "71-PE18_Compression2_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 2\", "72-PE18_Compression2_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 2\", "73-PE18_Compression2_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 2\", "74-PE18_Compression2_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 2\", "75-PE18_Compression2_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 2\", "76-PE18_Compression2_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 2\", "77-PE18_Compression2_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 3\", "78-PE18_Compression3_1", Array("Piston eye _0.tdms", "Piston eye_0.tdms", "Piston Eye _0.tdms", "Piston Eye_0.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 3\", "79-PE18_Compression3_2", Array("Piston eye _1.tdms", "Piston eye_1.tdms", "Piston Eye _1.tdms", "Piston Eye_1.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 3\", "80-PE18_Compression3_3", Array("Piston eye _2.tdms", "Piston eye_2.tdms", "Piston Eye _2.tdms", "Piston Eye_2.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 3\", "81-PE18_Compression3_4", Array("Piston eye _3.tdms", "Piston eye_3.tdms", "Piston Eye _3.tdms", "Piston Eye_3.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 3\", "82-PE18_Compression3_5", Array("Piston eye _4.tdms", "Piston eye_4.tdms", "Piston Eye _4.tdms", "Piston Eye_4.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 3\", "83-PE18_Compression3_6", Array("Piston eye _5.tdms", "Piston eye_5.tdms", "Piston Eye _5.tdms", "Piston Eye_5.tdms")) _
  ,  Array(commonAddress & "Piston Eye 18\Compression Analysis\Piston Eye Compression 3\", "84-PE18_Compression3_7", Array("Piston eye _6.tdms", "Piston eye_6.tdms", "Piston Eye _6.tdms", "Piston Eye_6.tdms")) _
)

' All steps
' 1-Step-1.1,29-Step-1.1-Repeat,2-Step-1.2,3-Step-1.3,30-Step-1.3-Repeat,4-Step-1.4,5-Step-1.5,6-Step-1.6,7-Step-2.4,11-Step-2.4-Repeat,26-Step-2.4-Repeat2,8-Step-2.1-1.5Displ,9-Step-2.1-NeutralPos,10-Step-2.2,12-Step-2.5,13-Step-2.6-1,14-Step-2.6-2,15-Step-3.1-1,16-Step-3.1-2,17-Step-3.1-3,18-Step-3.1-4,19-Step-3.2-1,20-Step-3.2-2,27-Step-3.2-hot,28-Step-3.2-cold,21-Step-3.3-1,22-Step-3.3-2,23-Step-3.4-1,24-Step-3.4-2,25-Step-3.4-3,31-Step-3.7-1,32-Step-3.7-2,33-Step-3.1-40FH-cold-1,34-Step-3.1-40FH-cold-2,35-Step-3.1-40FH-hot,36-Step-3.2-40FH-cold-1,37-Step-3.2-40FH-cold-2,38-Step-3.2-40FH-hot,39-Step-3.1-50FH-cold,40-Step-3.1-50FH-hot,41-Step-3.2-50FH-cold-1,42-Step-3.2-50FH-cold-2,43-Step-3.2-50FH-hot,44-Step-3.1-60FH-cold,45-Step-3.1-60FH-hot
' The variable iterators is used to load and operate only selected steps from above

' iterators = Array("57-Step-3.2-80FH-cold", "58-Step-3.2-80FH-hot", "59-Step-3.1-90FH-cold", "60-Step-3.1-90FH-hot")
' iterators = Array("1-LOWTEMP_Step_1.2", "2-LOWTEMP_Step_1.1", "3-LOWTEMP_Step_1.2")
iterators = Array(_
              "1-PE17_Tension1_1" _
             , "2-PE17_Tension1_2" _
             , "3-PE17_Tension1_3" _
             , "4-PE17_Tension1_4" _
             , "5-PE17_Tension1_5" _
             , "6-PE17_Tension1_6" _
             , "7-PE17_Tension1_7" _
             , "8-PE17_Tension2_1" _
             , "9-PE17_Tension2_2" _
             , "10-PE17_Tension2_3" _
             , "11-PE17_Tension2_4" _
             , "12-PE17_Tension2_5" _
             , "13-PE17_Tension2_6" _
             , "14-PE17_Tension2_7" _
             , "15-PE17_Tension3_1" _
             , "16-PE17_Tension3_2" _
             , "17-PE17_Tension3_3" _
             , "18-PE17_Tension3_4" _
             , "19-PE17_Tension3_5" _
             , "20-PE17_Tension3_6" _
             , "21-PE17_Tension3_7" _
             , "22-PE17_Compression1_1" _
             , "23-PE17_Compression1_2" _
             , "24-PE17_Compression1_3" _
             , "25-PE17_Compression1_4" _
             , "26-PE17_Compression1_5" _
             , "27-PE17_Compression1_6" _
             , "28-PE17_Compression1_7" _
             , "29-PE17_Compression2_1" _
             , "30-PE17_Compression2_2" _
             , "31-PE17_Compression2_3" _
             , "32-PE17_Compression2_4" _
             , "33-PE17_Compression2_5" _
             , "34-PE17_Compression2_6" _
             , "35-PE17_Compression2_7" _
             , "36-PE17_Compression3_1" _
             , "37-PE17_Compression3_2" _
             , "38-PE17_Compression3_3" _
             , "39-PE17_Compression3_4" _
             , "40-PE17_Compression3_5" _
             , "41-PE17_Compression3_6" _
             , "42-PE17_Compression3_7" _
             , "43-PE18_Tension1_1" _
             , "44-PE18_Tension1_2" _
             , "45-PE18_Tension1_3" _
             , "46-PE18_Tension1_4" _
             , "47-PE18_Tension1_5" _
             , "48-PE18_Tension1_6" _
             , "49-PE18_Tension1_7" _
             , "50-PE18_Tension2_1" _
             , "51-PE18_Tension2_2" _
             , "52-PE18_Tension2_3" _
             , "53-PE18_Tension2_4" _
             , "54-PE18_Tension2_5" _
             , "55-PE18_Tension2_6" _
             , "56-PE18_Tension2_7" _
             , "57-PE18_Tension3_1" _
             , "58-PE18_Tension3_2" _
             , "59-PE18_Tension3_3" _
             , "60-PE18_Tension3_4" _
             , "61-PE18_Tension3_5" _
             , "62-PE18_Tension3_6" _
             , "63-PE18_Tension3_7" _
             , "64-PE18_Compression1_1" _
             , "65-PE18_Compression1_2" _
             , "66-PE18_Compression1_3" _
             , "67-PE18_Compression1_4" _
             , "68-PE18_Compression1_5" _
             , "69-PE18_Compression1_6" _
             , "70-PE18_Compression1_7" _
             , "71-PE18_Compression2_1" _
             , "72-PE18_Compression2_2" _
             , "73-PE18_Compression2_3" _
             , "74-PE18_Compression2_4" _
             , "75-PE18_Compression2_5" _
             , "76-PE18_Compression2_6" _
             , "77-PE18_Compression2_7" _
             , "78-PE18_Compression3_1" _
             , "79-PE18_Compression3_2" _
             , "80-PE18_Compression3_3" _
             , "81-PE18_Compression3_4" _
             , "82-PE18_Compression3_5" _
             , "83-PE18_Compression3_6" _
             , "84-PE18_Compression3_7" _
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