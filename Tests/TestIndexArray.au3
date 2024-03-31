#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#AutoIt3Wrapper_UseX64=n



#include ".\..\UnitTest.au3"
#include ".\..\IndexArray.au3"



If @ScriptName == "TestIndexArray.au3" Then
    _UnitTest_Init()
    _test_IndexArray()
    _UnitTest_Exit()
EndIf



Func _test_IndexArray()
    _test_IndexArray_Init()
    _test_IndexArray_IsIndexArray()
    _test_IndexArray_IsIndexValid()
    _test_IndexArray_GetSize()
    _test_IndexArray_Resize()
    _test_IndexArray_Get()
    _test_IndexArray_Set()
    _test_IndexArray_Reset()
EndFunc



Func _test_IndexArray_Init()
    _UnitTest_Start("_IndexArray_Init()")

    _UnitTest_AssertNotEqual(Null, "_IndexArray_Init", 1)
    _UnitTest_AssertNotEqual(Null, "_IndexArray_Init", 8)
    _UnitTest_AssertNotEqual(Null, "_IndexArray_Init", 16)
    _UnitTest_AssertNotEqual(Null, "_IndexArray_Init", 24)
    _UnitTest_AssertNotEqual(Null, "_IndexArray_Init", 32)
    _UnitTest_AssertNotEqual(Null, "_IndexArray_Init", 4096)
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", 0)
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", -42)
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", Default)
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", "Null")
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", 0.444)
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", 17.6)
    _UnitTest_AssertEqual(Null, "_IndexArray_Init", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_IndexArray_IsIndexArray()
    _UnitTest_Start("_IndexArray_IsIndexArray()")

    Local $aIndexArray = _IndexArray_Init(128)
    Local $aFakeArray = ["Hello", "World", "!", 111]

    _UnitTest_AssertEqual(1, "_IndexArray_IsIndexArray", $aIndexArray)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", $aFakeArray)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", 0)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", -42)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", Default)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", Null)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", "Null")
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", 0.444)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", 17.6)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexArray", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_IndexArray_IsIndexValid()
    _UnitTest_Start("_IndexArray_IsIndexValid()")

    Local $aIndexArray = _IndexArray_Init(128)
    Local $aFakeArray = ["Hello", "World", "!", 111]

    _UnitTest_AssertEqual(1, "_IndexArray_IsIndexValid", $aIndexArray, 0)
    _UnitTest_AssertEqual(1, "_IndexArray_IsIndexValid", $aIndexArray, 64)
    _UnitTest_AssertEqual(1, "_IndexArray_IsIndexValid", $aIndexArray, 127)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, 128)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, $aFakeArray)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, -42)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, Default)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, Null)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, "Null")
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, 0.444)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, 17.6)
    _UnitTest_AssertEqual(0, "_IndexArray_IsIndexValid", $aIndexArray, DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_IndexArray_GetSize()
    _UnitTest_Start("_IndexArray_GetSize()")

    Local $aIndexArray = _IndexArray_Init(128)
    Local $aFakeArray = ["Hello", "World", "!", 111]

    _UnitTest_AssertEqual(128, "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual($aFakeArray, "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual(-42, "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual(Default, "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual(Null, "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual("Null", "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual(0.444, "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual(17.6, "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertNotEqual(DllStructCreate("DWORD"), "_IndexArray_GetSize", $aIndexArray)
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", $aFakeArray)
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", -42)
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", Default)
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", Null)
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", "Null")
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", 0.444)
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", 17.6)
    _UnitTest_AssertEqual(0, "_IndexArray_GetSize", DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_IndexArray_Resize()
    _UnitTest_Start("_IndexArray_Resize()")

    Local $aIndexArray = _IndexArray_Init(128)
    Local $aFakeArray = ["Hello", "World", "!", 111]

    _UnitTest_AssertEqual(1, "_IndexArray_Resize", $aIndexArray, 64)
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, $aFakeArray)
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, -42)
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, Default)
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, Null)
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, "Null")
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, 0.444)
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, 17.6)
    _UnitTest_AssertEqual(0, "_IndexArray_Resize", $aIndexArray, DllStructCreate("DWORD"))

    _UnitTest_Stop()
EndFunc



