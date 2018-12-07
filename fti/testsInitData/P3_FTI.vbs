Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "P:\12_flightTestData\P3-all\"

' Where the data will be saved in csv format
csvFolder = "P:\12_flightTestData\P3-all\"
' csvFolder = "P:\12_flightTestData\P3-all_smallSamplingRate\"

' filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
'                   , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
'                   , "Force_Piston_Eye_HP2_[N].tdms", "Input_force_[N].tdms", "Laser_Piston_[mm].tdms"_
'                   , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_[N].tdms", "Temperatur_HP_1_[degC].TDM", "Temperatur_HP_2_[degC].TDM")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "G:\FTI\ProcData\SKYeSH09\P3\J17-Test Data\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_120203\", "1-RC", Array("fti_2018-08-22_120203_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_125159\", "2-RC", Array("fti_2018-08-22_125159_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_142002\", "3-RC", Array("fti_2018-08-22_142002_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_164658\", "4-RC", Array("fti_2018-08-22_164658_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_172647\", "5-RC", Array("fti_2018-08-22_172647_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_183631\", "6-RC", Array("fti_2018-08-22_183631_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-001\FTI\fti_2018-08-24_131313\", "7-GR01", Array("fti_2018-08-24_131313_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-002\FTI\fti_2018-08-28_142034\", "8-GR02", Array("fti_2018-08-28_142034_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-002\FTI\fti_2018-08-28_151046\", "9-GR02", Array("fti_2018-08-28_151046_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-003\FTI\fti_2018-08-29_140143\", "10-GR03", Array("fti_2018-08-29_140143_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-003-001_Controls_Calib\FTI\fti_2018-08-30_080725\", "11-GR03", Array("fti_2018-08-30_080725_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-003-002_Tailboom_lifting\FTI\fti_2018-08-30_121543\", "12-GR03", Array("fti_2018-08-30_121543_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-004\FTI\fti_2018-09-03_142731\", "13-GR04", Array("fti_2018-09-03_142731_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_084730\", "14-GR05", Array("fti_2018-09-04_084730_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_091732\", "15-GR05", Array("fti_2018-09-04_091732_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_093052\", "16-GR05", Array("fti_2018-09-04_093052_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_094719\", "17-GR05", Array("fti_2018-09-04_094719_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_113847\", "18-GR05", Array("fti_2018-09-04_113847_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_121001\", "19-GR05", Array("fti_2018-09-04_121001_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_131902\", "20-GR05", Array("fti_2018-09-04_131902_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_141625\", "21-GR05", Array("fti_2018-09-04_141625_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_145011\", "22-GR05", Array("fti_2018-09-04_145011_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run1\", "23-GR06", Array("fti_20180907144446_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run2\", "24-GR06", Array("fti_20180907155328_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run3\", "25-GR06", Array("fti_20180907162445_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run4\", "26-GR06", Array("fti_20180907165135_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run5\", "27-GR06", Array("fti_20180907171544_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006-001 Helicopter_taxiing\FTI\Run1\", "28-GR06", Array("fti_20180907154101_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run1\", "29-GR07", Array("fti_20180910132019_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run2\", "30-GR07", Array("fti_20180910134511_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run3\", "31-GR07", Array("fti_20180910141117_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run4\", "32-GR07", Array("fti_20180910143205_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run5\", "33-GR07", Array("fti_20180910151302_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-008\FTI\Run1\", "34-GR08", Array("fti_20180911113815_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run1\", "35-GR09", Array("fti_20180913075811_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run2\", "36-GR09", Array("fti_20180913083809_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run3\", "37-GR09", Array("fti_20180913090710_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run4\", "38-GR09", Array("fti_20180913093446_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run5\", "39-GR09", Array("fti_20180913111618_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run6\", "40-GR09", Array("fti_20180913115747_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run7\", "41-GR09", Array("fti_20180913123210_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run7\", "42-GR09", Array("fti_20180913124359_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run8\", "43-GR09", Array("fti_20180913130147_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run9\", "44-GR09", Array("fti_20180913133257_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run10\", "45-GR09", Array("fti_20180913135522_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run11\", "46-GR09", Array("fti_20180913141742_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009-001_Controls_Range\FTI\Run1\", "47-GR09", Array("fti_20180914100758_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009-001_Controls_Range\FTI\Run2\", "48-GR09", Array("fti_20180914101252_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010\FTI\Run1\", "49-GR10", Array("fti_20180919114150_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010\FTI\Run2\", "50-GR10", Array("fti_20180919135017_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010\FTI\Run3\", "51-GR10", Array("fti_20180919144847_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010-001_Blade_sanity_check\FTI\Run1\", "52-GR10", Array("fti_20180924080500_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010-001_Blade_sanity_check\FTI\Run2\", "53-GR10", Array("fti_20180924083505_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010-001_Blade_sanity_check\FTI\Run3\", "54-GR10", Array("fti_20180924084201_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010-002_Shake_Test\FTI\Run1\", "55-GR10", Array("fti_20180924134556_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010-002_Shake_Test\FTI\Run2\", "56-GR10", Array("fti_20180924134740_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-011\FTI\Run1\", "57-GR11", Array("fti_20180924141158_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-011\FTI\Run2\", "58-GR11", Array("fti_20180924144658_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-011\FTI\Run3\", "59-GR11", Array("fti_20180924150900_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-011\FTI\Run4\", "60-GR11", Array("fti_20180924153904_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-011\FTI\Run5\", "61-GR11", Array("fti_20180924160201_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-012\FTI\Run1\", "62-GR12", Array("fti_20180925082126_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-012\FTI\Run2\", "63-GR12", Array("fti_20180925084718_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-012\FTI\Run3\", "64-GR12", Array("fti_20180925090833_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-012\FTI\Run4\", "65-GR12", Array("fti_20180925093504_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-012\FTI\Run5\", "66-GR12", Array("fti_20180925095743_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-013\FTI\Run1\", "67-GR13", Array("fti_20180925123104_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-013\FTI\Run2\", "68-GR13", Array("fti_20180925135626_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-013-001_Shake_Test\FTI\Run1\", "69-GR13", Array("fti_20180926113630_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-014\FTI\Run1\", "70-GR14", Array("fti_20180926114703_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-014\FTI\Run2\", "71-GR14", Array("fti_20180926120604_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-014-001_Shake_Test\FTI\Run1\", "72-GR14", Array("fti_20180927083621_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-014-001_Shake_Test\FTI\Run2\", "73-GR14", Array("fti_20180927083843_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-015\FTI\Run1\", "74-GR15", Array("fti_20180927084214_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-015\FTI\Run2\", "75-GR15", Array("fti_20180927094742_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-016\FTI\Run1\", "76-GR16", Array("fti_20180928093132_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-017\FTI\Run1\", "77-GR17", Array("fti_20180929075300_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-017\FTI\Run2\", "78-GR17", Array("fti_20180929081130_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-018\FTI\Run1\", "79-GR18", Array("fti_20181002122121_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-018\FTI\Run2\", "80-GR18", Array("fti_20181002124416_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-018\FTI\Run3\", "81-GR18", Array("fti_20181002141033_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-019\FTI\Run1\", "82-GR19", Array("fti_20181003141138_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-019\FTI\Run2\", "83-GR19", Array("fti_20181003150150_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-020\FTI\Run1\", "84-GR20", Array("fti_20181004123543_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-020\FTI\Run2\", "85-GR20", Array("fti_20181004141626_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-021\FTI\Run1\", "86-GR21", Array("fti_20181005131723_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-022\FTI\Run1\", "87-GR22", Array("fti_20181019090234_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-022\FTI\Run2\", "88-GR22", Array("fti_20181019094749_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-022\FTI\Run3\", "89-GR22", Array("fti_20181019112117_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-022\FTI\Run4\", "90-GR22", Array("fti_20181019121827_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-022-001_Pitot_Check\FTI\Run1\", "91-GR22", Array("fti_20181023135013_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-022-002_Rigging\FTI\Run1\", "92-GR22", Array("fti_20181027160430_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-023\FTI\Run1\", "93-GR23", Array("fti_20181105135103_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-023\FTI\Run2\", "94-GR23", Array("fti_20181105150001_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-023\FTI\Run3\", "95-GR23", Array("fti_20181105164059_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-024\FTI\Run1\", "96-GR24", Array("fti_20181106141007_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-024\FTI\Run2\", "97-GR24", Array("fti_20181106162305_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-025\FTI\Run1\", "98-GR25", Array("fti_20181110121623_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-025\FTI\Run2\", "99-GR25", Array("fti_20181110125653_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0001-000\FTI\Run1\", "100-FT01", Array("fti_20181122132613_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0002\FTI\Run1\", "101-FT02", Array("fti_20181123131614_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0003\FTI\Run1\", "102-FT03", Array("fti_20181128125529_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0003\FTI\Run2\", "103-FT03", Array("fti_20181128143532_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0004\FTI\Run1\", "104-FT04", Array("fti_20181130101353_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0004\FTI\Run2\", "105-FT04", Array("fti_20181130130044_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0005\FTI\Run1\", "106-FT05", Array("fti_20181205083011_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0005\FTI\Run2\", "107-FT05", Array("fti_20181205100158_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0005\FTI\Run3\", "108-FT05", Array("fti_20181205122743_pp.tdms")) _
  )

