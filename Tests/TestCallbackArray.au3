#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#include ".\..\UnitTest.au3"
#include ".\..\CallbackArray.au3"

Global Enum $CALLBACKID_TEST_1, _
            $CALLBACKID_TEST_2, _
            $CALLBACKID_TEST_3, _
            $CALLBACKID_TEST_4, _
            $CALLBACKID_TEST_5, _
            $CALLBACKID_TEST_6, _
            $__CALLBACKID_COUNT



_UnitTest_Init()
_test_CallbackArray_Init()
_test_CallbackArray_Add()
_test_CallbackArray_Remove()
_test_CallbackArray_Get()
_UnitTest_Exit()



Func _test_CallbackArray_Init()
    _UnitTest_Start("_CallbackArray_Init")

    _UnitTest_AssertNotEqual(Null, "_CallbackArray_Init", $__CALLBACKID_COUNT)
    _UnitTest_AssertEqual(Null, "_CallbackArray_Init", -5)
    _UnitTest_AssertEqual(Null, "_CallbackArray_Init", 'Hello World!')
    _UnitTest_AssertEqual(Null, "_CallbackArray_Init", 0)

    _UnitTest_Stop()
EndFunc



Func _test_CallbackArray_Add()
    _UnitTest_Start("_CallbackArray_Add")

    Local $hTestCallbackArray = _CallbackArray_Init($__CALLBACKID_COUNT)

    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_1, CB1)
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_2, CB2)
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_3, CB3)
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_4, CB4)
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_5, CB5)
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_6, CB6)
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_1, "CB1")
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_2, "CB2")
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_3, "CB3")
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_4, "CB4")
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_5, "CB5")
    _UnitTest_AssertEqual(1, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_6, "CB6")
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_1, "Callback_Test")
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_2, Null)
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, $CALLBACKID_TEST_2, Default)
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, Default, "CB3")
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, Default, Default)
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, Null, "CB3")
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, Null, Default)
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, Null, Null)
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", Default, $CALLBACKID_TEST_6, "CB6")
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, "Test", "Callback_")
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, "Test", "Callback_")
    _UnitTest_AssertEqual(0, "_CallbackArray_Add", $hTestCallbackArray, "Test", "Callback_")

    _UnitTest_Stop()
EndFunc



Func _test_CallbackArray_Remove()
    _UnitTest_Start("_CallbackArray_Remove")

    Local $hOriginalCallbackArray = _CallbackArray_Init($__CALLBACKID_COUNT)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_1, CB1)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_2, CB2)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_2, CB2)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_3, CB3)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_4, CB4)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_4, CB4)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_4, CB4)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_5, CB5)
    _CallbackArray_Add($hOriginalCallbackArray, $CALLBACKID_TEST_6, CB6)
    Local $hTestCallbackArray = 0
    
    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_1, CB1)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_2, CB2)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_3, CB3)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_4, CB4)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_5, CB5)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_6, CB6)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_1, "CB1")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_2, "CB2")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_3, "CB3")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_4, "CB4")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_5, "CB5")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(1, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_6, "CB6")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_1, "Callback_Test")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_2, Null)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, $CALLBACKID_TEST_2, Default)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, Default, "CB3")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, Default, Default)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, Null, "CB3")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, Null, Default)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, Null, Null)

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", Default, $CALLBACKID_TEST_6, "CB6")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, "Test", "Callback_")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, "Test", "Callback_")

    $hTestCallbackArray = $hOriginalCallbackArray
    _UnitTest_AssertEqual(0, "_CallbackArray_Remove", $hTestCallbackArray, "Test", "Callback_")

    _UnitTest_Stop()
EndFunc



Func _test_CallbackArray_Get()
    _UnitTest_Start("_CallbackArray_Get")

    Local $hTestCallbackArray = _CallbackArray_Init($__CALLBACKID_COUNT)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_1, CB1)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_2, CB2)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_2, CB2)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_3, CB3)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_4, CB4)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_5, CB5)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_5, CB5)
    _CallbackArray_Add($hTestCallbackArray, $CALLBACKID_TEST_6, CB6)

    _UnitTest_AssertCallback("_test_Get_CB", 2, "_CallbackArray_Get", $hTestCallbackArray, $CALLBACKID_TEST_1)
    _UnitTest_AssertCallback("_test_Get_CB", 3, "_CallbackArray_Get", $hTestCallbackArray, $CALLBACKID_TEST_2)
    _UnitTest_AssertCallback("_test_Get_CB", 2, "_CallbackArray_Get", $hTestCallbackArray, $CALLBACKID_TEST_3)
    _UnitTest_AssertCallback("_test_Get_CB", 2, "_CallbackArray_Get", $hTestCallbackArray, $CALLBACKID_TEST_4)
    _UnitTest_AssertCallback("_test_Get_CB", 3, "_CallbackArray_Get", $hTestCallbackArray, $CALLBACKID_TEST_5)
    _UnitTest_AssertCallback("_test_Get_CB", 2, "_CallbackArray_Get", $hTestCallbackArray, $CALLBACKID_TEST_6)

    _UnitTest_Stop()
EndFunc



Func _test_Get_CB($vExpected, $vGot, ByRef $sResultOut)
    $sResultOut = __UnitTest_GetDisplayVarValue($vGot)
    Return $vExpected = UBound($vGot)
EndFunc



Func CB1()
EndFunc



Func CB2()
EndFunc



Func CB3()
EndFunc



Func CB4()
EndFunc



Func CB5()
EndFunc



Func CB6()
EndFunc



