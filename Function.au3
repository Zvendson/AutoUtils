#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Zvend

 Script Function:
    _Function_Exists(Const $sFunctionName) -> Boolean
    _Function_Validate($fuFunction)        -> String<FuncName>

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



;~ Checks if a function exists.
Func _Function_Exists(Const $sFunctionName) ;-> Boolean
    ;~ This looks "wrong" but Execute("<Name>") will return a variable of type function
    ;~ if the function exists. if the argument for Execute is not a string, it will fail.
    Local $fuValidateFunc = Execute($sFunctionName)
    Return IsFunc($fuValidateFunc)
EndFunc



;~ Checks if a function exists and returns its string representation.
;~ Returns "" if the function does not exist and sets the error flag to non zero.
Func _Function_Validate($fuFunction) ;-> String<FuncName>
    If IsFunc($fuFunction) Then
        $fuFunction = FuncName($fuFunction)
    ElseIf IsString($fuFunction) Then
        ;~ To be consistent, cause FuncName returns the name in upper case.
        $fuFunction = StringUpper($fuFunction)
    Else
        Return SetError(1, 0, "")
    EndIf

    If Not _Function_Exists($fuFunction) Then
        Return SetError(2, 0, "")
    EndIf

    Return $fuFunction
EndFunc



