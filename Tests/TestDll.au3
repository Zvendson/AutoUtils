#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include ".\..\UnitTest.au3"
#include ".\..\Dll.au3"

Global $dDllPayload = GetDllPayload()



UTInit()
testDllStart()
testDllOpen()
testDllGetProcAddress()
testDllClose()
testDllShutdown()
UTExit()



Func testDllStart()
    UTStart("_Dll_StartUp()")

    UTAssert(_Dll_StartUp(), "_Dll_StartUp() // First init try")
    UTAssert(_Dll_StartUp(), "_Dll_StartUp() // Second init try")

    UTStop()
EndFunc



Func testDllOpen()
    UTStart("_Dll_Open()")

    UTAssert(_Dll_Open($dDllPayload), "_Dll_Open($dDllPayload) // First open try")
    UTAssert(_Dll_Open($dDllPayload), "_Dll_Open($dDllPayload) // Second open try")

    UTStop()
EndFunc



Func testDllGetProcAddress()
    UTStart("_Dll_GetProcAddress()")

    Local $hDll = _Dll_Open($dDllPayload)

    _Dll_GetProcAddress($hDll, "MakeVector")
    _Dll_GetProcAddress($hDll, "KillVector")
    _Dll_GetProcAddress($hDll, "PushInt")
    _Dll_GetProcAddress($hDll, "GetInt")


    UTAssert(_Dll_GetProcAddress($hDll, 'MakeVector') <> 0, "_Dll_GetProcAddress($hDll, 'MakeVector') <> 0")
    UTAssert(_Dll_GetProcAddress($hDll, 'KillVector') <> 0, "_Dll_GetProcAddress($hDll, 'KillVector') <> 0")
    UTAssert(_Dll_GetProcAddress($hDll, 'PushInt')    <> 0, "_Dll_GetProcAddress($hDll, 'PushInt')    <> 0")
    UTAssert(_Dll_GetProcAddress($hDll, 'GetInt')     <> 0, "_Dll_GetProcAddress($hDll, 'GetInt')     <> 0")
    UTAssert(_Dll_GetProcAddress($hDll, 'InvalidFunc') = 0, "_Dll_GetProcAddress($hDll, 'MakeVector') <> 0")
    UTAssert(_Dll_GetProcAddress($hDll, True)          = 0, "_Dll_GetProcAddress($hDll, True)          = 0")
    UTAssert(_Dll_GetProcAddress($hDll, 180.0)         = 0, "_Dll_GetProcAddress($hDll, 180.0)         = 0")
    UTAssert(_Dll_GetProcAddress($hDll, 50)            = 0, "_Dll_GetProcAddress($hDll, 50)            = 0")

    UTStop()
EndFunc



Func testDllClose()
    UTStart("_Dll_Close()")

    Local $hDll = _Dll_Open($dDllPayload)
    UTAssert($hDll <> 0, "_Dll_Open($dDllPayload) <> 0")

    UTAssert(_Dll_Close('$hDll') = 0, "_Dll_Close('$hDll') = 0")
    UTAssert(_Dll_Close($hDll)   = 1, "_Dll_Close($hDll)   = 1")
    UTAssert(_Dll_Close(42)      = 0, "_Dll_Close(42)      = 0")
    UTAssert(_Dll_Close(True)    = 0, "_Dll_Close(True)    = 0")
    UTAssert(_Dll_Close($hDll)   = 0, "_Dll_Close($hDll)   = 0")
    UTAssert(_Dll_Close(Default) = 0, "_Dll_Close(Default) = 0")

    UTStop()
EndFunc



Func testDllShutdown()
    UTStart("_Dll_Shutdown()")

    UTAssert(_Dll_Shutdown() = 1, "_Dll_Shutdown() = 1")
    UTAssert(_Dll_Shutdown() = 0, "_Dll_Shutdown() = 0")

    UTStop()
EndFunc



