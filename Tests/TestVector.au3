#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#include ".\..\UnitTest.au3"
#include ".\..\Vector.au3"



If @ScriptName == "TestVector.au3" Then
    _UnitTest_Init()
    _test_Vector()
    _UnitTest_Exit()
EndIf



Func _test_Vector()
    _test_Vector_Init()
    _test_Vector_IsVector()
    _test_Vector_SetComparatorCallback()
    _test_Vector_Push()
    _test_Vector_Pop()
    _test_Vector_GetSize()
    _test_Vector_GetCapacity()
EndFunc



Func _test_Vector_Init()
    _UnitTest_Start("_Vector_Init()")

    _UnitTest_AssertEqual(Null, "_Vector_Init", 32, Null, 1)
    _UnitTest_AssertEqual(Null, "_Vector_Init", 32, Null, 1.4)
    _UnitTest_AssertNotEqual(Null, "_Vector_Init", 32, Null, 10.0)
    _UnitTest_AssertNotEqual(Null, "_Vector_Init")

    _UnitTest_Stop()
EndFunc


Func _test_Vector_IsVector()
    Local $aTestVector = _Vector_Init()
    _UnitTest_Start("_Vector_IsVector")

    _UnitTest_AssertEqual(1, "_Vector_IsVector", $aTestVector)
    _UnitTest_AssertEqual(0, "_Vector_IsVector", True)
    _UnitTest_AssertEqual(0, "_Vector_IsVector", 100)
    _UnitTest_AssertEqual(0, "_Vector_IsVector", VectorCallback)
    _UnitTest_AssertEqual(0, "_Vector_IsVector", "VectorCallback")
    _UnitTest_AssertEqual(0, "_Vector_IsVector", "IAmAVector")
    _UnitTest_AssertEqual(0, "_Vector_IsVector", Binary('0xFF'))

    _UnitTest_Stop()
EndFunc



Func _test_Vector_SetComparatorCallback()
    _UnitTest_Start("_Vector_SetComparatorCallback")

    Local $bTest
    Local $aTestVector = _Vector_Init()

    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", Default, 'ThisShouldFail')
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", "Test", 0)
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", Null, True)
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", 100, Binary('0xFF'))
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", 0x4444, 10.0)
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", 0.7766, "VectorCallback")
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", Default, VectorCallback)

    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", $aTestVector, 'ThisShouldFail')
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", $aTestVector, 0)
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", $aTestVector, True)
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", $aTestVector, Binary('0xFF'))
    _UnitTest_AssertEqual(0, "_Vector_SetComparatorCallback", $aTestVector, 10.0)
    _UnitTest_AssertEqual(1, "_Vector_SetComparatorCallback", $aTestVector, "VectorCallback")
    _UnitTest_AssertEqual(1, "_Vector_SetComparatorCallback", $aTestVector, VectorCallback)

    _UnitTest_Stop()
EndFunc




Func _test_Vector_Push()
    Local $aTestVector = _Vector_Init()
    _UnitTest_Start("_Vector_Push")

    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, 10)
    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, 'Hello World')
    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, Binary('0xDEADBEEF'))
    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, Default)
    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, Null)
    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, True)
    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, False)
    _UnitTest_AssertEqual(1, "_Vector_Push", $aTestVector, DllStructCreate('DWORD'))
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, 10)
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, 'Hello World')
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, Binary('0xDEADBEEF'))
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, Default)
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, Null)
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, True)
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, False)
    _UnitTest_AssertEqual(0, "_Vector_Push", Default, DllStructCreate('DWORD'))

    _UnitTest_Stop()
EndFunc



