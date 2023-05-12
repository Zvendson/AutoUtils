#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author(s):       Zvend
 Discord(s):      Zvend#6666

 Script Functions:
    _FlagArray_Init(Const $nCapacity = 32)                                                      -> FlagArray
    _FlagArray_IsFlagArray(Const ByRef $aFlagArray)                                             -> Bool
    _FlagArray_IsValidIndex(Const ByRef $aFlagArray, Const $nIndex, Const $bSkipFlagArrayCheck) -> Bool
    _FlagArray_IsValidGroup(Const ByRef $aFlagArray, Const $nGroup, Const $bSkipFlagArrayCheck) -> Bool
    _FlagArray_GetFlag(Const ByRef $aFlagArray, Const $nIndex)                                  -> Bool
    _FlagArray_SetFlag(ByRef $aFlagArray, Const $nIndex, Const $bBool)                          -> Bool
    _FlagArray_SetGroup(ByRef $aFlagArray, Const $nGroup, Const $nBitMask)                      -> Bool
    _FlagArray_GetGroup(Const ByRef $aFlagArray, Const $nGroup)                                 -> DWORD
    _FlagArray_GetSize(Const ByRef $aFlagArray)                                                 -> Int32
    _FlagArray_GetGroupSize(Const ByRef $aFlagArray)                                            -> Int32
    _FlagArray_Debug(Const ByRef $aFlagArray, Const $fuStream = "ConsoleWrite")                 -> Bool

 Internal Functions:
    __FlagArray_GetGroupFlag(Const $nFlagMask, Const $nIndex)
    __FlagArray_GetBitMask(Const $nIndex)
    __FlagArray_ConvertToGroup(Const $nIndex)

 Description:
    The Flag Array is a very storage efficient BitMask for setting & getting flags.
    It can store 32 bool values in one array index and this 'class' let you set
    a very large amount of booleans in an array which is super tiny and fast.

    The main reason i made this class is for storing bitmasks into packets or
    getting bitmasks from received packets. No matter if its socket or inter
    process communication.

    Can also be used for any other flagging system.

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



Global Enum _
    $__FLAGARRAY_CAPACITY, _
    $__FLAGARRAY_BUFFER  , _
    $__FLAGARRAY_PARAMS



Func _FlagArray_Init(Const $nCapacity = 32)
    If $nCapacity <= 0 Then
        Return SetError(1, 0, 0)
    EndIf

    ;~ Calculate the size of the array
    Local $nGroups = __FlagArray_ConvertToGroup($nCapacity - 1) + 1
    Local $aContainer[$nGroups]

    For $i = 0 To $nGroups - 1
        $aContainer[$i] = Int(0x00000000, 1)
    Next

    Local $aFlagArray[$__FLAGARRAY_PARAMS] 
    $aFlagArray[$__FLAGARRAY_CAPACITY] = $nCapacity
    $aFlagArray[$__FLAGARRAY_BUFFER]   = $aContainer

    Return $aFlagArray
EndFunc



Func _FlagArray_IsFlagArray(Const ByRef $aFlagArray)
    If Not IsArray($aFlagArray) Then
        Return SetError(1, 0, 0)
    EndIf

    If UBound($aFlagArray) <> $__FLAGARRAY_PARAMS Then
        Return SetError(2, 0, 0)
    EndIf

    Return 1    
EndFunc