' Identified errors - P3!!!
' -> 77-FT17 contains NOVALUE for CNT_DST_BST_LNG and CNT_DST_BST_LAT
' -> 78-FT17 contains NOVALUE for CNT_DST_BST_LNG and CNT_DST_BST_COL

' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("1312")
' iterators = Array("1-SN002-1.1","2-SN002-1.2","3-SN002-1.3","4-SN002-1.6","5-SN002-2.3.1","6-SN002-2.3.2","7-SN002-2.3.3","8-SN002-2.4"_
'                 , "9-SN0012-1.1", "10-SN0012-1.3", "11-SN0012-1.6", "12-SN0012-2.3", "13-SN0012-2.4" _
'                 )
iterators_base = Array( _ 
            "1-RC" _
          , "2-RC" _
          , "3-RC" _
          , "4-RC" _
          , "5-RC" _
          , "6-RC" _
          , "7-GR01" _
          , "8-GR02" _
          , "9-GR02" _
          , "10-GR03" _
          , "11-GR03" _
          , "12-GR03" _
          , "13-GR04" _
          , "14-GR05" _
          , "15-GR05" _
          , "16-GR05" _
          , "17-GR05" _
          , "18-GR05" _
          , "19-GR05" _
          , "20-GR05" _
          , "21-GR05" _
          , "22-GR05" _
          , "23-GR06" _
          , "24-GR06" _
          , "25-GR06" _
          , "26-GR06" _
          , "27-GR06" _
          , "28-GR06" _
          , "29-GR07" _
          , "30-GR07" _
          , "31-GR07" _
          , "32-GR07" _
          , "33-GR07" _
          , "34-GR08" _
          , "35-GR09" _
          , "36-GR09" _
          , "37-GR09" _
          , "38-GR09" _
          , "39-GR09" _
          , "40-GR09" _
          , "41-GR09" _
          , "42-GR09" _
          , "43-GR09" _
          , "44-GR09" _
          , "45-GR09" _
          , "46-GR09" _
          , "47-GR09" _
          , "48-GR09" _
          , "49-GR10" _
          , "50-GR10" _
          , "51-GR10" _
          , "52-GR10" _
          , "53-GR10" _
          , "54-GR10" _
          , "55-GR10" _
          , "56-GR10" _
          , "57-GR11" _
          , "58-GR11" _
          , "59-GR11" _
          , "60-GR11" _
          , "61-GR11" _
          , "62-GR12" _
          , "63-GR12" _
          , "64-GR12" _
          , "65-GR12" _
          , "66-GR12" _
          , "67-GR13" _
          , "68-GR13" _
          , "69-GR13" _
          , "70-GR14" _
          , "71-GR14" _
          , "72-GR14" _
          , "73-GR14" _
          , "74-GR15" _
          , "75-GR15" _
          , "76-GR16" _
          , "77-GR17" _
          , "78-GR17" _
          , "79-GR18" _
          , "80-GR18" _
          , "81-GR18" _
          , "82-GR19" _
          , "83-GR19" _
          , "84-GR20" _
          , "85-GR20" _
          , "86-GR21" _
          , "87-GR22" _
          , "88-GR22" _
          , "89-GR22" _
          , "90-GR22" _
          , "91-GR22" _
          , "92-GR22" _
          , "93-GR23" _
          , "94-GR23" _
          , "95-GR23" _
          , "96-GR24" _
          , "97-GR24" _
          , "98-GR25" _
          , "99-GR25" _
          , "100-FT01" _
          , "101-FT02" _
          , "102-FT03" _
          , "103-FT03" _
          , "104-FT04" _
          , "105-FT04" _
          , "106-FT05" _
          , "107-FT05" _
          , "108-FT05" _
)

