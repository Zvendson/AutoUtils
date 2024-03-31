#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author(s):       Zvend
 Discord(s):      zvend

 Script Function:
    _IndexArray_Init(Const $nSize = 32)                                                     -> IndexArray
    _IndexArray_IsIndexArray(Const ByRef $aArray)                                           -> Bool
    _IndexArray_IsIndexValid(Const ByRef $aArray, Const $nIndex, Const $bSkipCheck = False) -> Bool
    _IndexArray_GetSize(Const ByRef $aArray)                                                -> UInt32
    _IndexArray_Resize(ByRef $aArray, Const $nNewSize)                                      -> Boolean
    _IndexArray_Get(Const ByRef $aArray, Const $nIndex, Const $vDefaultValue = Null)        -> Variant
    _IndexArray_Set(ByRef $aArray, Const $nIndex, Const $vValue)                            -> Bool
    _IndexArray_Reset(ByRef $aArray, Const $nSize = 32)                                     -> Bool

 Description:
    IndexArrays are meant to be index controlled. So instead of adding the new value to the end of an array it will always
    require where to write the array and if necessary it will resize the array accordingly.
    This is very useful for arrays with fixed IDs that have to be set on an index that does not (yet) exist.

#ce ----------------------------------------------------------------------------

#cs - Guide --------------------------------------------------------------------

 How To Use:
    Initialize your global array like:

        Global $g_aMyArray = _IndexArray_Init(4)

    This will create an array of size 4 indexes (1-4) and index 0 is always the current size of the array.
    Empty fields will always return Null.
    Now Set your values like:

        _IndexArray_Set($g_aMyArray, 1, "I am a value")
        _IndexArray_Set($g_aMyArray, 2, "Look another value!")
        _IndexArray_Set($g_aMyArray, 4, "I am the end of this array!")
        _IndexArray_Set($g_aMyArray, 8, "No you are not!")

    If you sharpened your eyes you see that setting on index 8 should not be possible, since we gave the array a size of 4.
    But it will auto resize the array by calculating the size like 'Floor(size * 1.5)' until the index 8 fits in the array.
    So 4 * 1.5 = 6 and 6 * 1.5 = 9. The array will be resized to size 9.

    You should always get the values by _IndexArray_Get(). it will error check and prevent autoit from crashing if index is out of bounds.
    If you need to completely reset your array (Nulling all values) + resizing to a default value, you can use:
        _IndexArray_Reset($g_aMyArray, 4)

    All values will be Null again. You could also just call:
        $g_aMyArray = _IndexArray_Init(4)

    Since it would do the exact same like Reset BUT using _IndexArray_Reset() is by far more readable.

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#include ".\Integer.au3"
#include ".\UnitTest.au3"
#include <Array.au3>



Global Enum _
    $INDEXARRAY_ERR_NONE          , _
    $INDEXARRAY_ERR_BAD_SIZE      , _
    $INDEXARRAY_ERR_BAD_INDEXARRAY, _
    $INDEXARRAY_ERR_INVALID_INDEX



Global Enum _
    $__INDEXARRAY_IDENTIFIER, _
    $__INDEXARRAY_SIZE, _
    $__INDEXARRAY_PARAMS



Func _IndexArray_Init(Const $nSize = 32) ;-> IndexArray
    If Not IsInt($nSize) Or $nSize <= 0 Then
        Return SetError($INDEXARRAY_ERR_BAD_SIZE, 0, Null)
    EndIf

    Local $aArray[$nSize + $__INDEXARRAY_PARAMS]
    $aArray[$__INDEXARRAY_IDENTIFIER] = "IndexArray"
    $aArray[$__INDEXARRAY_SIZE]       = $nSize

    For $i = $__INDEXARRAY_PARAMS To $nSize + $__INDEXARRAY_PARAMS - 1
        $aArray[$i] = Null
    Next

    Return $aArray
EndFunc