Func _test_Vector_Pop()
    Local $aTestVector = _Vector_Init()
    _UnitTest_Start("_Vector_Pop")

    _UnitTest_AssertEqual(Null, "_Vector_Pop", $aTestVector)

    _Vector_Push($aTestVector, False)
    _UnitTest_AssertEqual(False, "_Vector_Pop", $aTestVector)
    _UnitTest_AssertNotEqual(True, "_Vector_Pop", $aTestVector)

    _Vector_Push($aTestVector, Null)
    _UnitTest_AssertEqual(Null, "_Vector_Pop", $aTestVector)

    _Vector_Push($aTestVector, Default)
    _UnitTest_AssertEqual(Default, "_Vector_Pop", $aTestVector)

    _Vector_Push($aTestVector, Binary('0xDEADBEEF'))
    _UnitTest_AssertEqual(Binary('0xDEADBEEF'), "_Vector_Pop", $aTestVector)

    _Vector_Push($aTestVector, 'Hello World')
    _UnitTest_AssertEqualCaseSensitive('Hello World', "_Vector_Pop", $aTestVector)

    _Vector_Push($aTestVector, 10)
    _UnitTest_AssertEqual(10, "_Vector_Pop", $aTestVector)

    $aTestVector = _Vector_Init()
    _UnitTest_AssertEqual(Null, "_Vector_Pop", $aTestVector)

    _UnitTest_Stop()
EndFunc



Func _test_Vector_GetSize()
    Local $aTestVector = _Vector_Init()
    _UnitTest_Start("_Vector_GetSize")

    _Vector_Push($aTestVector, 10)
    _Vector_Push($aTestVector, 'Hello World')
    _Vector_Push($aTestVector, Binary('0xDEADBEEF'))
    _Vector_Push($aTestVector, Default)
    _Vector_Push($aTestVector, Null)
    _Vector_Push($aTestVector, True)
    _Vector_Push($aTestVector, False)
    _Vector_Push($aTestVector, DllStructCreate('DWORD'))

    _UnitTest_AssertEqual(8, "_Vector_GetSize", $aTestVector)

    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)

    _UnitTest_AssertNotEqual(8, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertEqual(6, "_Vector_GetSize", $aTestVector)

    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)

    _UnitTest_AssertNotEqual(8, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertNotEqual(6, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertNotEqual(3, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertEqual(4, "_Vector_GetSize", $aTestVector)

    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)
    _Vector_Pop($aTestVector)

    _UnitTest_AssertNotEqual(8, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertNotEqual(6, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertNotEqual(3, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertNotEqual(2, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertNotEqual(1, "_Vector_GetSize", $aTestVector)
    _UnitTest_AssertEqual(0, "_Vector_GetSize", $aTestVector)

    _UnitTest_Stop()
EndFunc



Func _test_Vector_GetCapacity()
    _UnitTest_Start("_Vector_GetCapacity")

    Local $aTestVector = _Vector_Init()
    _UnitTest_AssertEqual(32, "_Vector_GetCapacity", $aTestVector)

    $aTestVector = _Vector_Init(500)
    _UnitTest_AssertNotEqual(32, "_Vector_GetCapacity", $aTestVector)
    _UnitTest_AssertEqual(500, "_Vector_GetCapacity", $aTestVector)

    $aTestVector = _Vector_Init(0)
    _UnitTest_AssertNotEqual(32, "_Vector_GetCapacity", $aTestVector)
    _UnitTest_AssertNotEqual(500, "_Vector_GetCapacity", $aTestVector)
    _UnitTest_AssertEqual(0, "_Vector_GetCapacity", $aTestVector)

    $aTestVector = _Vector_Init(3)
    _UnitTest_AssertNotEqual(3, "_Vector_GetCapacity", $aTestVector)

    $aTestVector = _Vector_Init(-100)
    _UnitTest_AssertNotEqual(-100, "_Vector_GetCapacity", $aTestVector)


    $aTestVector = _Vector_Init(4)
    _UnitTest_AssertNotEqual(0, "_Vector_GetCapacity", $aTestVector)

    _Vector_Reserve($aTestVector, 1000)
    _UnitTest_AssertGreaterEqual(1000, "_Vector_GetCapacity", $aTestVector)

    _UnitTest_Stop()
EndFunc



Func VectorCallback(Const $vVal1, Const $vVal2)
    #forceref $vVal1, $vVal2
EndFunc


