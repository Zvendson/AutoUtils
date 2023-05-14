#include ".\..\Vector.au3"


Local $hStopwatch = TimerInit()
Test()
ConsoleWrite("Time passed: " & TimerDiff($hStopwatch) & "ms" & @CRLF)



Func Test()
    Local $aVector1 = _Vector_Init()
	For $i = 1 To 20
		_Vector_Push($aVector1, "Henlo " & $i)
	Next

    Local $aVector2 = _Vector_Init()
	For $i = 1 To 10
		_Vector_Push($aVector2, "Test " & $i)
	Next

    PrintVector($aVector1, "Vector 1")
    PrintVector($aVector2, "Vector 2")

    _Vector_SwapVectors($aVector1, $aVector2)
	ConsoleWrite(@LF & "<<Swap>>" & @LF & @LF)


    PrintVector($aVector1, "Vector 1")
    PrintVector($aVector2, "Vector 2")

	_Vector_AddVector($aVector1, $aVector2)
	ConsoleWrite(@LF & "<<AddVector>>" & @LF & @LF)
    PrintVector($aVector1, "Vector 1")
    PrintVector($aVector2, "Vector 2")

	ConsoleWrite(@LF & "<<Find>>" & @LF & @LF)

	Local $bRet = _Vector_Find($aVector1, "Test 5")
	ConsoleWrite("Found 'Test 5' = " & $bRet & " at index: " & @extended & @LF)

	$bRet = _Vector_FindBackwards($aVector1, "Henlo 1")
	ConsoleWrite("Found Backwards 'Henlo 1' = " & $bRet & " at index: " & @extended & @LF)

	$bRet = _Vector_Find($aVector1, "Henlo 21")
	ConsoleWrite("Found 'Henlo 21' = " & $bRet & " at index: " & @extended & @LF)

	ConsoleWrite(@LF & "<<End>>" & @LF & @LF)
EndFunc



Func PrintVector(Const ByRef $aVector, Const $nTitle = "Vector")
    If Not _Vector_IsVector($aVector) Then
		Return
	EndIf

	ConsoleWrite("[" & $nTitle & "]" & @LF)

	For $i = 0 To _Vector_GetSize($aVector) - 1
		ConsoleWrite(StringFormat("%5d = %s", $i, _Vector_Get($aVector, $i)) & @LF)
	Next

EndFunc