Func _FlagArray_IsValidIndex(Const ByRef $aFlagArray, Const $nIndex, Const $bSkipFlagArrayCheck)
    If Not $bSkipFlagArrayCheck And Not _FlagArray_IsFlagArray($aFlagArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    If $nIndex < 0 Or $nIndex >= $aFlagArray[$__FLAGARRAY_CAPACITY] Then
        Return SetError(3, 0, 0)
    EndIf

    Return 1
EndFunc



Func _FlagArray_IsValidGroup(Const ByRef $aFlagArray, Const $nGroup, Const $bSkipFlagArrayCheck)
    If Not $bSkipFlagArrayCheck And Not _FlagArray_IsFlagArray($aFlagArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aContainer = $aFlagArray[$__FLAGARRAY_BUFFER]

    If $nGroup < 0 Or $nGroup >= UBound($aContainer) Then
        Return SetError(3, 0, 0)
    EndIf

    Return 1
EndFunc



Func _FlagArray_GetFlag(Const ByRef $aFlagArray, Const $nIndex)
    If Not _FlagArray_IsValidIndex($aFlagArray, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $nGroup     = __FlagArray_ConvertToGroup($nIndex)
    Local $aContainer = $aFlagArray[$__FLAGARRAY_BUFFER]

    Return __FlagArray_GetGroupFlag($aContainer[$nGroup], $nIndex)
EndFunc



Func _FlagArray_SetFlag(ByRef $aFlagArray, Const $nIndex, Const $bBool)
    If Not _FlagArray_IsValidIndex($aFlagArray, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $nGroup     = __FlagArray_ConvertToGroup($nIndex)
    Local $nBitMask   = __FlagArray_GetBitMask($nIndex)
    Local $aContainer = $aFlagArray[$__FLAGARRAY_BUFFER]

    If $bBool Then
        $aContainer[$nGroup] = BitOR($aContainer[$nGroup], $nBitMask)
    Else
        $aContainer[$nGroup] = BitAND($aContainer[$nGroup], BitNOT($nBitMask))
    EndIf    

    $aFlagArray[$__FLAGARRAY_BUFFER] = $aContainer

    Return 1
EndFunc



Func _FlagArray_SetGroup(ByRef $aFlagArray, Const $nGroup, Const $nBitMask)
    If Not _FlagArray_IsValidGroup($aFlagArray, $nGroup, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not IsInt($nBitMask) And Not IsPtr($nBitMask) Then
        Return SetError(4, 0, 0)
    EndIf

    Local $aContainer = $aFlagArray[$__FLAGARRAY_BUFFER]

    $aContainer[$nGroup] = Int($nBitMask, 1)

    $aFlagArray[$__FLAGARRAY_BUFFER] = $aContainer

    Return 1
EndFunc



Func _FlagArray_GetGroup(Const ByRef $aFlagArray, Const $nGroup)
    If Not _FlagArray_IsValidGroup($aFlagArray, $nGroup, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aContainer = $aFlagArray[$__FLAGARRAY_BUFFER]

    Return $aContainer[$nGroup]
EndFunc



Func _FlagArray_GetSize(Const ByRef $aFlagArray)
    If Not _FlagArray_IsFlagArray($aFlagArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $aFlagArray[$__FLAGARRAY_CAPACITY]
EndFunc



Func _FlagArray_GetGroupSize(Const ByRef $aFlagArray)
    If Not _FlagArray_IsFlagArray($aFlagArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return UBound($aFlagArray[$__FLAGARRAY_BUFFER])
EndFunc



Func _FlagArray_Debug(Const ByRef $aFlagArray, Const $fuStream = "ConsoleWrite")
    If Not _FlagArray_IsFlagArray($aFlagArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $sOut = "[FlagArray] [Size: " & _FlagArray_GetSize($aFlagArray) & ", Groups: " & _FlagArray_GetGroupSize($aFlagArray) & "]" & @LF
    $sOut &= "Group  0: {"

    For $i = 0 To $aFlagArray[$__FLAGARRAY_CAPACITY] - 1
        $sOut &= StringFormat("%1d ", _FlagArray_GetFlag($aFlagArray, $i))

        If $i = $aFlagArray[$__FLAGARRAY_CAPACITY] - 1 Then
            ExitLoop
        ElseIf Mod($i + 1, 32) = 0 Then
            $sOut = StringTrimRight($sOut, 1) & "}" & @LF & "Group  " & __FlagArray_ConvertToGroup($i + 1) & ": {"
        ElseIf Mod($i + 1, 8) = 0 Then
            $sOut &= "  "
        EndIf
    Next

    $sOut = StringStripWS($sOut, 2) & "}" & @LF

    Call($fuStream, $sOut)

    Return 1
EndFunc



Func __FlagArray_GetGroupFlag(Const $nFlagMask, Const $nIndex)
    Return BitAnd($nFlagMask, BitShift(1, - Mod($nIndex, 32))) <> 0
EndFunc



Func __FlagArray_GetBitMask(Const $nIndex)
    Return BitShift(1, - Mod($nIndex, 32))
EndFunc



Func __FlagArray_ConvertToGroup(Const $nIndex)
    Return Floor($nIndex / 32)
EndFunc


