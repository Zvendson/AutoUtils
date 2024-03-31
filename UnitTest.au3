#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author(s):       Zvend       Nadav
 Discord(s):      zvend       hero_of_abaddon

 Description:
    Small UnitTest library for GitHub Workflows

 Script Functions:
    _UnitTest_Init($fuCallback = __UnitTest_DefaultOut, $fuHandleConverter = "")              -> 0
    _UnitTest_Exit(Const $bExit = 1)                                                          -> Bool
    _UnitTest_Start(Const $sTitle)                                                            -> 0
    _UnitTest_Stop()                                                                          -> 0
    _UnitTest_AssertEqual(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30)                 -> Bool
    _UnitTest_AssertNotEqual(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30)              -> Bool
    _UnitTest_AssertLesser(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30)                -> Bool
    _UnitTest_AssertGreater(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30)               -> Bool
    _UnitTest_AssertLesserEqual(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30)           -> Bool
    _UnitTest_AssertGreaterEqual(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30)          -> Bool
    _UnitTest_AssertEqualCaseSensitive(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30)    -> Bool
    _UnitTest_AssertNotEqualCaseSensitive(Const $vExpected, $sFuncName, $vArg1, ..., $vArg30) -> Bool
    _UnitTest_AssertCallback($fuCallback, Const $vExpected, $sFuncName, $vArg1, ..., $vArg30) -> Bool
    _UnitTest_ConvertMessage($aArgs)                                                          -> String

 Internal Functions:
    __UnitTest_FuncCallToString($sFuncName, $aParams, $vResult)                                  -> String
    __UnitTest_Assert(ByRef $aArgs, $sFuncName, $vArg1, ..., $vArg30)                            -> Variant
    __UnitTest_DefaultOut($aArgs)                                                                -> 0
    __UnitTest_GetDisplayVarValue($vValue)                                                       -> String
    __UnitTest_StructToArray($tStruct, $nOverflowAt = 5000)                                      -> Array
    __UnitTest_CallResult(Const $sAssertName, Const $bResult, Const $nTimeDiff, Const $sCallOut) -> 0
    __UnitTest_DefaultHandleConverter($vValue)                                                   -> String|0

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#include ".\String.au3"
#include ".\Function.au3"
#include ".\Vector.au3"
#include ".\CallbackArray.au3"
#include ".\BigMask.au3"
#include ".\IndexArray.au3"



Global $__g_fuUT_OutFunction             ;Requires one param: $aArgs
Global $__g_fuUT_HandleConverterFunction ;Requires one param: $vValue
Global $__g_nUT_UnitTestCount = 0
Global $__g_nUT_UnitTestSuccessCount = 0
Global $__g_nUT_UnitTestFailCount = 0

Global $__g_nUT_GlobalTime = 0
Global $__g_nUT_LocalTime = 0
Global $__g_nUT_TempTime = 0
Global $__g_nUT_TempMaxLen = 0



Func _UnitTest_Init($fuCallback = __UnitTest_DefaultOut, $fuHandleConverter = "") ;-> 0
    $__g_fuUT_OutFunction             = $fuCallback
    $__g_fuUT_HandleConverterFunction = $fuHandleConverter
    $__g_nUT_UnitTestCount            = 0
    $__g_nUT_UnitTestSuccessCount     = 0
    $__g_nUT_UnitTestFailCount        = 0
    $__g_nUT_GlobalTime               = 0
    $__g_nUT_LocalTime                = 0
EndFunc



Func _UnitTest_Exit(Const $bExit = 1) ;-> Bool
    Local $aArgs1 = [2, "%d total UnitTests.\n", $__g_nUT_UnitTestCount]
    Call($__g_fuUT_OutFunction, $aArgs1)

    Local $aArgs2 = [2, "%d UnitTests were successful.\n", $__g_nUT_UnitTestSuccessCount]
    Call($__g_fuUT_OutFunction, $aArgs2)

    Local $aArgs3 = [2, "%d UnitTests have failed.\n", $__g_nUT_UnitTestFailCount]
    Call($__g_fuUT_OutFunction, $aArgs3)

    Local $aArgs4 = [2, "Test time passed: %0.3f ms\n", $__g_nUT_GlobalTime]
    Call($__g_fuUT_OutFunction, $aArgs4)

    If Not $bExit Then
        Return $__g_nUT_UnitTestFailCount = 0
    EndIf

    If $__g_nUT_UnitTestFailCount Then
        Exit(1)
    EndIf

    Exit(0)
EndFunc