' iterators = Array("100-FT01", "101-FT02")
' iterators = Array("102-FT03", "103-FT03")
iterators = Array("104-FT04", "105-FT04", "106-FT05", "107-FT05", "108-FT05")
' iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08")

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "CNT_FRC_BST_COL", "CNT_FRC_BST_COL"
dictVaDiadem.Add "CNT_FRC_BST_LNG", "CNT_FRC_BST_LNG"
dictVaDiadem.Add "CNT_FRC_BST_LAT", "CNT_FRC_BST_LAT"
dictVaDiadem.Add "CNT_FRC_BST_TR_1", "CNT_FRC_BST_TR_1"
dictVaDiadem.Add "CNT_FRC_BST_TR_2", "CNT_FRC_BST_TR_2"
dictVaDiadem.Add "CNT_FRC_BST_TR_CALC", "CNT_FRC_BST_TR_CALC"
dictVaDiadem.Add "CNT_DST_BST_COL", "CNT_DST_BST_COL"
dictVaDiadem.Add "CNT_DST_BST_LAT", "CNT_DST_BST_LAT"
dictVaDiadem.Add "CNT_DST_BST_LNG", "CNT_DST_BST_LNG"
dictVaDiadem.Add "CNT_DST_BST_TR", "CNT_DST_BST_TR"
dictVaDiadem.Add "CNT_DST_COL", "CNT_DST_COL"
dictVaDiadem.Add "CNT_DST_LAT", "CNT_DST_LAT"
dictVaDiadem.Add "CNT_DST_LNG", "CNT_DST_LNG"
dictVaDiadem.Add "CNT_DST_PED", "CNT_DST_PED"
dictVaDiadem.Add "HYD_PRS_1", "HYD_PRS_1"
dictVaDiadem.Add "HYD_PRS_2", "HYD_PRS_2"
' dictVaDiadem.Add "HYD_TMP_1", "HYD_TMP_1"
' dictVaDiadem.Add "HYD_TMP_2", "HYD_TMP_2"
dictVaDiadem.Add "HYD_TMP_TANK_1", "HYD_TMP_TANK_1"
dictVaDiadem.Add "HYD_TMP_TANK_2", "HYD_TMP_TANK_2"
' dictVaDiadem.Add "DIU_ARI_IND_HYD_PRS_1_C", "DIU_ARI_IND_HYD_PRS_1_C"
' dictVaDiadem.Add "DIU_ARI_IND_HYD_PRS_2_C", "DIU_ARI_IND_HYD_PRS_2_C"
' dictVaDiadem.Add "PFD_ARI_TMP_OAT", "PFD_ARI_TMP_OAT"


