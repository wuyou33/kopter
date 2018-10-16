Set oFSO = CreateObject("Scripting.FileSystemObject")
Set dictVaDiadem = CreateObject("Scripting.Dictionary")

' Where the raw data will be saved in "TMD" format
workingFolder = "P:\12_flightTestData\P2_all_100Hz\"

' Where the data will be saved in csv format
csvFolder = "P:\12_flightTestData\P2_all_100Hz\"

' filesNames = Array("Druck_HP_1_[bar].tdms", "Druck_HP_2_[bar].tdms","Durchfluss_HP_1_[l_min].tdms"_ 
'                   , "Durchfluss_HP_2_[l_min]_.tdms", "Force_Piston_Eye_HP1_[N].tdms"_
'                   , "Force_Piston_Eye_HP2_[N].tdms", "Input_force_[N].tdms", "Laser_Piston_[mm].tdms"_
'                   , "Laser_Steuerventilhebel_[mm].tdms", "Output_force_[N].tdms", "Temperatur_HP_1_[degC].TDM", "Temperatur_HP_2_[degC].TDM")

' These are the folders where the data that wants to be imported is contained. Each folder correspond to a differt time step
commonAddress = "G:\FTI\ProcData\SKYeSH09\P2\J17-01-Flight Tests\"
fileNamesBigArrayFolders = Array( _
    Array(commonAddress & "P2-J17-01-FT0001\FTI\fti_2016-02-26_161010\", "1-FT0001", Array("fti_2016-02-26_161010_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0001\FTI\fti_2016-02-26_161621\", "2-FT0001", Array("fti_2016-02-26_161621_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0002\FTI\fti_2016-03-17_094251\", "3-FT0002", Array("fti_2016-03-17_094251_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0002\FTI\fti_2016-03-17_100040\", "4-FT0002", Array("fti_2016-03-17_100040_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0003\FTI\fti_2016-03-22_073220\", "5-FT0003", Array("fti_2016-03-22_073220_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0004\FTI\fti_2016-03-22_094708\", "6-FT0004", Array("fti_2016-03-22_094708_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0005\FTI\fti_2016-03-22_131640\", "7-FT0005", Array("fti_2016-03-22_131640_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0006\FTI\fti_2016-03-23_090140\", "8-FT0006", Array("fti_2016-03-23_090140_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0007\FTI\fti_2016-05-20_133748\", "9-FT0007", Array("fti_2016-05-20_133748_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0007\FTI\fti_2016-05-20_140118\", "10-FT0007", Array("fti_2016-05-20_140118_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0007\FTI\fti_2016-05-20_144848\", "11-FT0007", Array("fti_2016-05-20_144848_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0008\FTI\fti_2016-05-24_140021\", "12-FT0008", Array("fti_2016-05-24_140021_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0008\FTI\fti_2016-05-24_150050\", "13-FT0008", Array("fti_2016-05-24_150050_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0009\FTI\fti_2016-05-25_105421\", "14-FT0009", Array("fti_2016-05-25_105421_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0010\FTI\fti_2016-05-25_143915\", "15-FT0010", Array("fti_2016-05-25_143915_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0011\FTI\fti_2016-05-26_115612\", "16-FT0011", Array("fti_2016-05-26_115612_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0011\FTI\fti_2016-05-26_125015\", "17-FT0011", Array("fti_2016-05-26_125015_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0012\FTI\fti_2016-05-27_052414\", "18-FT0012", Array("fti_2016-05-27_052414_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0013\FTI\fti_2016-05-27_110055\", "19-FT0013", Array("fti_2016-05-27_110055_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0014\FTI\fti_2016-06-01_114013\", "20-FT0014", Array("fti_2016-06-01_114013_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0014\FTI\fti_2016-06-01_115405\", "21-FT0014", Array("fti_2016-06-01_115405_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0014\FTI\fti_2016-06-01_123426\", "22-FT0014", Array("fti_2016-06-01_123426_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0014\FTI\fti_2016-06-01_145816\", "23-FT0014", Array("fti_2016-06-01_145816_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0014\FTI\fti_2016-06-02_075116\", "24-FT0014", Array("fti_2016-06-02_075116_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0015\FTI\fti_2016-06-02_093937\", "25-FT0015", Array("fti_2016-06-02_093937_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0016\FTI\fti_2016-06-02_120113\", "26-FT0016", Array("fti_2016-06-02_120113_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0017\FTI\fti_2016-06-10_062159\", "27-FT0017", Array("fti_2016-06-10_062159_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0017\FTI\fti_2016-06-10_063833\", "28-FT0017", Array("fti_2016-06-10_063833_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0018\FTI\fti_2016-07-06_114005\", "29-FT0018", Array("fti_2016-07-06_114005_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0018\FTI\fti_2016-07-06_130048\", "30-FT0018", Array("fti_2016-07-06_130048_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0018\FTI\fti_2016-07-06_143348\", "31-FT0018", Array("fti_2016-07-06_143348_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0019\FTI\fti_2016-07-07_092652\", "32-FT0019", Array("fti_2016-07-07_092652_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0019\FTI\fti_2016-07-07_115309\", "33-FT0019", Array("fti_2016-07-07_115309_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0020\FTI\fti_2016-07-11_111619\", "34-FT0020", Array("fti_2016-07-11_111619_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0021-FT0022\FTI\fti_2016-07-15_083327\", "35-FT0021&FT0022", Array("fti_2016-07-15_083327_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0021-FT0022\FTI\fti_2016-07-15_084625\", "36-FT0021&FT0022", Array("fti_2016-07-15_084625_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0023\FTI\fti_2016-07-19_071508\", "37-FT0023", Array("fti_2016-07-19_071508_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0024\FTI\fti_2016-07-19_110848\", "38-FT0024", Array("fti_2016-07-19_110848_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0025\FTI\fti_2016-07-20_065511\", "39-FT0025", Array("fti_2016-07-20_065511_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0025\FTI\fti_2016-07-20_081759\", "40-FT0025", Array("fti_2016-07-20_081759_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0025\FTI\fti_2016-07-20_092950\", "41-FT0025", Array("fti_2016-07-20_092950_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0026\FTI\fti_2016-07-21_071019\", "42-FT0026", Array("fti_2016-07-21_071019_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0026\FTI\fti_2016-07-21_080414\", "43-FT0026", Array("fti_2016-07-21_080414_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0026\FTI\fti_2016-07-21_082523\", "44-FT0026", Array("fti_2016-07-21_082523_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0026\FTI\fti_2016-07-21_090945\", "45-FT0026", Array("fti_2016-07-21_090945_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0027\FTI\fti_2016-07-25_130342\", "46-FT0027", Array("fti_2016-07-25_130342_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0027\FTI\fti_2016-07-25_134135\", "47-FT0027", Array("fti_2016-07-25_134135_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0027\FTI\fti_2016-07-25_153431\", "48-FT0027", Array("fti_2016-07-25_153431_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0028\FTI\fti_2016-07-26_081640\", "49-FT0028", Array("fti_2016-07-26_081640_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0028\FTI\fti_2016-07-26_111340\", "50-FT0028", Array("fti_2016-07-26_111340_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0029\FTI\fti_2016-07-27_075909\", "51-FT0029", Array("fti_2016-07-27_075909_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0030\FTI\fti_2016-08-11_122928\", "52-FT0030", Array("fti_2016-08-11_122928_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0030\FTI\fti_2016-08-11_145513\", "53-FT0030", Array("fti_2016-08-11_145513_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0031\FTI\fti_2016-08-19_134800\", "54-FT0031", Array("fti_2016-08-19_134800_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0032\FTI\fti_2016-08-22_072936\", "55-FT0032", Array("fti_2016-08-22_072936_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0032\FTI\fti_2016-08-22_083015\", "56-FT0032", Array("fti_2016-08-22_083015_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0032\FTI\fti_2016-08-22_090618\", "57-FT0032", Array("fti_2016-08-22_090618_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0032\FTI\fti_2016-08-22_093000\", "58-FT0032", Array("fti_2016-08-22_093000_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0033\FTI\fti_2016-08-22_132642\", "59-FT0033", Array("fti_2016-08-22_132642_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0033\FTI\fti_2016-08-22_143642\", "60-FT0033", Array("fti_2016-08-22_143642_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0033\FTI\fti_2016-08-22_152636\", "61-FT0033", Array("fti_2016-08-22_152636_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0034\FTI\fti_2016-08-23_091550\", "62-FT0034", Array("fti_2016-08-23_091550_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0035\FTI\fti_2016-08-23_124155\", "63-FT0035", Array("fti_2016-08-23_124155_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0036\FTI\fti_2016-08-24_151741\", "64-FT0036", Array("fti_2016-08-24_151741_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0036\FTI\fti_2016-08-24_154020\", "65-FT0036", Array("fti_2016-08-24_154020_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0037\FTI\fti_2016-08-25_072155\", "66-FT0037", Array("fti_2016-08-25_072155_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0038\FTI\fti_2016-08-25_092655\", "67-FT0038", Array("fti_2016-08-25_092655_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0039\FTI\fti_2016-11-28_120427\", "68-FT0039", Array("fti_2016-11-28_120427_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0040\FTI\fti_2016-11-29_140128\", "69-FT0040", Array("fti_2016-11-29_140128_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0040\FTI\fti_2016-11-29_141655\", "70-FT0040", Array("fti_2016-11-29_141655_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0040\FTI\fti_2016-11-29_151254\", "71-FT0040", Array("fti_2016-11-29_151254_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0041\FTI\fti_2016-11-30_103655\", "72-FT0041", Array("fti_2016-11-30_103655_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0041\FTI\fti_2016-11-30_135133\", "73-FT0041", Array("fti_2016-11-30_135133_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0041\FTI\fti_2016-11-30_143615\", "74-FT0041", Array("fti_2016-11-30_143615_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0041\FTI\fti_2016-11-30_145649\", "75-FT0041", Array("fti_2016-11-30_145649_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0041\FTI\fti_2016-11-30_151215\", "76-FT0041", Array("fti_2016-11-30_151215_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0042\FTI\fti_2016-12-01_084706\", "77-FT0042", Array("fti_2016-12-01_084706_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0043\FTI\fti_2016-12-01_103316\", "78-FT0043", Array("fti_2016-12-01_103316_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0043\FTI\fti_2016-12-01_123609\", "79-FT0043", Array("fti_2016-12-01_123609_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0044\FTI\fti_2016-12-01_134813\", "80-FT0044", Array("fti_2016-12-01_134813_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0045\FTI\fti_2017-03-03_103437\", "81-FT0045", Array("fti_2017-03-03_103437_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0045\FTI\fti_2017-03-03_104830\", "82-FT0045", Array("fti_2017-03-03_104830_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0046\FTI\fti_2017-03-06_100022\", "83-FT0046", Array("fti_2017-03-06_100022_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0046\FTI\fti_2017-03-06_104611\", "84-FT0046", Array("fti_2017-03-06_104611_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0046\FTI\fti_2017-03-06_121832\", "85-FT0046", Array("fti_2017-03-06_121832_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0046\FTI\fti_2017-03-06_124510\", "86-FT0046", Array("fti_2017-03-06_124510_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0046\FTI\fti_2017-03-06_131114\", "87-FT0046", Array("fti_2017-03-06_131114_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0047\FTI\fti_2017-03-10_092357\", "88-FT0047", Array("fti_2017-03-10_092357_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0047\FTI\fti_2017-03-10_133543\", "89-FT0047", Array("fti_2017-03-10_133543_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0048\FTI\fti_2017-03-15_084703\", "90-FT0048", Array("fti_2017-03-15_084703_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0048\FTI\fti_2017-03-15_090021\", "91-FT0048", Array("fti_2017-03-15_090021_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0049\FTI\fti_2017-03-17_092955\", "92-FT0049", Array("fti_2017-03-17_092955_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0049\FTI\fti_2017-03-17_100633\", "93-FT0049", Array("fti_2017-03-17_100633_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0050\FTI\fti_2017-04-05_074153\", "94-FT0050", Array("fti_2017-04-05_074153_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0050\FTI\fti_2017-04-05_084959\", "95-FT0050", Array("fti_2017-04-05_084959_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0050\FTI\fti_2017-04-05_140514\", "96-FT0050", Array("fti_2017-04-05_140514_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0050\FTI\fti_2017-04-05_141315\", "97-FT0050", Array("fti_2017-04-05_141315_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0051\FTI\fti_2017-04-07_090324\", "98-FT0051", Array("fti_2017-04-07_090324_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0051\FTI\fti_2017-04-07_111804\", "99-FT0051", Array("fti_2017-04-07_111804_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0051\FTI\fti_2017-04-07_120433\", "100-FT0051", Array("fti_2017-04-07_120433_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0052\FTI\fti_2017-04-25_082230\", "101-FT0052", Array("fti_2017-04-25_082230_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0052\FTI\fti_2017-04-25_085927\", "102-FT0052", Array("fti_2017-04-25_085927_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0053\FTI\fti_2017-05-04_092815\", "103-FT0053", Array("fti_2017-05-04_092815_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0053\FTI\fti_2017-05-04_113952\", "104-FT0053", Array("fti_2017-05-04_113952_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0054\FTI\fti_2017-05-05_072556\", "105-FT0054", Array("fti_2017-05-05_072556_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0054\FTI\fti_2017-05-05_112030\", "106-FT0054", Array("fti_2017-05-05_112030_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0054\FTI\fti_2017-05-05_134832\", "107-FT0054", Array("fti_2017-05-05_134832_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0055\FTI\fti_2017-05-11_114651\", "108-FT0055", Array("fti_2017-05-11_114651_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0055\FTI\fti_2017-05-11_141228\", "109-FT0055", Array("fti_2017-05-11_141228_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0056\FTI\fti_2017-05-15_134820\", "110-FT0056", Array("fti_2017-05-15_134820_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0056\FTI\fti_2017-05-15_142901\", "111-FT0056", Array("fti_2017-05-15_142901_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0057\FTI\fti_2017-05-16_114319\", "112-FT0057", Array("fti_2017-05-16_114319_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0058\FTI\fti_2017-05-17_121954\", "113-FT0058", Array("fti_2017-05-17_121954_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0059\FTI\fti_2017-05-18_070003\", "114-FT0059", Array("fti_2017-05-18_070003_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0060\FTI\fti_2017-06-02_060310\", "115-FT0060", Array("fti_2017-06-02_060310_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0060\FTI\fti_2017-06-02_061954\", "116-FT0060", Array("fti_2017-06-02_061954_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0060\FTI\fti_2017-06-02_081310\", "117-FT0060", Array("fti_2017-06-02_081310_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0061\FTI\fti_2017-06-08_121754\", "118-FT0061", Array("fti_2017-06-08_121754_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0062\FTI\fti_2017-06-08_134256\", "119-FT0062", Array("fti_2017-06-08_134256_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0063\FTI\fti_2017-06-08_145804\", "120-FT0063", Array("fti_2017-06-08_145804_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0064\FTI\fti_2017-06-09_080608\", "121-FT0064", Array("fti_2017-06-09_080608_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0065\FTI\fti_2017-06-09_092227\", "122-FT0065", Array("fti_2017-06-09_092227_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0066\FTI\fti_2017-06-09_114158\", "123-FT0066", Array("fti_2017-06-09_114158_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0067\FTI\fti_2017-06-12_063754\", "124-FT0067", Array("fti_2017-06-12_063754_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0068\FTI\fti_2017-06-12_080444\", "125-FT0068", Array("fti_2017-06-12_080444_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0069\FTI\fti_2017-06-12_092557\", "126-FT0069", Array("fti_2017-06-12_092557_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0069\FTI\fti_2017-06-12_121750\", "127-FT0069", Array("fti_2017-06-12_121750_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0070\FTI\fti_2017-06-13_062354\", "128-FT0070", Array("fti_2017-06-13_062354_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0070\FTI\fti_2017-06-13_081742\", "129-FT0070", Array("fti_2017-06-13_081742_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0071\FTI\fti_2017-06-14_062949\", "130-FT0071", Array("fti_2017-06-14_062949_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0071\FTI\fti_2017-06-14_081418\", "131-FT0071", Array("fti_2017-06-14_081418_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0072\FTI\fti_2017-06-26_065641\", "132-FT0072", Array("fti_2017-06-26_065641_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0072\FTI\fti_2017-06-26_114125\", "133-FT0072", Array("fti_2017-06-26_114125_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0072\FTI\fti_2017-06-26_131646\", "134-FT0072", Array("fti_2017-06-26_131646_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0072\FTI\fti_2017-06-26_135330\", "135-FT0072", Array("fti_2017-06-26_135330_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0073\FTI\fti_2017-06-27_063238\", "136-FT0073", Array("fti_2017-06-27_063238_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0074\FTI\fti_2017-07-03_120027\", "137-FT0074", Array("fti_2017-07-03_120027_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0075\FTI\fti_2017-07-04_124410\", "138-FT0075", Array("fti_2017-07-04_124410_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0075\FTI\fti_2017-07-04_134539\", "139-FT0075", Array("fti_2017-07-04_134539_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0076\FTI\fti_2017-07-05_062723\", "140-FT0076", Array("fti_2017-07-05_062723_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0076\FTI\fti_2017-07-05_065123\", "141-FT0076", Array("fti_2017-07-05_065123_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0077\FTI\fti_2017-07-14_084646\", "142-FT0077", Array("fti_2017-07-14_084646_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0077\FTI\fti_2017-07-14_111143\", "143-FT0077", Array("fti_2017-07-14_111143_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0078\FTI\fti_2017-07-17_071318\", "144-FT0078", Array("fti_2017-07-17_071318_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0078\FTI\fti_2017-07-17_093858\", "145-FT0078", Array("fti_2017-07-17_093858_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0079\FTI\fti_2017-07-18_053416\", "146-FT0079", Array("fti_2017-07-18_053416_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0079\FTI\fti_2017-07-18_113601\", "147-FT0079", Array("fti_2017-07-18_113601_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0080\FTI\fti_2017-10-05_142223\", "148-FT0080", Array("fti_2017-10-05_142223_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0080\FTI\fti_2017-10-05_151014\", "149-FT0080", Array("fti_2017-10-05_151014_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0080\FTI\fti_2017-10-05_155931\", "150-FT0080", Array("fti_2017-10-05_155931_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0081\FTI\fti_2017-10-06_094703\", "151-FT0081", Array("fti_2017-10-06_094703_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0081\FTI\fti_2017-10-06_110205\", "152-FT0081", Array("fti_2017-10-06_110205_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0082\FTI\fti_2017-10-10_070646\", "153-FT0082", Array("fti_2017-10-10_070646_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0083\FTI\fti_2017-10-10_125748\", "154-FT0083", Array("fti_2017-10-10_125748_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0084\FTI\fti_2017-10-11_093831\", "155-FT0084", Array("fti_2017-10-11_093831_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0084\FTI\fti_2017-10-11_112020\", "156-FT0084", Array("fti_2017-10-11_112020_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0085\FTI\fti_2017-10-12_081034\", "157-FT0085", Array("fti_2017-10-12_081034_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0085\FTI\fti_2017-10-12_090810\", "158-FT0085", Array("fti_2017-10-12_090810_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0086\FTI\fti_2017-10-13_080040\", "159-FT0086", Array("fti_2017-10-13_080040_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0087\FTI\fti_2017-10-24_080826\", "160-FT0087", Array("fti_2017-10-24_080826_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0087\FTI\fti_2017-10-24_091922\", "161-FT0087", Array("fti_2017-10-24_091922_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0088\FTI\fti_2017-10-25_133407\", "162-FT0088", Array("fti_2017-10-25_133407_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0089\FTI\fti_2017-10-26_080608\", "163-FT0089", Array("fti_2017-10-26_080608_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0089\FTI\fti_2017-10-26_085127\", "164-FT0089", Array("fti_2017-10-26_085127_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0090\FTI\fti_2017-10-30_094324\", "165-FT0090", Array("fti_2017-10-30_094324_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0090\FTI\fti_2017-10-30_102350\", "166-FT0090", Array("fti_2017-10-30_102350_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0091\FTI\fti_2017-10-31_074559\", "167-FT0091", Array("fti_2017-10-31_074559_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0091\FTI\fti_2017-10-31_085859\", "168-FT0091", Array("fti_2017-10-31_085859_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0092\FTI\fti_2017-11-02_080012\", "169-FT0092", Array("fti_2017-11-02_080012_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0093\FTI\fti_2017-11-03_100737\", "170-FT0093", Array("fti_2017-11-03_100737_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0094\FTI\fti_2017-12-01_100240\", "171-FT0094", Array("fti_2017-12-01_100240_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0094\FTI\fti_2017-12-01_125727\", "172-FT0094", Array("fti_2017-12-01_125727_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0094\FTI\fti_2017-12-01_134306\", "173-FT0094", Array("fti_2017-12-01_134306_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0095\FTI\fti_2017-12-05_120756\", "174-FT0095", Array("fti_2017-12-05_120756_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0095\FTI\fti_2017-12-05_124258\", "175-FT0095", Array("fti_2017-12-05_124258_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0096\FTI\fti_2017-12-06_151310\", "176-FT0096", Array("fti_2017-12-06_151310_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0097\FTI\fti_2017-12-07_122526\", "177-FT0097", Array("fti_2017-12-07_122526_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0098\FTI\fti_2017-12-13_101734\", "178-FT0098", Array("fti_2017-12-13_101734_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0098\FTI\fti_2017-12-13_104040\", "179-FT0098", Array("fti_2017-12-13_104040_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0099\FTI\fti_2018-01-12_130053\", "180-FT0099", Array("fti_2018-01-12_130053_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0100\FTI\fti_2018-01-15_144120\", "181-FT0100", Array("fti_2018-01-15_144120_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0100\FTI\fti_2018-01-15_151154\", "182-FT0100", Array("fti_2018-01-15_151154_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0100\FTI\fti_2018-01-15_152920\", "183-FT0100", Array("fti_2018-01-15_152920_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0100\FTI\fti_2018-01-15_155402\", "184-FT0100", Array("fti_2018-01-15_155402_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0101\FTI\fti_2018-01-24_133911\", "185-FT0101", Array("fti_2018-01-24_133911_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0101\FTI\fti_2018-01-24_145539\", "186-FT0101", Array("fti_2018-01-24_145539_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0102\FTI\fti_2018-01-25_084649\", "187-FT0102", Array("fti_2018-01-25_084649_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0102\FTI\fti_2018-01-25_122546\", "188-FT0102", Array("fti_2018-01-25_122546_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0103\FTI\fti_2018-01-25_142451\", "189-FT0103", Array("fti_2018-01-25_142451_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0104\FTI\fti_2018-01-26_091716\", "190-FT0104", Array("fti_2018-01-26_091716_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0105\FTI\fti_2018-01-29_144100\", "191-FT0105", Array("fti_2018-01-29_144100_pp.tdms")) _
    , Array(commonAddress & "P2-J17-01-FT0106\FTI\fti_2018-01-30_084242\", "192-FT0106", Array("fti_2018-01-30_084242_pp.tdms")) _
  )

' The variable iterators is used to load and operate only selected steps from above
' iterators = Array("1312")
' iterators = Array("1-SN002-1.1","2-SN002-1.2","3-SN002-1.3","4-SN002-1.6","5-SN002-2.3.1","6-SN002-2.3.2","7-SN002-2.3.3","8-SN002-2.4"_
'                 , "9-SN0012-1.1", "10-SN0012-1.3", "11-SN0012-1.6", "12-SN0012-2.3", "13-SN0012-2.4" _
'                 )
iterators = Array(_
		"1-FT0001" _
		,	"2-FT0001" _
		,	"3-FT0002" _
		,	"4-FT0002" _
		,	"5-FT0003" _
		,	"6-FT0004" _
		,	"7-FT0005" _
		,	"8-FT0006" _
		,	"9-FT0007" _
		,	"10-FT0007" _
		,	"11-FT0007" _
		,	"12-FT0008" _
		,	"13-FT0008" _
		,	"14-FT0009" _
		,	"15-FT0010" _
		,	"16-FT0011" _
		,	"17-FT0011" _
		,	"18-FT0012" _
		,	"19-FT0013" _
		,	"20-FT0014" _
		,	"21-FT0014" _
		,	"22-FT0014" _
		,	"23-FT0014" _
		,	"24-FT0014" _
		,	"25-FT0015" _
		,	"26-FT0016" _
		,	"27-FT0017" _
		,	"28-FT0017" _
		,	"29-FT0018" _
		,	"30-FT0018" _
		,	"31-FT0018" _
		,	"32-FT0019" _
		,	"33-FT0019" _
		,	"34-FT0020" _
		,	"35-FT0021&FT0022" _
		,	"36-FT0021&FT0022" _
		,	"37-FT0023" _
		,	"38-FT0024" _
		,	"39-FT0025" _
		,	"40-FT0025" _
		,	"41-FT0025" _
		,	"42-FT0026" _
		,	"43-FT0026" _
		,	"44-FT0026" _
		,	"45-FT0026" _
		,	"46-FT0027" _
		,	"47-FT0027" _
		,	"48-FT0027" _
		,	"49-FT0028" _
		,	"50-FT0028" _
		,	"51-FT0029" _
		,	"52-FT0030" _
		,	"53-FT0030" _
		,	"54-FT0031" _
		,	"55-FT0032" _
		,	"56-FT0032" _
		,	"57-FT0032" _
		,	"58-FT0032" _
		,	"59-FT0033" _
		,	"60-FT0033" _
		,	"61-FT0033" _
		,	"62-FT0034" _
		,	"63-FT0035" _
		,	"64-FT0036" _
		,	"65-FT0036" _
		,	"66-FT0037" _
		,	"67-FT0038" _
		,	"68-FT0039" _
		,	"69-FT0040" _
		,	"70-FT0040" _
		,	"71-FT0040" _
		,	"72-FT0041" _
		,	"73-FT0041" _
		,	"74-FT0041" _
		,	"75-FT0041" _
		,	"76-FT0041" _
		,	"77-FT0042" _
		,	"78-FT0043" _
		,	"79-FT0043" _
		,	"80-FT0044" _
		,	"81-FT0045" _
		,	"82-FT0045" _
		,	"83-FT0046" _
		,	"84-FT0046" _
		,	"85-FT0046" _
		,	"86-FT0046" _
		,	"87-FT0046" _
		,	"88-FT0047" _
		,	"89-FT0047" _
		,	"90-FT0048" _
		,	"91-FT0048" _
		,	"92-FT0049" _
		,	"93-FT0049" _
		,	"94-FT0050" _
		,	"95-FT0050" _
		,	"96-FT0050" _
		,	"97-FT0050" _
		,	"98-FT0051" _
		,	"99-FT0051" _
		,	"100-FT0051" _
		,	"101-FT0052" _
		,	"102-FT0052" _
		,	"103-FT0053" _
		,	"104-FT0053" _
		,	"105-FT0054" _
		,	"106-FT0054" _
		,	"107-FT0054" _
		,	"108-FT0055" _
		,	"109-FT0055" _
		,	"110-FT0056" _
		,	"111-FT0056" _
		,	"112-FT0057" _
		,	"113-FT0058" _
		,	"114-FT0059" _
		,	"115-FT0060" _
		,	"116-FT0060" _
		,	"117-FT0060" _
		,	"118-FT0061" _
		,	"119-FT0062" _
		,	"120-FT0063" _
		,	"121-FT0064" _
		,	"122-FT0065" _
		,	"123-FT0066" _
		,	"124-FT0067" _
		,	"125-FT0068" _
		,	"126-FT0069" _
		,	"127-FT0069" _
		,	"128-FT0070" _
		,	"129-FT0070" _
		,	"130-FT0071" _
		,	"131-FT0071" _
		,	"132-FT0072" _
		,	"133-FT0072" _
		,	"134-FT0072" _
		,	"135-FT0072" _
		,	"136-FT0073" _
		,	"137-FT0074" _
		,	"138-FT0075" _
		,	"139-FT0075" _
		,	"140-FT0076" _
		,	"141-FT0076" _
		,	"142-FT0077" _
		,	"143-FT0077" _
		,	"144-FT0078" _
		,	"145-FT0078" _
		,	"146-FT0079" _
		,	"147-FT0079" _
		,	"148-FT0080" _
		,	"149-FT0080" _
		,	"150-FT0080" _
		,	"151-FT0081" _
		,	"152-FT0081" _
		,	"153-FT0082" _
		,	"154-FT0083" _
		,	"155-FT0084" _
		,	"156-FT0084" _
		,	"157-FT0085" _
		,	"158-FT0085" _
		,	"159-FT0086" _
		,	"160-FT0087" _
		,	"161-FT0087" _
		,	"162-FT0088" _
		,	"163-FT0089" _
		,	"164-FT0089" _
		,	"165-FT0090" _
		,	"166-FT0090" _
		,	"167-FT0091" _
		,	"168-FT0091" _
		,	"169-FT0092" _
		,	"170-FT0093" _
		,	"171-FT0094" _
		,	"172-FT0094" _
		,	"173-FT0094" _
		,	"174-FT0095" _
		,	"175-FT0095" _
		,	"176-FT0096" _
		,	"177-FT0097" _
		,	"178-FT0098" _
		,	"179-FT0098" _
		,	"180-FT0099" _
		,	"181-FT0100" _
		,	"182-FT0100" _
		,	"183-FT0100" _
		,	"184-FT0100" _
		,	"185-FT0101" _
		,	"186-FT0101" _
		,	"187-FT0102" _
		,	"188-FT0102" _
		,	"189-FT0103" _
		,	"190-FT0104" _
		,	"191-FT0105" _
		,	"192-FT0106" _
		)

' iterators = Array("29-FT07")
' iterators = Array("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
' iterators = Array("08")

' variable names inside DIAdem -> variable names for the files to be saved
' This dictionary contains the original variable names as keys. For each key, a corresponding simplified name is assign and this will be used
' in the "csv" file name.
' The variable name has to be written without: spaces , . _ -
dictVaDiadem.Add "CNT_FRC_BST_COL", "CNT_FRC_BST_COL"
dictVaDiadem.Add "CNT_FRC_BST_LAT", "CNT_FRC_BST_LAT"
dictVaDiadem.Add "CNT_FRC_BST_LNG", "CNT_FRC_BST_LNG"
' dictVaDiadem.Add "CNT_DST_BST_COL", "CNT_DST_BST_COL"
' dictVaDiadem.Add "CNT_DST_BST_LAT", "CNT_DST_BST_LAT"
' dictVaDiadem.Add "CNT_DST_BST_LNG", "CNT_DST_BST_LNG"
' dictVaDiadem.Add "CNT_DST_COL", "CNT_DST_COL"
' dictVaDiadem.Add "CNT_DST_LAT", "CNT_DST_LAT"
' dictVaDiadem.Add "CNT_DST_LNG", "CNT_DST_LNG"
' dictVaDiadem.Add "CNT_DST_PED", "CNT_DST_PED"
' dictVaDiadem.Add "HYD_PRS_1", "HYD_PRS_1"
' dictVaDiadem.Add "HYD_PRS_2", "HYD_PRS_2"
' dictVaDiadem.Add "HYD_TMP_1", "HYD_TMP_1"
' dictVaDiadem.Add "HYD_TMP_2", "HYD_TMP_2"

' Temperatures, FT060 the first one with cooler 
' dictVaDiadem.Add "HYD_ARI_MFD_TMP_1", "HYD_ARI_MFD_TMP_1"
' dictVaDiadem.Add "HYD_ARI_MFD_TMP_2", "HYD_ARI_MFD_TMP_2"
signalsToDif = Array("CNT_DST_COL", "CNT_DST_LNG", "CNT_DST_LAT", "CNT_DST_BST_COL", "CNT_DST_BST_LNG", "CNT_DST_BST_LAT")

FlagFTData = True

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

' numberPointsSmoothering= 10 'Number of points to take for the smoothering operation'

FlagFilteredData = True
FlagHighPass = True 'False if low pass'

FlagMaxMinMeanData = False

saveFlagFilteredData = True 'possible values: True or False
saveFlagMaxMinMean = False 'possible values: True or False