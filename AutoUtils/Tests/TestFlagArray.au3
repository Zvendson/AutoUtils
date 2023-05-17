#include ".\..\FlagArray.au3"

;@Todo Need reword with UnitTest.au3

Test()



Func Test()
    Local $aFlags = _FlagArray_Init(256)

    For $nGroup = 0 To _FlagArray_GetGroupSize($aFlags) - 1
        _FlagArray_SetGroup($aFlags, $nGroup, 0xFFFFFFFF)
    Next

    Local $nShift = 1
    For $i = 0 To _FlagArray_GetSize($aFlags) - 1
        If Mod($i + 1, 3) = $nShift Then
            _FlagArray_SetFlag($aFlags, $i, 0)
        ElseIf Mod($i + 1, 3) = 0 Then
            $nShift += 1
            If $nShift >= 3 Then $nShift = 1
        EndIf
    Next

    _FlagArray_Debug($aFlags)
EndFunc