' Temperature investigation upper deck
' dictVaDiadem.Add "FRW_TMP_FWD_MID", "FRW_TMP_FWD_MID" 'Kurt'
' dictVaDiadem.Add "FRW_TMP_FWD_RH", "FRW_TMP_FWD_RH" 'Kurt'
' dictVaDiadem.Add "FRW_TMP_AFT_LH", "FRW_TMP_AFT_LH" 'Kurt'
' dictVaDiadem.Add "FRW_TMP_AFT_RH", "FRW_TMP_AFT_RH" 'Kurt'
' dictVaDiadem.Add "MGB_TMP_SUS_FWD", "MGB_TMP_SUS_FWD" 'Kurt'
' dictVaDiadem.Add "ENG_TMP_EDUCT", "ENG_TMP_EDUCT" 'Kurt'
' dictVaDiadem.Add "ECS_TMP_LEDE_SUS_FWD_INN", "ECS_TMP_LEDE_SUS_FWD_INN" 'Kurt'
' dictVaDiadem.Add "ECS_TMP_LEDE_SUS_FWD_OUT", "ECS_TMP_LEDE_SUS_FWD_OUT" 'Kurt'
' dictVaDiadem.Add "ECS_TMP_LEDE_SUS_AFT", "ECS_TMP_LEDE_SUS_AFT" 'Kurt'
' dictVaDiadem.Add "ECS_TMP_LEDE_FRW", "ECS_TMP_LEDE_FRW" 'Kurt'
' dictVaDiadem.Add "ECS_TMP_LEDE_HYD", "ECS_TMP_LEDE_HYD" 'Kurt'
' dictVaDiadem.Add "ENG_TMP_CPT_AIR", "ENG_TMP_CPT_AIR" 'Kurt'


signalsToDif = Array("CNT_DST_BST_COL", "CNT_DST_BST_LNG", "CNT_DST_BST_LAT","CNT_DST_COL", "CNT_DST_LNG", "CNT_DST_LAT")

FlagFTData = False
' FlagFTData = False

' newFreq = 0.1 'Hz'
newFreq = 100 'Hz'

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

FlagFilteredData = True
FlagHighPass = True 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False