Func _UnitTest_Start(Const $sTitle) ;-> 0
    Local $aArgs = [2, "> Testing: %s\n", $sTitle]
    Call($__g_fuUT_OutFunction, $aArgs)
    $__g_nUT_LocalTime = 0
    $__g_nUT_TempMaxLen = 0
EndFunc



Func _UnitTest_Stop() ;-> 0
    $__g_nUT_GlobalTime += $__g_nUT_LocalTime

    Local $aArgs1 = [1, ">\t%s\n", _String_Repeat("-", $__g_nUT_TempMaxLen - 3)]
    Call($__g_fuUT_OutFunction, $aArgs1)

    Local $aArgs2 = [2, "  = %0.3f ms\n\n", $__g_nUT_LocalTime]
    Call($__g_fuUT_OutFunction, $aArgs2)
EndFunc



Func _UnitTest_AssertEqual(Const $vExpected, $sFuncName, _  ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = ($vResult = $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " = " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertEqual", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertNotEqual(Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = ($vResult <> $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " <> " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertNotEqual", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertLesser(Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = ($vResult < $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " < " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertLesser", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertGreater(Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = ($vResult > $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " > " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertGreater", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertLesserEqual(Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = ($vResult <= $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " <= " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertLesserEqual", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertGreaterEqual(Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = ($vResult >= $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " >= " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertGreaterEqual", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertEqualCaseSensitive(Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = ($vResult == $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " == " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertEqual(Case)", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertNotEqualCaseSensitive(Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30)
    Local $bSuccess = Not ($vResult == $vExpected)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " !== " & __UnitTest_GetDisplayVarValue($vExpected)
    __UnitTest_CallResult("AssertNotEqual(Case)", $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_AssertCallback($fuCallback, Const $vExpected, $sFuncName, _ ;-> Bool
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null)

    $fuCallback = _Function_Validate($fuCallback)
    Local $aArgs
    Local $vResult = __UnitTest_Assert($aArgs, $sFuncName, _
                        $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                        $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                        $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30, _
                        @NumParams - 1)
    Local $sResultOut = ""
    Local $bSuccess = Call($fuCallback, $vExpected, $vResult, $sResultOut)
    Local $sCallOut = __UnitTest_FuncCallToString($sFuncName, $aArgs, $vResult) & " = " & $sResultOut
    __UnitTest_CallResult(StringFormat("Assert(%s)", $fuCallback), $bSuccess, $__g_nUT_TempTime, $sCallOut)

    Return $bSuccess
EndFunc



Func _UnitTest_ConvertMessage($aArgs) ;-> String
    $aArgs[0] = "CallArgArray"
    Local $sResult = Call("StringFormat", $aArgs)
    Return SetError(@error, @extended, $sResult)
EndFunc



Func __UnitTest_FuncCallToString($sFuncName, $aParams, $vResult) ;-> String
    Local $nSize = UBound($aParams) - 1
    Local $sCallOut = $sFuncName & "("

    For $i = 1 To $nSize
        $sCallOut &= __UnitTest_GetDisplayVarValue($aParams[$i])

        If $i < $nSize Then
            $sCallOut &= ", "
        EndIf
    Next

    Return $sCallOut & StringFormat(") -> %s", __UnitTest_GetDisplayVarValue($vResult))
EndFunc



Func __UnitTest_Assert(ByRef $aArgs, $sFuncName, _ ;-> Variant
        $vArg1  = Null, $vArg2  = Null, $vArg3  = Null, $vArg4  = Null, $vArg5  = Null, _
        $vArg6  = Null, $vArg7  = Null, $vArg8  = Null, $vArg9  = Null, $vArg10 = Null, _
        $vArg11 = Null, $vArg12 = Null, $vArg13 = Null, $vArg14 = Null, $vArg15 = Null, _
        $vArg16 = Null, $vArg17 = Null, $vArg18 = Null, $vArg19 = Null, $vArg20 = Null, _
        $vArg21 = Null, $vArg22 = Null, $vArg23 = Null, $vArg24 = Null, $vArg25 = Null, _
        $vArg26 = Null, $vArg27 = Null, $vArg28 = Null, $vArg29 = Null, $vArg30 = Null, _
        $nParamCount = @NumParams)
    $__g_nUT_UnitTestCount += 1

    Local $aArguments = ["CallArgArray", _
                            $vArg1,  $vArg2,  $vArg3,  $vArg4,  $vArg5,  $vArg6,  $vArg7,  $vArg8,  $vArg9,  $vArg10, _
                            $vArg11, $vArg12, $vArg13, $vArg14, $vArg15, $vArg16, $vArg17, $vArg18, $vArg19, $vArg20, _
                            $vArg21, $vArg22, $vArg23, $vArg24, $vArg25, $vArg26, $vArg27, $vArg28, $vArg29, $vArg30 _
                        ]

    ReDim $aArguments[$nParamCount - 1]

    ;~ Pre declaring vars to safe allocation time? Not tested.
    Local $vResult   = 0
    Local $nErr      = 0

    Local $hStopwatch = TimerInit()
    $vResult = Call($sFuncName, $aArguments)
    $nErr = @error
    $__g_nUT_TempTime = TimerDiff($hStopwatch)
    $__g_nUT_LocalTime += $__g_nUT_TempTime

    $aArgs = $aArguments
    Return SetError($nErr, 0, $vResult)
EndFunc



Func __UnitTest_DefaultOut($aArgs) ;-> 0
    ConsoleWrite(_UnitTest_ConvertMessage($aArgs))
EndFunc



Func __UnitTest_GetDisplayVarValue($vValue) ;-> String
    Local $sOut = ""
    Local $nSize = 0

    Local $vConverted = __UnitTest_DefaultHandleConverter($vValue)
    If IsString($vConverted) Then
        Return $vConverted
    EndIf

    If Not ($__g_fuUT_HandleConverterFunction == "") Then
        $vConverted = Call($__g_fuUT_HandleConverterFunction, $vValue)
        If IsString($vConverted) Then
            Return $vValue
        EndIf
    EndIf

    Switch VarGetType($vValue)
        Case "Array"
            $nSize = UBound($vValue) - 1
            $sOut  = "["

            For $i = 0 To $nSize
                $sOut &= __UnitTest_GetDisplayVarValue($vValue[$i])
                If $i < $nSize Then
                    $sOut &= ", "
                EndIf
            Next

            Return $sOut & "]"

        Case "Int32", "Int64", "Ptr", "Bool"
            Return String($vValue)

        Case "Double"
            Return StringFormat("%f", $vValue)

        Case "String"
            Return StringFormat('"%s"', $vValue)

        Case "Binary"
            $nSize = BinaryLen($vValue)
            If $nSize > 16 Then
                $vValue = StringLeft($vValue, 34) & "..."
            EndIf
            Return StringFormat('Binary<%d>("%s")', $nSize, $vValue)

        Case "Function", "UserFunction"
            Return FuncName($vValue)

        Case "Keyword"
            If $vValue = Null Then
                Return "Null"
            EndIf

            Return String($vValue)

        Case "DllStruct"
            Local $sContent = __UnitTest_GetDisplayVarValue(__UnitTest_StructToArray($vValue))
            Return StringFormat("DllStruct(Size=0x%X, Ptr=0x%X, Content=%s)", DllStructGetSize($vValue), DllStructGetPtr($vValue), $sContent)

        Case "Map"
            Local $aKeys = MapKeys($vValue)
            $nSize = UBound($aKeys) - 1

            $sOut  = "{ "

            For $i = 0 To $nSize
                $sOut &= StringFormat("%s: %s", $aKeys[$i], __UnitTest_GetDisplayVarValue($vValue[$aKeys[$i]]))

                If $i < $nSize Then
                    $sOut &= ", "
                EndIf
            Next

            Return $sOut & " }"

        Case "Object"
            Return StringFormat('Objecz("%s")', ObjName($vValue))

        Case Else
            Return StringFormat("Unknown<%s>(%s)", VarGetType($vValue), $vValue)
    EndSwitch
EndFunc



Func __UnitTest_StructToArray($tStruct, $nOverflowAt = 5000) ;-> Array
    Local $vElement = Null
    Local $nElement = 1
    Local $nIndex   = 1
    Local $nSize    = 0
    Local $vOut     = Null
    Local $aOut[0]
    Local $aSubArray[0]
    Local $nErr
    Local $aError[1]
    Local $nOverflow = 0

    While True
        $vOut = Null
        $nIndex = 1
        ReDim $aSubArray[0]

        While True
            $nOverflow += 1
            If $nOverflow >= $nOverflowAt Then
                $aError[0] = "Element Overlow @" & $nOverflow
                Return $aError
            EndIf
            $vElement = DllStructGetData($tStruct, $nElement, $nIndex)
            $nErr = @error
;~             ConsoleWrite(StringFormat("%2s,%2s    %8s = %s\n", $nElement, $nIndex, VarGetType($vElement), $vElement))

            Switch $nErr
                Case 0
                Case 2
                    ExitLoop 2
                Case 3
                    If $nIndex > 2 Then
                        $vOut = $aSubArray
                    EndIf
                    ExitLoop
                Case Else
                    $aError[0] = "Unhandled Error: " & @error
                    Return $aError
            EndSwitch

            Switch VarGetType($vElement)
                Case "Int32", "Int64", "Ptr"
                    $vOut = $vElement

                Case "String"
                    If $nIndex >= 2 Then
                        $vOut = DllStructGetData($tStruct, $nElement)
                        ExitLoop
                    EndIf

                    $vOut = $vElement
                Case Else
                    ConsoleWrite("UNK: " & VarGetType($vElement) & @CRLF)
                    ContinueLoop 2

            EndSwitch

            ReDim $aSubArray[$nIndex]
            $aSubArray[$nIndex - 1] = $vElement
            $nIndex += 1
        WEnd

        $nSize = UBound($aOut)
        ReDim $aOut[$nSize + 1]
        $aOut[$nSize] = $vOut

        $nElement += 1
    WEnd

    Return $aOut
EndFunc



Func __UnitTest_CallResult(Const $sAssertName, Const $bResult, Const $nTimeDiff, Const $sCallOut) ;-> 0
    Local $sTime = StringFormat("%0.3f ms", $nTimeDiff)
    Local $sName = ""
    Local $sPrefix = ""


    If $bResult Then
        $__g_nUT_UnitTestSuccessCount += 1
        $sPrefix = '+'
        $sName = StringFormat("Success    %-20s", $sAssertName & ":")
    Else
        $__g_nUT_UnitTestFailCount += 1
        $sPrefix = '!'
        $sName = StringFormat("Failure    %-20s", $sAssertName & ":")
    EndIf

    Local $aArgs = [4, $sPrefix & "\t%-10s  " & $sName & " %s\n", $sTime, $sCallOut]
    Local $sMessage = _UnitTest_ConvertMessage($aArgs)
    If StringLen($sMessage) > $__g_nUT_TempMaxLen Then
        $__g_nUT_TempMaxLen = StringLen($sMessage)
    EndIf

    Call($__g_fuUT_OutFunction, $aArgs)

EndFunc



Func __UnitTest_DefaultHandleConverter($vValue) ;-> String|0
    Local $nSize
    Local $vTemp
    Local $sOut
    Local $nDisplaySize

    If _IndexArray_IsIndexArray($vValue) Then
        $nSize = _IndexArray_GetSize($vValue)
        $nDisplaySize = _Integer_Validate($nSize, 1, 4)
        Local $aIndexArrayContent[$nDisplaySize]
        For $i = 0 To $nDisplaySize - 1
            $aIndexArrayContent[$i] = _IndexArray_Get($vValue, $i, Null)
        Next

        If $nSize > $nDisplaySize Then
            Redim $aIndexArrayContent[$nDisplaySize + 1]
            $aIndexArrayContent[$nDisplaySize] = "..."
        EndIf

        $sOut = __UnitTest_GetDisplayVarValue($aIndexArrayContent)

        Return StringFormat("IndexArray<%d>(%s)", $nSize, $sOut)
    EndIf

    If _BigMask_IsBigMask($vValue) Then
        $vTemp = _BigMask_ToBinary($vValue)
        $nSize = BinaryLen($vTemp)
        If $nSize > 16 Then
            $vTemp = StringLeft($vTemp, 34) & "..."
        EndIf

        Return StringFormat("BigMask<%s>(Groups=%s, Mask=%s)", _BigMask_GetSize($vValue), _BigMask_GetGroupSize($vValue), $vTemp)
    EndIf

    If _Vector_IsVector($vValue) Then
        $vTemp = __UnitTest_GetDisplayVarValue(_Vector_GetDefaultValue($vValue))
        Return StringFormat("Vector<%s>(Size=%d/%d)", $vTemp, _Vector_GetSize($vValue), _Vector_GetCapacity($vValue))
    EndIf

    If _CallbackArray_IsCallbackArray($vValue) Then
        $nSize = _CallbackArray_GetSize($vValue)
        $sOut = StringFormat("CallbackArray<%d>(", $nSize)

        For $i = 0 To $nSize - 1
            $vTemp = _CallbackArray_Get($vValue, $i)
            If @error Then
                ContinueLoop
            EndIf

            $sOut &= $vTemp[0]
            If $i < $nSize - 1 Then
                $sOut &= ", "
            EndIf
        Next

        $sOut &= ")"

        Return $sOut
    EndIf

    Return 0
EndFunc



