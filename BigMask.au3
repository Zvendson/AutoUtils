#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author(s):       Zvend
 Discord(s):      zvend

 Script Functions:
    _BigMask_Init(Const $nCapacity = 32, Const $bDefaultSet = False)                              -> BigMask
    _BigMask_IsBigMask(Const ByRef $aBigMask)                                                     -> Bool
    _BigMask_IsValidIndex(Const ByRef $aBigMask, Const $nIndex, Const $bSkipBigMaskCheck = False) -> Bool
    _BigMask_IsValidGroup(Const ByRef $aBigMask, Const $nGroup, Const $bSkipBigMaskCheck = False) -> Bool
    _BigMask_GetFlag(Const ByRef $aBigMask, Const $nIndex)                                        -> Bool
    _BigMask_SetFlag(ByRef $aBigMask, Const $nIndex, Const $bBool)                                -> Bool
    _BigMask_SetGroup(ByRef $aBigMask, Const $nGroup, Const $nBitMask)                            -> Bool
    _BigMask_GetGroup(Const ByRef $aBigMask, Const $nGroup)                                       -> UInt32
    _BigMask_GetSize(Const ByRef $aBigMask)                                                       -> UInt32
    _BigMask_GetGroupSize(Const ByRef $aBigMask)                                                  -> UInt32
    _BigMask_ToBinary(Const ByRef $aBigMask)                                                      -> Binary
    _BigMask_ToString(Const ByRef $aBigMask, Const $bIncludeGroups = False)                       -> String

 Internal Functions:
    __BigMask_GetGroupFlag(Const $nFlagMask, Const $nIndex) -> Bool
    __BigMask_GetBitMask(Const $nIndex)                     -> UInt32
    __BigMask_ConvertToGroup(Const $nIndex)                 -> UInt32

 Description:
    The BigMask is a very storage efficient BitMask, that contain unlimited bits for
    setting & getting flags.

    The main reason i made this class is for storing bitmasks into packets or
    getting bitmasks from received packets. No matter if its socket or inter
    process communication.

    Can also be used for any other flagging system.

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



Global Enum _
    $BIGMASK_ERR_NONE         , _
    $BIGMASK_ERR_BAD_SIZE     , _
    $BIGMASK_ERR_BAD_BIGMASK  , _
    $BIGMASK_ERR_BAD_FLAG     , _
    $BIGMASK_ERR_INVALID_INDEX, _
    $BIGMASK_ERR_INVALID_GROUP, _
    $__BIGMASK_ERR_COUNT



Global Enum _
    $__BIGMASK_IDENTIFIER, _
    $__BIGMASK_CAPACITY, _
    $__BIGMASK_BUFFER  , _
    $__BIGMASK_PARAMS



Func _BigMask_Init(Const $nCapacity = 32, Const $bDefaultSet = False) ;-> BigMask
    If Not IsInt($nCapacity) Or $nCapacity <= 0 Then
        Return SetError($BIGMASK_ERR_BAD_SIZE, 0, Null)
    EndIf

    ;~ Calculate the size of the array
    Local $nGroups = __BigMask_ConvertToGroup($nCapacity - 1) + 1
    Local $aContainer[$nGroups]

    For $i = 0 To $nGroups - 1
        $aContainer[$i] = Int(0 - Int($bDefaultSet = True, 1), 1)
    Next

    Local $aBigMask[$__BIGMASK_PARAMS]
    $aBigMask[$__BIGMASK_IDENTIFIER] = "BigMask"
    $aBigMask[$__BIGMASK_CAPACITY] = $nCapacity
    $aBigMask[$__BIGMASK_BUFFER]   = $aContainer

    Return $aBigMask
EndFunc



Func _BigMask_IsBigMask(Const ByRef $aBigMask) ;-> Bool
    If Not IsArray($aBigMask) Then
        Return SetError($BIGMASK_ERR_BAD_BIGMASK, 0, 0)
    EndIf

    If UBound($aBigMask) <> $__BIGMASK_PARAMS Then
        Return SetError($BIGMASK_ERR_BAD_BIGMASK, 0, 0)
    EndIf

    If Not ($aBigMask[$__BIGMASK_IDENTIFIER] == "BigMask") Then
        Return SetError($BIGMASK_ERR_BAD_BIGMASK, 0, 0)
    EndIf

    Return 1
EndFunc



Func _BigMask_IsValidIndex(Const ByRef $aBigMask, Const $nIndex, Const $bSkipBigMaskCheck = False) ;-> Bool
    If Not $bSkipBigMaskCheck And Not _BigMask_IsBigMask($aBigMask) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not IsInt($nIndex) Or $nIndex < 0 Or $nIndex >= $aBigMask[$__BIGMASK_CAPACITY] Then
        Return SetError($BIGMASK_ERR_INVALID_INDEX, 0, 0)
    EndIf

    Return 1
EndFunc



Func _BigMask_IsValidGroup(Const ByRef $aBigMask, Const $nGroup, Const $bSkipBigMaskCheck = False) ;-> Bool
    If Not $bSkipBigMaskCheck And Not _BigMask_IsBigMask($aBigMask) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aContainer = $aBigMask[$__BIGMASK_BUFFER]

    If Not IsInt($nGroup) Or $nGroup < 0 Or $nGroup >= UBound($aContainer) Then
        Return SetError($BIGMASK_ERR_INVALID_GROUP, 0, 0)
    EndIf

    Return 1
EndFunc



