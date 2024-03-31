#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#AutoIt3Wrapper_UseX64=n


#include ".\..\UnitTest.au3"
#include ".\..\BigMask.au3"
#include ".\..\Integer.au3"



If @ScriptName == "TestBigMask.au3" Then
    _UnitTest_Init()
    _test_BigMask()
    _UnitTest_Exit()
EndIf



Func _test_BigMask()
    _test_BigMask_Init()
    _test_BigMask_IsBigMask()
    _test_BigMask_IsValidIndex()
    _test_BigMask_IsValidGroup()
    _test_BigMask_GetFlag()
    _test_BigMask_SetFlag()
    _test_BigMask_SetGroup()
    _test_BigMask_GetGroup()
    _test_BigMask_GetSize()
    _test_BigMask_GetGroupSize()
    _test_BigMask_ToBinary()
EndFunc



Func _test_BigMask_Init()
    _UnitTest_Start("_BigMask_Init()")

    _UnitTest_AssertNotEqual(Null, "_BigMask_Init", 1)
    _UnitTest_AssertNotEqual(Null, "_BigMask_Init", 8)
    _UnitTest_AssertNotEqual(Null, "_BigMask_Init", 16)
    _UnitTest_AssertNotEqual(Null, "_BigMask_Init", 24)
    _UnitTest_AssertNotEqual(Null, "_BigMask_Init", 32)
    _UnitTest_AssertNotEqual(Null, "_BigMask_Init", 4096)
    _UnitTest_AssertEqual(Null, "_BigMask_Init", 0)
    _UnitTest_AssertEqual(Null, "_BigMask_Init", -42)
    _UnitTest_AssertEqual(Null, "_BigMask_Init", Default)
    _UnitTest_AssertEqual(Null, "_BigMask_Init", Null)
    _UnitTest_AssertEqual(Null, "_BigMask_Init", "Null")
    _UnitTest_AssertEqual(Null, "_BigMask_Init", 0.444)
    _UnitTest_AssertEqual(Null, "_BigMask_Init", 17.6)
    _UnitTest_AssertEqual(Null, "_BigMask_Init", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_IsBigMask()
    _UnitTest_Start("_BigMask_IsBigMask()")

    Local $aBigMask = _BigMask_Init(128)
    _BigMask_SetGroup($aBigMask, 0, 0xFFFFFFFF)
    _BigMask_SetGroup($aBigMask, 1, 0xF2354733)
    _BigMask_SetGroup($aBigMask, 2, 0xFF7FFF7F)
    _BigMask_SetGroup($aBigMask, 3, 0xE23E4730)

    Local $aFakeBigMask = [0xFFFFFFFF, 0xF2354733, 0xFF7FFF7F, 0xE23E4730]

    _UnitTest_AssertEqual(1, "_BigMask_IsBigMask", $aBigMask)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", $aFakeBigMask)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", 0)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", -42)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", Default)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", Null)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", "Null")
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", 0.444)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_IsBigMask", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_IsValidIndex()
    _UnitTest_Start("_BigMask_IsValidIndex()")

    Local $aBigMask = _BigMask_Init(32)

    _UnitTest_AssertEqual(1, "_BigMask_IsValidIndex", $aBigMask, 6)
    _UnitTest_AssertEqual(1, "_BigMask_IsValidIndex", $aBigMask, 0)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidIndex", $aBigMask, -42)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidIndex", $aBigMask, Default)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidIndex", $aBigMask, Null)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidIndex", $aBigMask, "Null")
    _UnitTest_AssertEqual(0, "_BigMask_IsValidIndex", $aBigMask, 0.444)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidIndex", $aBigMask, 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidIndex", $aBigMask, DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_IsValidGroup()
    _UnitTest_Start("_BigMask_IsValidGroup()")

    Local $aBigMask = _BigMask_Init(256, False)

    _UnitTest_AssertEqual(1, "_BigMask_IsValidGroup", $aBigMask, 6)
    _UnitTest_AssertEqual(1, "_BigMask_IsValidGroup", $aBigMask, 0)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, 8)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, -42)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, Default)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, Null)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, "Null")
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, 0.444)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_IsValidGroup", $aBigMask, DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_GetFlag()
    _UnitTest_Start("_BigMask_GetFlag()")

    Local $aBigMask = _BigMask_Init(256, True)

    _UnitTest_AssertEqual(1, "_BigMask_GetFlag", $aBigMask, 6)
    _UnitTest_AssertEqual(1, "_BigMask_GetFlag", $aBigMask, 0)
    _UnitTest_AssertEqual(1, "_BigMask_GetFlag", $aBigMask, 8)
    _UnitTest_AssertEqual(1, "_BigMask_GetFlag", $aBigMask, 255)
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, 256)
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, -42)
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, Default)
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, Null)
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, "Null")
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, 0.444)
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_GetFlag", $aBigMask, DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_SetFlag()
    _UnitTest_Start("_BigMask_SetFlag()")

    Local $aBigMask = _BigMask_Init(256, True)

    _UnitTest_AssertEqual(1, "_BigMask_SetFlag", $aBigMask, 6, 0)
    _UnitTest_AssertEqual(1, "_BigMask_SetFlag", $aBigMask, 0, 0)
    _UnitTest_AssertEqual(1, "_BigMask_SetFlag", $aBigMask, 8, 0)
    _UnitTest_AssertEqual(1, "_BigMask_SetFlag", $aBigMask, 8, True)
    _UnitTest_AssertEqual(1, "_BigMask_SetFlag", $aBigMask, 255, 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 256, 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 5, "Hello")
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 6, "World")
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 17, Ptr(9))
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 77, DllStructCreate("DWORD"))
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 42, Null)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 3, Default)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, -42, 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, Default, 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, Null, 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, "Null", 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 0.444, 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, 17.6, 0)
    _UnitTest_AssertEqual(0, "_BigMask_SetFlag", $aBigMask, DllStructCreate("DWORD"), 0)

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_SetGroup()
    _UnitTest_Start("_BigMask_SetGroup()")

    Local $aBigMask = _BigMask_Init(256, True)

    _UnitTest_AssertEqual(1, "_BigMask_SetGroup", $aBigMask, 6, 0x66666666)
    _UnitTest_AssertEqual(1, "_BigMask_SetGroup", $aBigMask, 0, 0x66666666)
    _UnitTest_AssertEqual(1, "_BigMask_SetGroup", $aBigMask, 7, 0x66666666)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, 8, 0x66666666)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, -42, 0x66666666)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, Default, 0x666666660)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, Null, 0x66666666)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, "Null", 0x66666666)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, 0.444, 0x66666666)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, 17.6, 0x66666666)
    _UnitTest_AssertEqual(0, "_BigMask_SetGroup", $aBigMask, DllStructCreate("DWORD"), 0x66666666)

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_GetGroup()
    _UnitTest_Start("_BigMask_GetGroup()")

    Local $aBigMask = _BigMask_Init(256, True)

    _UnitTest_AssertEqual(-1, "_BigMask_GetGroup", $aBigMask, 6)
    _UnitTest_AssertEqual(-1, "_BigMask_GetGroup", $aBigMask, 0)
    _UnitTest_AssertEqual(-1, "_BigMask_GetGroup", $aBigMask, 7)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, 8)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, -42)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, Default)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, Null)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, "Null")
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, 0.444)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, DllStructCreate("DWORD"))

    _BigMask_SetGroup($aBigMask, 0, 0x66666666)
    _BigMask_SetGroup($aBigMask, 1, 0x77777777)
    _BigMask_SetGroup($aBigMask, 2, 0x88888888)
    _BigMask_SetGroup($aBigMask, 3, 0x99999999)

    _UnitTest_AssertEqual(0x66666666, "_BigMask_GetGroup", $aBigMask, 0)
    _UnitTest_AssertEqual(0x77777777, "_BigMask_GetGroup", $aBigMask, 1)
    _UnitTest_AssertEqual(0x88888888, "_BigMask_GetGroup", $aBigMask, 2)
    _UnitTest_AssertEqual(0x99999999, "_BigMask_GetGroup", $aBigMask, 3)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroup", $aBigMask, Default)

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_GetSize()
    _UnitTest_Start("_BigMask_GetSize()")

    Local $aBigMask = _BigMask_Init(256, True)
    _UnitTest_AssertEqual(256, "_BigMask_GetSize", $aBigMask)

    $aBigMask = _BigMask_Init(32)
    _UnitTest_AssertEqual(32, "_BigMask_GetSize", $aBigMask)

    $aBigMask = _BigMask_Init(64)
    _UnitTest_AssertEqual(64, "_BigMask_GetSize", $aBigMask)

    $aBigMask = _BigMask_Init(42)
    _UnitTest_AssertEqual(42, "_BigMask_GetSize", $aBigMask)

    _UnitTest_AssertEqual(0, "_BigMask_GetSize", Null)
    _UnitTest_AssertEqual(0, "_BigMask_GetSize", Default)
    _UnitTest_AssertEqual(0, "_BigMask_GetSize", -42)
    _UnitTest_AssertEqual(0, "_BigMask_GetSize", "Null")
    _UnitTest_AssertEqual(0, "_BigMask_GetSize", 0.444)
    _UnitTest_AssertEqual(0, "_BigMask_GetSize", 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_GetSize", 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_GetSize", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_GetGroupSize()
    _UnitTest_Start("_BigMask_GetGroupSize()")

    Local $aBigMask = _BigMask_Init(256, True)
    _UnitTest_AssertEqual(8, "_BigMask_GetGroupSize", $aBigMask)

    $aBigMask = _BigMask_Init(32)
    _UnitTest_AssertEqual(1, "_BigMask_GetGroupSize", $aBigMask)

    $aBigMask = _BigMask_Init(64)
    _UnitTest_AssertEqual(2, "_BigMask_GetGroupSize", $aBigMask)

    $aBigMask = _BigMask_Init(42)
    _UnitTest_AssertEqual(2, "_BigMask_GetGroupSize", $aBigMask)

    $aBigMask = _BigMask_Init(17)
    _UnitTest_AssertEqual(1, "_BigMask_GetGroupSize", $aBigMask)

    $aBigMask = _BigMask_Init(128)
    _UnitTest_AssertEqual(4, "_BigMask_GetGroupSize", $aBigMask)

    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", Null)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", Default)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", -42)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", "Null")
    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", 0.444)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", 17.6)
    _UnitTest_AssertEqual(0, "_BigMask_GetGroupSize", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_BigMask_ToBinary()
    _UnitTest_Start("_BigMask_ToBinary()")

    Local $aBigMask = _BigMask_Init(64)
    _UnitTest_AssertEqual(Binary("0x0000000000000000"), "_BigMask_ToBinary", $aBigMask)

    $aBigMask = _BigMask_Init(32)
    _UnitTest_AssertEqual(Binary("0x00000000"), "_BigMask_ToBinary", $aBigMask)

    $aBigMask = _BigMask_Init(32, 1)
    _UnitTest_AssertEqual(Binary("0xFFFFFFFF"), "_BigMask_ToBinary", $aBigMask)

    $aBigMask = _BigMask_Init(17, 1)
    _UnitTest_AssertEqual(Binary("0xFFFFFF"), "_BigMask_ToBinary", $aBigMask)

    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", Null)
    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", Default)
    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", -42)
    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", "Null")
    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", 0.444)
    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", 17.6)
    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", 17.6)
    _UnitTest_AssertEqual(Binary("0x00"), "_BigMask_ToBinary", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



