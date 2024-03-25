#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Zvend

 Script Function:
    _String_Repeat($sString, $nRepeatCount) -> String

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



;~ Repeats a string a specified number of times
Func _String_Repeat($sString, $nRepeatCount) ;-> String
    $nRepeatCount = Int($nRepeatCount)

    If $nRepeatCount = 0 Then
        Return ""
    EndIf

    If StringLen($sString) < 1 Or $nRepeatCount < 0 Then
        Return SetError(1, 0, "")
    EndIf

    Local $sResult = ""

    If $nRepeatCount < 100 Then
        For $i = 1 To $nRepeatCount
            $sResult &= $sString
        Next

        Return $sResult
    EndIf

    While $nRepeatCount > 1
        If BitAND($nRepeatCount, 1) Then
            $sResult &= $sString
        EndIf

        $sString &= $sString
        $nRepeatCount = BitShift($nRepeatCount, 1)
    WEnd

    Return $sString & $sResult
EndFunc