Func GetDllPayload()
    ;I tried to fit everything in one function and made a custom Test.dll to demonstrate how this work.
    ;The code of the test.dll can be found at the end of this file.
    ;If you still dont trust the code, dont run this.

    Local $sBinary = ""
    $sBinary &= "0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000F800000"
    $sBinary &= "00E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000"
    $sBinary &= "4DC49DC009A5F39309A5F39309A5F39300DD60930DA5F39346D9F69206A5F39346D9F79203A5F39346D9F09208A5F39346D9F2920CA5F393DAD7F2920BA5F3930"
    $sBinary &= "9A5F29323A5F393C8D9FA9208A5F393C8D9F39208A5F393C8D90C9308A5F393C8D9F19208A5F3935269636809A5F3930000000000000000504500004C01050044"
    $sBinary &= "8E5E640000000000000000E00002210B010E220012000000180000000000007B17000000100000003000000000001000100000000200000600000000000000060"
    $sBinary &= "0000000000000007000000004000000000000030040010000100000100000000010000010000000000000100000004038000080000000C0380000780000000050"
    $sBinary &= "0000E00100000000000000000000000000000000000000600000FC010000283200007000000000000000000000000000000000000000000000000000000068310"
    $sBinary &= "00040000000000000000000000000300000940000000000000000000000000000000000000000000000000000002E746578740000006911000000100000001200"
    $sBinary &= "0000040000000000000000000000000000200000602E72646174610000040D000000300000000E000000160000000000000000000000000000400000402E64617"
    $sBinary &= "46100000004040000004000000002000000240000000000000000000000000000400000C02E72737263000000E001000000500000000200000026000000000000"
    $sBinary &= "0000000000000000400000402E72656C6F630000FC010000006000000002000000280000000000000000000000000000400000420000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000558BEC568BF10F"
    $sBinary &= "57C08D460450C706D8300010660FD6008B450883C00450FF154830001083C4088BC65E5DC20400CCCC8B4904B80831001085C90F45C1C3CCCC558BEC568BF18D4"
    $sBinary &= "604C706D830001050FF154C30001083C404F6450801740B6A0C56E8A303000083C4088BC65E5DC20400CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC8D4104C701D83000"
    $sBinary &= "1050FF154C30001059C3CCCCCCCCCCCCCCCCCCCCCCCCCCCC0F57C08BC1660FD64104C741041C310010C70100310010C3CCCCCCCCCCCCCCCC558BEC83EC0C8D4DF"
    $sBinary &= "4E8D2FFFFFF68143800108D45F450E8AF0F0000CCCCCCCC558BEC568BF10F57C08D460450C706D8300010660FD6008B450883C00450FF154830001083C408C706"
    $sBinary &= "003100108BC65E5DC20400CCCCCCCCCCCCCCCCCCCCCCCC558BEC568BF10F57C08D460450C706D8300010660FD6008B450883C00450FF154830001083C408C706E"
    $sBinary &= "43000108BC65E5DC20400CCCCCCCCCCCCCCCCCCCCCCCC6A0CE87302000083C404C70000000000C7400400000000C7400800000000C3CC558BEC568B750885F674"
    $sBinary &= "518B0685C074408B4E082BC883E1FC81F90010000072128B50FC83C1232BC283C0FC83F81F772E8BC25150E850020000C7060000000083C408C7460400000000C"
    $sBinary &= "74608000000006A0C56E83102000083C4085E5DC3FF1588300010CCCCCCCCCCCCCCCCCCCCCC558BEC8B4D088B51043B5108740B8B450C8902834104045DC38D45"
    $sBinary &= "0C5052E84D0000005DC3CCCCCCCCCCCCCCCCCCCCCC558BEC8B45088B550C8B088B40042BC1C1F8023BC20F86150000008B04915DC3B801000000C20C00CCCCCCC"
    $sBinary &= "CCCCCCCCC6834310010FF1534300010CCCCCCCCCC558BEC83EC0C8B45085356578BF98945F88B172BC2C1F8028945FC8B47042BC2C1F8023DFFFFFF3F0F842401"
    $sBinary &= "00008B4F088D70012BCA8975F4C1F902B8FFFFFF3F8BD1D1EA2BC23BC80F87FE0000008D040A8BDE3BC60F43D881FBFFFFFF3F0F87E8000000C1E30281FB00100"
    $sBinary &= "00072278D43233BC30F86D200000050E8F900000083C40485C00F84BB0000008D702383E6E08946FCEB1385DB740D53E8D900000083C4048BF0EB0233F68B45FC"
    $sBinary &= "8B55F88D0C868B450C894DFC8B0089018B47048B0F3BD0750F2BC1505156E8330E000083C40CEB232BD1525156E8240E00008B47048B4DF82BC1508B45FC5183C"
    $sBinary &= "00450E80E0E000083C4188B0785C0742C8B4F082BC883E1FC81F90010000072128B50FC83C1232BC283C0FC83F81F77298BC25150E88300000083C4088B45F489"
    $sBinary &= "378D0C868B45FC894F048D0C33894F085F5E5B8BE55DC20800FF1588300010E80EFDFFFFE809000000CCCCCCCCCCCCCCCCCC6850310010FF1530300010CC3B0D0"
    $sBinary &= "04000107501C3E9EC030000558BECEB0DFF7508E8BC0C00005985C0740FFF7508E8B50C00005985C074E65DC3837D08FF0F84BBFCFFFFE9CE040000558BECFF75"
    $sBinary &= "08E8E0040000595DC3558BECF6450801568BF1C706C4300010740A6A0C56E8D8FFFFFF59598BC65E5DC20400558BEC8B450C83E800743383E801742083E801741"
    $sBinary &= "183E801740533C040EB30E842060000EB05E81C0600000FB6C0EB1FFF7510FF7508E81800000059EB10837D10000F95C00FB6C050E80C010000595DC20C006A10"
    $sBinary &= "6830370010E8960900006A00E8710600005984C00F84D1000000E8680500008845E3B301885DE78365FC00833DD0430010000F85C5000000C705D043001001000"
    $sBinary &= "000E89D05000084C0744DE8F4080000E8AD040000E8CC04000068A830001068A4300010E8BC0B0000595985C07529E84505000084C0742068A0300010689C3000"
    $sBinary &= "10E8980B00005959C705D04300100200000032DB885DE7C745FCFEFFFFFFE83D00000084DB7543E86E0700008BF0833E00741F56E8880600005984C07414FF750"
    $sBinary &= "C6A02FF75088B368BCEFF1594300010FFD6FF059040001033C040EB0F8A5DE7FF75E3E8ED06000059C333C08B4DF064890D00000000595F5E5BC9C36A07E81D07"
    $sBinary &= "0000CC6A106850370010E88F080000A19040001085C07F0433C0EB6948A39040001033FF47897DE48365FC00E8540400008845E0897DFC833DD043001002756BE"
    $sBinary &= "80B050000E8C2030000E81F0800008325D0430010008365FC00E8390000006A00FF7508E88806000059590FB6F0F7DE1BF623F78975E4C745FCFEFFFFFFE82200"
    $sBinary &= "00008BC68B4DF064890D00000000595F5E5BC9C38B7DE4FF75E0E83406000059C38B75E4E8C9040000C36A07E86D060000CC6A0C6878370010E8DF0700008B7D0"
    $sBinary &= "C85FF750F393D904000107F0733C0E9D90000008365FC0083FF01740A83FF0274058B5D10EB318B5D105357FF7508E8C90000008BF08975E485F60F84A3000000"
    $sBinary &= "5357FF7508E89DFDFFFF8BF08975E485F60F848C0000005357FF7508E88BFBFFFF8BF08975E483FF01752785F675235350FF7508E873FBFFFF85DB0F95C00FB6C"
    $sBinary &= "050E8BAFEFFFF595356FF7508E86A00000085FF740583FF0375485357FF7508E842FDFFFF8BF08975E485F674355357FF7508E8440000008BF0EB248B4DEC8B01"
    $sBinary &= "51FF30683B140010FF7510FF750CFF7508E88303000083C418C38B65E833F68975E4C745FCFEFFFFFF8BC68B4DF064890D00000000595F5E5BC9C3558BEC568B3"
    $sBinary &= "5C830001085F6750533C040EB13FF75108BCEFF750CFF7508FF1594300010FFD65E5DC20C00558BEC837D0C017505E8BE010000FF7510FF750CFF7508E8AEFEFF"
    $sBinary &= "FF83C40C5DC20C00558BEC6A00FF1500300010FF7508FF152830001068090400C0FF150430001050FF15083000105DC3558BEC81EC240300006A17FF150C30001"
    $sBinary &= "085C074056A0259CD29A398410010890D94410010891590410010891D8C410010893588410010893D84410010668C15B0410010668C0DA4410010668C1D804100"
    $sBinary &= "10668C057C410010668C2578410010668C2D744100109C8F05A84100108B4500A39C4100108B4504A3A04100108D4508A3AC4100108B85DCFCFFFFC705E840001"
    $sBinary &= "001000100A1A0410010A3A4400010C70598400010090400C0C7059C40001001000000C705A8400010010000006A04586BC000C780AC400010020000006A04586B"
    $sBinary &= "C0008B0D00400010894C05F86A0458C1E0008B0D04400010894C05F868CC300010E8E0FEFFFFC9C3836104008BC183610800C74104EC300010C701E4300010C35"
    $sBinary &= "58BEC83EC0C8D4DF4E8DAFFFFFF68943700108D45F450E897070000CCE9C1070000558BEC83EC148365F4008D45F48365F80050FF151C3000108B45F83345F489"
    $sBinary &= "45FCFF15183000103145FCFF15143000103145FC8D45EC50FF15103000108B45F08D4DFC3345EC3345FC33C1C9C38B0D004000105657BF4EE640BBBE0000FFFF3"
    $sBinary &= "BCF740485CE7526E894FFFFFF8BC83BCF7507B94FE640BBEB0E85CE750A0D11470000C1E0100BC8890D00400010F7D15F890D044000105EC368B8430010FF1520"
    $sBinary &= "300010C368B8430010E8E906000059C3B8C0430010C3B8C8430010C3E8EFFFFFFF8B4804830824894804E8E7FFFFFF8B4804830802894804C3558BEC8B4508568"
    $sBinary &= "B483C03C80FB741148D511803D00FB741066BF02803F23BD674198B4D0C3B4A0C720A8B420803420C3BC8720C83C2283BD675EA33C05E5DC38BC2EBF956E86206"
    $sBinary &= "000085C0742064A118000000BED44300108B5004EB043BD0741033C08BCAF00FB10E85C075F032C05EC3B0015EC3E83106000085C07407E850040000EB18E81D0"
    $sBinary &= "6000050E8630600005985C0740332C0C3E85C060000B001C36A00E8D000000084C0590F95C0C3E85E06000084C0750332C0C3E85206000084C07507E849060000"
    $sBinary &= "EBEDB001C3E83F060000E83A060000B001C3558BECE8C905000085C07519837D0C017513FF75108B4D1450FF7508FF1594300010FF5514FF751CFF7518E8E3050"
    $sBinary &= "00059595DC3E89805000085C0740C68DC430010E8E405000059C3E8EC05000085C00F84DB050000C36A00E8D905000059E9D3050000558BEC837D08007507C605"
    $sBinary &= "D843001001E880030000E8B905000084C0750432C05DC3E8AC05000084C0750A6A00E8A105000059EBE9B0015DC3558BEC803DD9430010007404B0015DC3568B7"
    $sBinary &= "50885F6740583FE017562E81205000085C0742685F6752268DC430010E8540500005985C0750F68E8430010E8450500005985C0742B32C0EB3083C9FF890DDC43"
    $sBinary &= "0010890DE0430010890DE4430010890DE8430010890DEC430010890DF0430010C605D943001001B0015E5DC36A05E8E0000000CC6A0868B0370010E8520200008"
    $sBinary &= "365FC00B84D5A000066390500000010755DA13C00001081B80000001050450000754CB90B01000066398818000010753E8B4508B9000000102BC15051E8B3FDFF"
    $sBinary &= "FF595985C07427837824007C21C745FCFEFFFFFFB001EB1F8B45EC8B0033C98138050000C00F94C18BC1C38B65E8C745FCFEFFFFFF32C08B4DF064890D0000000"
    $sBinary &= "0595F5E5BC9C3558BECE81104000085C0740F807D0800750933C0B9D443001087015DC3558BEC803DD8430010007406807D0C007512FF7508E848040000FF7508"
    $sBinary &= "E8400400005959B0015DC3B800440010C3558BEC81EC24030000536A17FF150C30001085C074058B4D08CD296A03E8F9000000C70424CC0200008D85DCFCFFFF6"
    $sBinary &= "A0050E8AF03000083C40C89858CFDFFFF898D88FDFFFF899584FDFFFF899D80FDFFFF89B57CFDFFFF89BD78FDFFFF668C95A4FDFFFF668C8D98FDFFFF668C9D74"
    $sBinary &= "FDFFFF668C8570FDFFFF668CA56CFDFFFF668CAD68FDFFFF9C8F859CFDFFFF8B4504898594FDFFFF8D45048985A0FDFFFFC785DCFCFFFF010001008B40FC6A508"
    $sBinary &= "98590FDFFFF8D45A86A0050E8250300008B450483C40CC745A815000040C745AC010000008945B4FF15243000106A008D58FFF7DB8D45A88945F88D85DCFCFFFF"
    $sBinary &= "1ADB8945FCFEC3FF15003000108D45F850FF152830001085C0750C84DB75086A03E804000000595BC9C38325F443001000C35356BE20370010BB203700103BF37"
    $sBinary &= "319578B3E85FF740A8BCFFF1594300010FFD783C6043BF372E95F5E5BC35356BE28370010BB283700103BF37319578B3E85FF740A8BCFFF1594300010FFD783C6"
    $sBinary &= "043BF372E95F5E5BC3CCCCCCCC68751E001064FF35000000008B442410896C24108D6C24102BE0535657A1004000103145FC33C5508965E8FF75F88B45FCC745F"
    $sBinary &= "CFEFFFFFF8945F88D45F064A300000000C3558BEC568B7508FF36E868020000FF75148906FF7510FF750C5668CC1300106800400010E8FF01000083C41C5E5DC3"
    $sBinary &= "C20000558BEC8325F84300100083EC24830D10400010016A0AFF150C30001085C00F84AC0100008365F00033C053565733C98D7DDC530FA28BF35B90890789770"
    $sBinary &= "4894F0833C989570C8B45DC8B7DE08945F481F747656E758B45E835696E65498945FC8B45E4356E74656C8945F833C040530FA28BF35B908D5DDC89038B45FC0B"
    $sBinary &= "45F80BC7897304894B0889530C75438B45DC25F03FFF0F3DC006010074233D60060200741C3D7006020074153D50060300740E3D6006030074073D70060300751"
    $sBinary &= "18B3DFC43001083CF01893DFC430010EB068B3DFC4300108B4DE46A0758894DFC3945F47C3033C9530FA28BF35B908D5DDC8903897304894B088B4DFC89530C8B"
    $sBinary &= "5DE0F7C300020000740E83CF02893DFC430010EB038B5DF0A11040001083C802C705F843001001000000A310400010F7C1000010000F849300000083C804C705F"
    $sBinary &= "843001002000000A310400010F7C1000000087479F7C100000010747133C90F01D08945EC8955F08B45EC8B4DF06A065E23C63BC67557A11040001083C808C705"
    $sBinary &= "F843001003000000A310400010F6C320743B83C820C705F843001005000000A310400010B8000003D023D83BD8751E8B45ECBAE00000008B4DF023C23BC2750D8"
    $sBinary &= "30D10400010408935F84300105F5E5B33C0C9C333C040C333C03905144000100F95C0C3FF2540300010FF253C300010FF2544300010FF2554300010FF25603000"
    $sBinary &= "10FF2564300010FF2580300010FF257C300010FF255C300010FF2578300010FF2574300010FF2570300010FF258C300010FF256C300010FF2584300010B001C33"
    $sBinary &= "3C0C3558BEC51833DF8430010017C66817D08B40200C07409817D08B50200C075540FAE5DFC8B45FC83F03FA881743FA9040200007507B88E0000C0C9C3A90201"
    $sBinary &= "0000742AA9080400007507B8910000C0C9C3A9100800007507B8930000C0C9C3A920100000750EB88F0000C0C9C3B8900000C0C9C38B4508C9C3FF25503000100"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "0000000000000000000000000000000000000000000003C00001E3C0000323C0000463C0000623C00007C3C0000923C0000A83C0000C23C0000D83C0000E43B00"
    $sBinary &= "0000000000EC390000CC39000000000000623A00004C3A0000823A0000343A00001A3A0000FA3C00008C3A0000000000000E3B0000DE3A0000EA3A00000000000"
    $sBinary &= "0803B0000423B0000283B0000163B0000003B0000F43A0000983B0000B83A0000643B000000000000A41E00100000000000000000000000000000000000000000"
    $sBinary &= "0000000000000000000000000000000000000000C0320010181400100000000098400010E84000100833001040100010301000108833001040100010301000106"
    $sBinary &= "2616420616C6C6F636174696F6E0000BC3300104010001030100010556E6B6E6F776E20657863657074696F6E000000626164206172726179206E6577206C656E"
    $sBinary &= "67746800000000696E76616C696420766563746F722073756273637269707400000000766563746F7220746F6F206C6F6E67000000000000000000C0000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400010EC3300100100"
    $sBinary &= "000094300010000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000F03300100000000000000000000000000000000000000000983000100000000000000000448E5E"
    $sBinary &= "640000000002000000410000004C3400004C1A000000000000448E5E64000000000C0000001400000090340000901A000000000000448E5E64000000000D00000"
    $sBinary &= "078020000A4340000A41A000000000000448E5E64000000000E000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "0000000000000000000000000000000000000000000000000000000078400010D4320010000000000000000001000000E4320010EC32001000000000784000100"
    $sBinary &= "000000000000000FFFFFFFF0000000040000000D43200100000000000000000000000003440001078330010D03300105433001038330010000000005433001038"
    $sBinary &= "33001000000000344000100000000000000000FFFFFFFF000000004000000078330010184000100100000000000000FFFFFFFF0000000040000000AC330010383"
    $sBinary &= "30010000000000000000000000000010000007033001000000000000000000000000018400010AC3300100000000000000000030000001C330010000000000000"
    $sBinary &= "0000020000002C330010000000000000000000000000504000109C330010504000100200000000000000FFFFFFFF00000000400000009C330010751E000018000"
    $sBinary &= "00002800280083400002C0000003434000018000000A0180000B0180000DF1E00001B1F0000931F0000082000000B2000000E20000011200000562000005E2000"
    $sBinary &= "00CC130000640A0000751E000016020000E52000007E000000525344532EE4CD2A73038F468AF0925CDD0E4B2C08000000443A5C50726F6772616D6D696E675C4"
    $sBinary &= "32B2B5C546573745C52656C656173655C546573742E70646200000000000000001A0000001A00000001000000190000004743544C00100000691100002E746578"
    $sBinary &= "74246D6E0000000000300000940000002E696461746124350000000094300000080000002E303063666700009C300000040000002E4352542458434100000000A"
    $sBinary &= "0300000040000002E4352542458435A00000000A4300000040000002E4352542458494100000000A8300000040000002E4352542458495A00000000AC30000004"
    $sBinary &= "0000002E4352542458504100000000B0300000040000002E4352542458505A00000000B4300000040000002E4352542458544100000000B8300000080000002E4"
    $sBinary &= "352542458545A00000000C0300000000200002E72646174610000C03200002C0100002E7264617461247200000000EC330000040000002E726461746124737864"
    $sBinary &= "617461000000F03300005C0000002E726461746124766F6C746D640000004C340000D00200002E7264617461247A7A7A6462670000001C370000040000002E727"
    $sBinary &= "463244941410000000020370000040000002E72746324495A5A0000000024370000040000002E727463245441410000000028370000080000002E72746324545A"
    $sBinary &= "5A0000000030370000100100002E786461746124780000000040380000800000002E65646174610000C0380000640000002E69646174612432000000002439000"
    $sBinary &= "0140000002E696461746124330000000038390000940000002E6964617461243400000000CC390000380300002E69646174612436000000000040000018000000"
    $sBinary &= "2E6461746100000018400000600000002E6461746124720078400000180000002E646174612472730000000090400000740300002E62737300000000005000006"
    $sBinary &= "00000002E727372632430310000000060500000800100002E72737263243032000000000000000000000000000000000000000000000000FEFFFFFF00000000D0"
    $sBinary &= "FFFFFF00000000FEFFFFFF000000006E15001000000000FEFFFFFF00000000D0FFFFFF00000000FEFFFFFF0000000034160010000000000000000027160010FEF"
    $sBinary &= "FFFFF00000000D4FFFFFF00000000FEFFFFFF101700102F170010000000008010001000000000A437001002000000DC370010F8370010FEFFFFFF00000000D8FF"
    $sBinary &= "FFFF00000000FEFFFFFF371C00104A1C00100300000024380010DC370010F8370010100000001840001000000000FFFFFFFF000000000C0000002011001000000"
    $sBinary &= "0003440001000000000FFFFFFFF000000000C00000000100010000000008010001000000000CC370010000000005040001000000000FFFFFFFF000000000C0000"
    $sBinary &= "00E010001000000000FFFFFFFF0000000090380000010000000400000004000000683800007838000088380000201200008011000060110000F01100009938000"
    $sBinary &= "0A0380000AB380000B63800000000010002000300546573742E646C6C00476574496E74004B696C6C566563746F72004D616B65566563746F720050757368496E"
    $sBinary &= "740000006839000000000000000000000C3A000030300000743900000000000000000000A63A00003C300000A43900000000000000000000A23B00006C3000009"
    $sBinary &= "43900000000000000000000C43B00005C300000383900000000000000000000EC3C0000003000000000000000000000000000000000000000000000003C00001E"
    $sBinary &= "3C0000323C0000463C0000623C00007C3C0000923C0000A83C0000C23C0000D83C0000E43B000000000000EC390000CC39000000000000623A00004C3A0000823"
    $sBinary &= "A0000343A00001A3A0000FA3C00008C3A0000000000000E3B0000DE3A0000EA3A000000000000803B0000423B0000283B0000163B0000003B0000F43A0000983B"
    $sBinary &= "0000B83A0000643B0000000000008F023F5F586F75745F6F665F72616E6765407374644040594158504244405A008E023F5F586C656E6774685F6572726F72407"
    $sBinary &= "374644040594158504244405A004D535643503134302E646C6C000022005F5F7374645F657863657074696F6E5F64657374726F790021005F5F7374645F657863"
    $sBinary &= "657074696F6E5F636F7079000001005F4378785468726F77457863657074696F6E000025005F5F7374645F747970655F696E666F5F64657374726F795F6C69737"
    $sBinary &= "4000048006D656D736574000035005F6578636570745F68616E646C6572345F636F6D6D6F6E00564352554E54494D453134302E646C6C00003B005F696E76616C"
    $sBinary &= "69645F706172616D657465725F6E6F696E666F5F6E6F72657475726E000008005F63616C6C6E6577680019006D616C6C6F63000038005F696E69747465726D003"
    $sBinary &= "9005F696E69747465726D5F6500180066726565000041005F7365685F66696C7465725F646C6C0019005F636F6E6669677572655F6E6172726F775F6172677600"
    $sBinary &= "0035005F696E697469616C697A655F6E6172726F775F656E7669726F6E6D656E74000036005F696E697469616C697A655F6F6E657869745F7461626C650000240"
    $sBinary &= "05F657865637574655F6F6E657869745F7461626C650017005F636578697400006170692D6D732D77696E2D6372742D72756E74696D652D6C312D312D302E646C"
    $sBinary &= "6C006170692D6D732D77696E2D6372742D686561702D6C312D312D302E646C6C0000C705556E68616E646C6564457863657074696F6E46696C746572000087055"
    $sBinary &= "36574556E68616E646C6564457863657074696F6E46696C74657200240247657443757272656E7450726F6365737300A6055465726D696E61746550726F636573"
    $sBinary &= "7300009B03497350726F636573736F724665617475726550726573656E740061045175657279506572666F726D616E6365436F756E74657200250247657443757"
    $sBinary &= "272656E7450726F63657373496400290247657443757272656E7454687265616449640000FA0247657453797374656D54696D65417346696C6554696D65007803"
    $sBinary &= "496E697469616C697A65534C697374486561640094034973446562756767657250726573656E74004B45524E454C33322E646C6C000047006D656D6D6F7665000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004EE640BBB119B"
    $sBinary &= "F44FFFFFFFF000000000100000001000000C4300010000000002E3F41566261645F616C6C6F6340737464404000C4300010000000002E3F415665786365707469"
    $sBinary &= "6F6E40737464404000C4300010000000002E3F41566261645F61727261795F6E65775F6C656E6774684073746440400000C4300010000000002E3F41567479706"
    $sBinary &= "55F696E666F4040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    $sBinary &= "000000001001800000018000080000000000000000000000000000001000200000030000080000000000000000000000000000001000904000048000000605000"
    $sBinary &= "007D010000000000000000000000000000000000003C3F786D6C2076657273696F6E3D27312E302720656E636F64696E673D275554462D3827207374616E64616"
    $sBinary &= "C6F6E653D27796573273F3E0D0A3C617373656D626C7920786D6C6E733D2775726E3A736368656D61732D6D6963726F736F66742D636F6D3A61736D2E76312720"
    $sBinary &= "6D616E696665737456657273696F6E3D27312E30273E0D0A20203C7472757374496E666F20786D6C6E733D2275726E3A736368656D61732D6D6963726F736F667"
    $sBinary &= "42D636F6D3A61736D2E7633223E0D0A202020203C73656375726974793E0D0A2020202020203C72657175657374656450726976696C656765733E0D0A20202020"
    $sBinary &= "202020203C726571756573746564457865637574696F6E4C6576656C206C6576656C3D276173496E766F6B6572272075694163636573733D2766616C736527202"
    $sBinary &= "F3E0D0A2020202020203C2F72657175657374656450726976696C656765733E0D0A202020203C2F73656375726974793E0D0A20203C2F7472757374496E666F3E"
    $sBinary &= "0D0A3C2F617373656D626C793E0D0A000000000000000000000000000000000000000000000000000000000000000000000000100000200100000F30203034304"
    $sBinary &= "B30523085308C30AD30B330CF30EF30003109312F3140314931E13151325732A933C133C733CE3324349134BD34CA34EB34F03409350E351B355D3565359835A2"
    $sBinary &= "35B035CB35E33548365A36193756377037A537AE37B937C037D337E137E737ED37F337F937FF3706380D3814381B3822382938303838384038483854385D38623"
    $sBinary &= "8683872387C388C389C38AC38B538CD38D338E7380E391D3926393339493983398C39933999399F39AB39B139283ACC3AEC3A1D3B503B763B853B9C3BA23BA83B"
    $sBinary &= "AE3BB43BBA3BC03BD53BEA3BF13BF73B093C133C7B3C883CAC3CBF3C8B3DAB3DB53DCE3DD73DDC3DEF3D033E083E1B3E313E4E3E903E953EAC3EB63EBF3E683F7"
    $sBinary &= "13F793FB53FBF3FC83FD13FE63FEF3F002000003C0000001E30273030303E3047306930703083308D30933099309F30A530AB30B130B730BD30C330C930CF30D5"
    $sBinary &= "30DB30E130F1306531000000300000900000009430C030C430CC30D030D430D830DC30E030E430E830FC3000310431A431A831B03108322032CC32D032E032E43"
    $sBinary &= "2EC320433143318331C33203324332C3330333833503354336C337033843394339833A833B833C833CC33D033E8334837683774378C3790379837A037A837AC37"
    $sBinary &= "C437C837D037D437D837E037F437FC3710381838203828383C380040000010000000183034305030783000000000"

    Return Binary($sBinary)
EndFunc