Func _test_IndexArray_Get()
    _UnitTest_Start("_IndexArray_Get()")

    Local $aIndexArray = _IndexArray_Init(8)

    _UnitTest_AssertEqual(64     , "_IndexArray_Get", $aIndexArray, 8, 64)
    _UnitTest_AssertEqual(-42    , "_IndexArray_Get", $aIndexArray, 8, -42)
    _UnitTest_AssertEqual(Default, "_IndexArray_Get", $aIndexArray, 8, Default)
    _UnitTest_AssertEqual(Null   , "_IndexArray_Get", $aIndexArray, 8, Null)
    _UnitTest_AssertEqual("Null" , "_IndexArray_Get", $aIndexArray, 8, "Null")
    _UnitTest_AssertEqual(0.444  , "_IndexArray_Get", $aIndexArray, 8, 0.444)
    _UnitTest_AssertEqual(17.6   , "_IndexArray_Get", $aIndexArray, 8, 17.6)

    _UnitTest_AssertEqual(Null, "_IndexArray_Get", $aIndexArray, 0, 64)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", $aIndexArray, 0, -42)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", $aIndexArray, 0, Default)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", $aIndexArray, 0, Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", $aIndexArray, 0, "Null")
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", $aIndexArray, 0, 0.444)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", $aIndexArray, 0, 17.6)

    _UnitTest_AssertEqual(Null, "_IndexArray_Get", 64, 0, Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", -42, 0, Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", Default, 0, Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", Null, 0, Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", "Null", 0, Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", 0.444, 0, Null)
    _UnitTest_AssertEqual(Null, "_IndexArray_Get", 17.6, 0, Null)

    _UnitTest_Stop()
EndFunc



Func _test_IndexArray_Set()
    _UnitTest_Start("_IndexArray_Set()")

    Local $aIndexArray = _IndexArray_Init(8)

    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 0, 64)
    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 1, -42)
    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 2, Default)
    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 3, Null)
    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 4, "Null")
    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 5, 0.444)
    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 6, 17.6)
    _UnitTest_AssertEqual(1, "_IndexArray_Set", $aIndexArray, 42, 666)
    _UnitTest_AssertEqual(0, "_IndexArray_Set", $aIndexArray, -42, 666)

    _UnitTest_AssertEqual(0, "_IndexArray_Set", 64     , 0, "Test")
    _UnitTest_AssertEqual(0, "_IndexArray_Set", -42    , 0, "Test")
    _UnitTest_AssertEqual(0, "_IndexArray_Set", Default, 0, "Test")
    _UnitTest_AssertEqual(0, "_IndexArray_Set", Null   , 0, "Test")
    _UnitTest_AssertEqual(0, "_IndexArray_Set", "Null" , 0, "Test")
    _UnitTest_AssertEqual(0, "_IndexArray_Set", 0.444  , 0, "Test")
    _UnitTest_AssertEqual(0, "_IndexArray_Set", 17.6   , 0, "Test")

    _UnitTest_Stop()
EndFunc



Func _test_IndexArray_Reset()
    _UnitTest_Start("_IndexArray_Reset()")

    Local $aIndexArray = _IndexArray_Init(8)

    _UnitTest_AssertEqual(1, "_IndexArray_Reset", $aIndexArray, 44)
    _UnitTest_AssertEqual(1, "_IndexArray_Reset", $aIndexArray, 20000)
    _UnitTest_AssertEqual(1, "_IndexArray_Reset", $aIndexArray, 66666)
    _UnitTest_AssertEqual(0, "_IndexArray_Reset", $aIndexArray, -44)
    _UnitTest_AssertEqual(0, "_IndexArray_Reset", $aIndexArray, "42")
    _UnitTest_AssertEqual(1, "_IndexArray_Reset", $aIndexArray, 16)
    _UnitTest_AssertEqual(0, "_IndexArray_Reset", $aIndexArray, Default)
    _UnitTest_AssertEqual(0, "_IndexArray_Reset", $aIndexArray, Null)
    _UnitTest_AssertEqual(0, "_IndexArray_Reset", $aIndexArray, 0.444)
    _UnitTest_AssertEqual(0, "_IndexArray_Reset", $aIndexArray, 17.6)

    _UnitTest_Stop()
EndFunc



