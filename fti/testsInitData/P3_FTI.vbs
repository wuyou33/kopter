Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "P:\12_flightTestData\all\"

' Where the data will be saved in csv format
csvFolder = "P:\12_flightTestData\all\"

' filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
'                   , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
'                   , "Force_Piston_Eye_HP2_[N].tdms", "Input_force_[N].tdms", "Laser_Piston_[mm].tdms"_
'                   , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_[N].tdms", "Temperatur_HP_1_[degC].TDM", "Temperatur_HP_2_[degC].TDM")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "E:\FTI\ProcData\SKYeSH09\P3\J17-Test Data\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_120203\", "1-RC", Array("fti_2018-08-22_120203_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_125159\", "2-RC", Array("fti_2018-08-22_125159_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_142002\", "3-RC", Array("fti_2018-08-22_142002_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_164658\", "4-RC", Array("fti_2018-08-22_164658_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_172647\", "5-RC", Array("fti_2018-08-22_172647_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-000-009_Rigging_check\FTI\fti_2018-08-22_183631\", "6-RC", Array("fti_2018-08-22_183631_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-001\FTI\fti_2018-08-24_131313\", "7-FT01", Array("fti_2018-08-24_131313_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-002\FTI\fti_2018-08-28_142034\", "8-FT02", Array("fti_2018-08-28_142034_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-002\FTI\fti_2018-08-28_151046\", "9-FT02", Array("fti_2018-08-28_151046_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-003\FTI\fti_2018-08-29_140143\", "10-FT03", Array("fti_2018-08-29_140143_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-003-001_Controls_Calib\FTI\fti_2018-08-30_080725\", "11-FT03", Array("fti_2018-08-30_080725_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-003-002_Tailboom_lifting\FTI\fti_2018-08-30_121543\", "12-FT03", Array("fti_2018-08-30_121543_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-004\FTI\fti_2018-09-03_142731\", "13-FT04", Array("fti_2018-09-03_142731_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_084730\", "14-FT05", Array("fti_2018-09-04_084730_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_091732\", "15-FT05", Array("fti_2018-09-04_091732_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_093052\", "16-FT05", Array("fti_2018-09-04_093052_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_094719\", "17-FT05", Array("fti_2018-09-04_094719_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_113847\", "18-FT05", Array("fti_2018-09-04_113847_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_121001\", "19-FT05", Array("fti_2018-09-04_121001_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_131902\", "20-FT05", Array("fti_2018-09-04_131902_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_141625\", "21-FT05", Array("fti_2018-09-04_141625_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-005\FTI\fti_2018-09-04_145011\", "22-FT05", Array("fti_2018-09-04_145011_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run1\", "23-FT06", Array("fti_20180907144446_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run2\", "24-FT06", Array("fti_20180907155328_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run3\", "25-FT06", Array("fti_20180907162445_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run4\", "26-FT06", Array("fti_20180907165135_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006\FTI\Run5\", "27-FT06", Array("fti_20180907171544_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-006-001 Helicopter_taxiing\FTI\Run1\", "28-FT06", Array("fti_20180907154101_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run1\", "29-FT07", Array("fti_20180910132019_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run2\", "30-FT07", Array("fti_20180910134511_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run3\", "31-FT07", Array("fti_20180910141117_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run4\", "32-FT07", Array("fti_20180910143205_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-007\FTI\Run5\", "33-FT07", Array("fti_20180910151302_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-008\FTI\Run1\", "34-FT08", Array("fti_20180911113815_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run1\", "35-FT09", Array("fti_20180913075811_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run2\", "36-FT09", Array("fti_20180913083809_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run3\", "37-FT09", Array("fti_20180913090710_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run4\", "38-FT09", Array("fti_20180913093446_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run5\", "39-FT09", Array("fti_20180913111618_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run6\", "40-FT09", Array("fti_20180913115747_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run7\", "41-FT09", Array("fti_20180913123210_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run7\", "42-FT09", Array("fti_20180913124359_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run8\", "43-FT09", Array("fti_20180913130147_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run9\", "44-FT09", Array("fti_20180913133257_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run10\", "45-FT09", Array("fti_20180913135522_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009\FTI\Run11\", "46-FT09", Array("fti_20180913141742_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009-001_Controls_Range\FTI\Run1\", "47-FT09", Array("fti_20180914100758_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-009-001_Controls_Range\FTI\Run2\", "48-FT09", Array("fti_20180914101252_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010\FTI\Run1\", "49-FT10", Array("fti_20180919114150_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010\FTI\Run2\", "50-FT10", Array("fti_20180919135017_pp.tdms")) _
    , Array(commonAddress&"P3-J17-0000-010\FTI\Run3\", "51-FT10", Array("fti_20180919144847_pp.tdms")) _
  )

' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("1312")
' iterators = Array("1-SN002-1.1","2-SN002-1.2","3-SN002-1.3","4-SN002-1.6","5-SN002-2.3.1","6-SN002-2.3.2","7-SN002-2.3.3","8-SN002-2.4"_
'                 , "9-SN0012-1.1", "10-SN0012-1.3", "11-SN0012-1.6", "12-SN0012-2.3", "13-SN0012-2.4" _
'                 )
iterators = Array(_ 
			"1-RC"_
		, 	"2-RC" _
		, 	"3-RC" _
		, 	"4-RC" _
		, 	"5-RC" _
		, 	"6-RC" _
		, 	"7-FT01" _
		, 	"8-FT02" _
		, 	"9-FT02" _
		, "10-FT03" _
		, "11-FT03" _
		, "12-FT03" _
		, "13-FT04" _
		, "14-FT05" _
		, "15-FT05" _
		, "16-FT05" _
		, "17-FT05" _
		, "18-FT05" _
		, "19-FT05" _
		, "20-FT05" _
		, "21-FT05" _
		, "22-FT05" _
		, "23-FT06" _
		, "24-FT06" _
		, "25-FT06" _
		, "26-FT06" _
		, "27-FT06" _
		, "28-FT06" _
		, "29-FT07" _
		, "30-FT07" _
		, "31-FT07" _
		, "32-FT07" _
		, "33-FT07" _
		, "34-FT08" _
		, "35-FT09" _
		, "36-FT09" _
		, "37-FT09" _
		, "38-FT09" _
		, "39-FT09" _
		, "40-FT09" _
		, "41-FT09" _
		, "42-FT09" _
		, "43-FT09" _
		, "44-FT09" _
		, "45-FT09" _
		, "46-FT09" _
		, "47-FT09" _
		, "48-FT09" _
		, "49-FT010" _
		, "50-FT10" _
		, "51-FT10" _
		)

' iterators = Array("29-FT07")
' iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08")

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
' dictVaDiadem.Add "CNT_FRC_BST_COL", "CNT_FRC_BST_COL"
' dictVaDiadem.Add "CNT_FRC_BST_LAT", "CNT_FRC_BST_LAT"
' dictVaDiadem.Add "CNT_FRC_BST_LNG", "CNT_FRC_BST_LNG"
' dictVaDiadem.Add "CNT_DST_BST_COL", "CNT_DST_BST_COL"
' dictVaDiadem.Add "CNT_DST_BST_LAT", "CNT_DST_BST_LAT"
' dictVaDiadem.Add "CNT_DST_BST_LNG", "CNT_DST_BST_LNG"
dictVaDiadem.Add "CNT_DST_COL", "CNT_DST_COL"
dictVaDiadem.Add "CNT_DST_LAT", "CNT_DST_LAT"
dictVaDiadem.Add "CNT_DST_LNG", "CNT_DST_LNG"
' dictVaDiadem.Add "CNT_DST_PED", "CNT_DST_PED"
' dictVaDiadem.Add "HYD_PRS_1", "HYD_PRS_1"
' dictVaDiadem.Add "HYD_PRS_2", "HYD_PRS_2"
' dictVaDiadem.Add "HYD_TMP_1", "HYD_TMP_1"
' dictVaDiadem.Add "HYD_TMP_2", "HYD_TMP_2"



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