Func _BigMask_GetFlag(Const ByRef $aBigMask, Const $nIndex) ;-> Bool
    If Not _BigMask_IsValidIndex($aBigMask, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $nGroup     = __BigMask_ConvertToGroup($nIndex)
    Local $aContainer = $aBigMask[$__BIGMASK_BUFFER]

    Return Int(__BigMask_GetGroupFlag($aContainer[$nGroup], $nIndex), 1)
EndFunc



Func _BigMask_SetFlag(ByRef $aBigMask, Const $nIndex, Const $bBool) ;-> Bool
    If Not _BigMask_IsValidIndex($aBigMask, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not (IsBool($bBool) Or IsInt($bBool)) Then
        Return SetError($BIGMASK_ERR_BAD_FLAG, 0, 0)
    EndIf

    Local $nGroup     = __BigMask_ConvertToGroup($nIndex)
    Local $nBitMask   = __BigMask_GetBitMask($nIndex)
    Local $aContainer = $aBigMask[$__BIGMASK_BUFFER]

    If $bBool Then
        $aContainer[$nGroup] = BitOR($aContainer[$nGroup], $nBitMask)
    Else
        $aContainer[$nGroup] = BitAND($aContainer[$nGroup], BitNOT($nBitMask))
    EndIf

    $aBigMask[$__BIGMASK_BUFFER] = $aContainer

    Return 1
EndFunc



Func _BigMask_SetGroup(ByRef $aBigMask, Const $nGroup, Const $nBitMask) ;-> Bool
    If Not _BigMask_IsValidGroup($aBigMask, $nGroup, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not IsInt($nBitMask) And Not IsPtr($nBitMask) Then
        Return SetError($BIGMASK_ERR_BAD_FLAG, 0, 0)
    EndIf

    Local $aContainer = $aBigMask[$__BIGMASK_BUFFER]

    $aContainer[$nGroup] = Int($nBitMask, 1)

    $aBigMask[$__BIGMASK_BUFFER] = $aContainer

    Return 1
EndFunc



Func _BigMask_GetGroup(Const ByRef $aBigMask, Const $nGroup) ;-> UInt32
    If Not _BigMask_IsValidGroup($aBigMask, $nGroup, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aContainer = $aBigMask[$__BIGMASK_BUFFER]

    Return $aContainer[$nGroup]
EndFunc



Func _BigMask_GetSize(Const ByRef $aBigMask) ;-> UInt32
    If Not _BigMask_IsBigMask($aBigMask) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $aBigMask[$__BIGMASK_CAPACITY]
EndFunc



Func _BigMask_GetGroupSize(Const ByRef $aBigMask) ;-> UInt32
    If Not _BigMask_IsBigMask($aBigMask) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return UBound($aBigMask[$__BIGMASK_BUFFER])
EndFunc



Func _BigMask_ToBinary(Const ByRef $aBigMask) ;-> Binary
    If Not _BigMask_IsBigMask($aBigMask) Then
        Return SetError(@error, 0, Binary("0x00"))
    EndIf

    Local $tStruct = DllStructCreate("DWORD[" & _BigMask_GetGroupSize($aBigMask) & "];")

    For $i = 0 To _BigMask_GetGroupSize($aBigMask) - 1
        DllStructSetData($tStruct, 1, _BigMask_GetGroup($aBigMask, $i), $i + 1)
    Next

    Local $nSize  = Ceiling(_BigMask_GetSize($aBigMask) / 8)

    Local $tBytes = DllStructCreate("BYTE[" & $nSize & "];", DllStructGetPtr($tStruct))
    Return DllStructGetData($tBytes, 1)
EndFunc



Func _BigMask_ToString(Const ByRef $aBigMask, Const $bIncludeGroups = False) ;-> String
    If Not _BigMask_IsBigMask($aBigMask) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $sOut = ""
    If $bIncludeGroups Then
        $sOut  = "[BigMask] [Size: " & _BigMask_GetSize($aBigMask) & ", Groups: " & _BigMask_GetGroupSize($aBigMask) & "]" & @LF
        $sOut &= StringFormat("Group  %d: 0x%08X = {", 0, _BigMask_GetGroup($aBigMask, 0))
    EndIf

    For $i = 0 To $aBigMask[$__BIGMASK_CAPACITY] - 1
        $sOut &= StringFormat("%1d ", _BigMask_GetFlag($aBigMask, $i))

        If $i = $aBigMask[$__BIGMASK_CAPACITY] - 1 Then
            ExitLoop
        ElseIf $bIncludeGroups And Mod($i + 1, 32) = 0 Then
            Local $nGroupIndex = __BigMask_ConvertToGroup($i + 1)
            $sOut  = StringTrimRight($sOut, 1) & "}" & @LF
            $sOut &= StringFormat("Group  %d: 0x%08X = {", $nGroupIndex, _BigMask_GetGroup($aBigMask, $nGroupIndex))
        ElseIf $bIncludeGroups And Mod($i + 1, 8) = 0 Then
            $sOut &= "  "
        EndIf
    Next

    If $bIncludeGroups Then
        $sOut = StringStripWS($sOut, 2) & "}" & @LF
    EndIf

    Return $sOut
EndFunc



Func __BigMask_GetGroupFlag(Const $nFlagMask, Const $nIndex) ;-> Bool
    Return BitAnd($nFlagMask, BitShift(1, - Mod($nIndex, 32))) <> 0
EndFunc



Func __BigMask_GetBitMask(Const $nIndex) ;-> UInt32
    Return BitShift(1, - Mod($nIndex, 32))
EndFunc



Func __BigMask_ConvertToGroup(Const $nIndex) ;-> UInt32
    Return Floor($nIndex / 32)
EndFunc