Func _IndexArray_IsIndexArray(Const ByRef $aArray) ;-> Bool
    If Not IsArray($aArray) Then
        Return SetError($INDEXARRAY_ERR_BAD_INDEXARRAY, 0, 0)
    EndIf

    If UBound($aArray) < $__INDEXARRAY_PARAMS Then
        Return SetError($INDEXARRAY_ERR_BAD_INDEXARRAY, 0, 0)
    EndIf

    If Not ($aArray[$__INDEXARRAY_IDENTIFIER] == "IndexArray") Then
        Return SetError($INDEXARRAY_ERR_BAD_INDEXARRAY, 0, 0)
    EndIf

    Return 1
EndFunc



Func _IndexArray_IsIndexValid(Const ByRef $aArray, Const $nIndex, Const $bSkipCheck = False) ;-> Bool
    If Not $bSkipCheck And Not _IndexArray_IsIndexArray($aArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not _Integer_IsInRange($nIndex, 0, $aArray[$__INDEXARRAY_SIZE] - 1) Then
        Return SetError($INDEXARRAY_ERR_INVALID_INDEX, 0, 0)
    EndIf

    Return 1
EndFunc



Func _IndexArray_GetSize(Const ByRef $aArray) ;-> UInt32
    If Not _IndexArray_IsIndexArray($aArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $aArray[$__INDEXARRAY_SIZE]
EndFunc



Func _IndexArray_Resize(ByRef $aArray, Const $nNewSize) ;-> Boolean
    If Not _IndexArray_IsIndexArray($aArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not IsInt($nNewSize) Or $nNewSize <= 0 Then
        Return SetError($INDEXARRAY_ERR_BAD_SIZE, 0, 0)
    EndIf

    If $nNewSize = $aArray[$__INDEXARRAY_SIZE] Then
        Return 1
    EndIf

    If $nNewSize < $aArray[$__INDEXARRAY_SIZE] Then
        Redim $aArray[$nNewSize + $__INDEXARRAY_PARAMS]
        $aArray[$__INDEXARRAY_SIZE] = $nNewSize
        Return 1
    EndIf

    Local $nCalcSize = $aArray[$__INDEXARRAY_SIZE]
    Local $nOldSize  = $aArray[$__INDEXARRAY_SIZE]

    While $nCalcSize <= $nNewSize
        $nCalcSize = Floor($nCalcSize * 1.5)
    WEnd

    ReDim $aArray[$nCalcSize + $__INDEXARRAY_PARAMS]
    $aArray[$__INDEXARRAY_SIZE] = $nCalcSize

    For $i = $__INDEXARRAY_PARAMS + $nOldSize To $nCalcSize + $__INDEXARRAY_PARAMS - 1
        $aArray[$i] = Null
    Next

    Return 1
EndFunc



Func _IndexArray_Get(Const ByRef $aArray, Const $nIndex, Const $vDefaultValue = Null) ;-> Variant
    If Not _IndexArray_IsIndexValid($aArray, $nIndex, False) Then
        Return SetError(@error, 0, $vDefaultValue)
    EndIf

    Return $aArray[$nIndex + $__INDEXARRAY_PARAMS]
EndFunc



Func _IndexArray_Set(ByRef $aArray, Const $nIndex, Const $vValue) ;-> Bool
    If Not _IndexArray_IsIndexArray($aArray) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not IsInt($nIndex) Or $nIndex < 0 Then
        Return SetError($INDEXARRAY_ERR_INVALID_INDEX, 0, 0)
    EndIf

    If $nIndex >= $aArray[$__INDEXARRAY_SIZE] Then
        _IndexArray_Resize($aArray, $nIndex)
    EndIf

    $aArray[$nIndex + $__INDEXARRAY_PARAMS] = $vValue

    Return 1
EndFunc



Func _IndexArray_Reset(ByRef $aArray, Const $nSize = 32) ;-> Bool
    If Not _IndexArray_IsIndexArray($aArray) Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aTemp = _IndexArray_Init($nSize)
    If $aTemp = Null Or @error Then
        Return SetError(@error, 0, 0)
    EndIf

    $aArray = $aTemp

    Return 1
EndFunc



