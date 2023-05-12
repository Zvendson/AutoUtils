#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author(s):       Zvend       Nadav
 Discord(s):      Zvend#6666  Abaddon#9048

 Script Functions:
    Func _Vector_Init($nCapacity = 32, Const $vDefaultValue = Null, $nModifier = 1.5, Const $fuCompare = Null) -> Vector
    _Vector_IsVector(Const ByRef $aVector)                                                                     -> Bool
    _Vector_IsValidIndex(Const ByRef $aVector, Const $nIndex)                                                  -> Bool
    _Vector_GetSize(Const ByRef $aVector)                                                                      -> UInt
    _Vector_GetCapacity(Const ByRef $aVector)                                                                  -> UInt
    _Vector_GetDefaultValue(Const ByRef $aVector)                                                              -> DefaultValue / Null
    _Vector_GetModifier(Const ByRef $aVector)                                                                  -> Float
    _Vector_IsEmpty(Const ByRef $aVector)                                                                      -> Bool
    _Vector_Get(Const ByRef $aVector, Const $nIndex)                                                           -> Variant / Null
    _Vector_GetBuffer(Const ByRef $aVector)                                                                    -> Array
    _Vector_Reserve(ByRef $aVector, Const $nCapacity)                                                          -> Bool
    _Vector_Insert(ByRef $aVector, Const $nIndex, Const $vValue)                                               -> Bool
    _Vector_Push(ByRef $aVector, Const $vValue)                                                                -> Bool
    _Vector_Pop(ByRef $aVector)                                                                                -> Variant / DefaultValue / Null
    _Vector_PopFirst(ByRef $aVector)                                                                           -> Variant / DefaultValue / Null
    _Vector_Set(ByRef $aVector, Const $nIndex, Const $vValue)                                                  -> Bool
    _Vector_AddVector(ByRef $aVector, Const ByRef $aFromVector)                                                -> Bool
    _Vector_Erase(ByRef $aVector, Const $nIndex)                                                               -> Bool
    _Vector_EraseValue(ByRef $aVector, Const $vValue)                                                          -> Bool
    _Vector_Swap(ByRef $aVector, Const $nIndex1, Const $nIndex2)                                               -> Bool
    _Vector_SwapVectors(ByRef $aVectorL, ByRef $aVectorR)                                                      -> Bool
    _Vector_Clear(ByRef $aVector)                                                                              -> Bool
    _Vector_Find(Const ByRef $aVector, Const $vValue)                                                          -> Bool @extended = index
    _Vector_FindBackwards(Const ByRef $aVector, Const $vValue)                                                 -> Bool @extended = index
    _Vector_Sort(Const ByRef $aVector, Const $vValue)                                                          -> Bool

 Internal Functions:
    __Vector_CalculateCapacity($nCapacity, Const $nRequiredSize, $nModifier)                                   -> UInt
    __Vector_IsValidIndex(Const ByRef $aVector, Const $nIndex, Const $bSkipVectorCheck)                        -> Bool
    __Vector_HasSpace(Const ByRef $aVector, Const $nSize, Const $bSkipVectorCheck)                             -> Bool
    __Vector_QuickSort(ByRef $aVector, ByRef $aContainer, Const $nLowIndex, Const $nHighIndex)                 -> (None)
    __Vector_QuickSortPartition(ByRef $aVector, ByRef $aContainer, Const $nLowIndex, Const $nHighIndex)        -> UInt
    __Vector_SwapContainer(ByRef $aContainer, Const $nIndex1, Const $nIndex2)                                  -> (None)
    __Vector_Compare(Const ByRef $fuCompare, Const $vValue1, Const $vValue2)                                   -> UInt

 Description:
    This Vector "Class" implementation acts exactly like the stdlib vector from C++ just without typesafe values.
    Of course this will have massive struggle to actually go head to head with the c++ version and was never
    meant to.
    So this vector is kind of "intelligent" in using the ReDim keyword wisely. You init the vector with a
    capacity and as soon the size of the vector will be bigger than its capacity, the vector will auto
    increase the capacity by 1.5 of it current capcity.

#ce ----------------------------------------------------------------------------



#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



Global Enum _
    $__VECTOR_SIZE     , _
    $__VECTOR_CAPACITY , _
    $__VECTOR_DEFAULT  , _
    $__VECTOR_MODIFIER , _
    $__VECTOR_BUFFER   , _
    $__VECTOR_COMPARE  , _
    $__VECTOR_PARAMS

Global Enum _
    $VECTOR_NO_ERROR                       , _
    $VECTOR_ERROR_INVALID_VECTOR           , _
    $VECTOR_ERROR_BAD_MODIFIER             , _
    $VECTOR_ERROR_INVALID_PARAMS           , _
    $VECTOR_ERROR_INVALID_COMPARE_FUNCTION , _
    $VECTOR_ERROR_INDEX_OUT_OF_BOUNDS      , _
    $VECTOR_ERROR_EMTPY_VECTOR             , _
    $VECTOR_ERROR_INVALID_COMPARISION



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Init
; Description ...: Creates a new Vector.
; Syntax ........: _Vector_Init([$nCapacity = 32[, $vDefaultValue = Null[, $nModifier = 1.5[, $fuCompare = Null]]]])
; Parameters ....: $nCapacity           - [optional and const] a general number value. Default is 32.
;                  $vDefaultValue       - [optional and const] a variant value. Default is Null.
;                  $nModifier           - [optional and const] a general number value. Default is 1.5.
; Return values .: The new Vector.
; Author ........: Zvend
; Modified ......: Nadav
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Init(Const $nCapacity = 32, Const $vDefaultValue = Null, Const $nModifier = 1.5)
    If $nModifier < 1.5 Then
        Return SetError($VECTOR_ERROR_BAD_MODIFIER, 0, Null)
    EndIf

    Local $aContainer[$nCapacity]
    Local $aNewVector[$__VECTOR_PARAMS]
    $aNewVector[$__VECTOR_SIZE]     = 0
    $aNewVector[$__VECTOR_CAPACITY] = $nCapacity
    $aNewVector[$__VECTOR_DEFAULT]  = $vDefaultValue
    $aNewVector[$__VECTOR_MODIFIER] = $nModifier
    $aNewVector[$__VECTOR_BUFFER]   = $aContainer
    $aNewVector[$__VECTOR_COMPARE]  = Null

    Return $aNewVector
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_SetComparatorCallback
; Description ...: Sets the compare callback of the Vector.
; Syntax ........: _Vector_SetComparatorCallback(Byref $aVector, Const $fuCompare)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $fuCompare           - [const] a function (first class object). Default is Null.
;                                         Gets 2 comparable values and returns a negative number if the first was smaller,
;                                         0 if the values are equal, and a positive number if the first was larger.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Nadav
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_SetComparatorCallback(ByRef $aVector, Const $fuCompare)
    If Not IsFunc($fuCompare) Then
        Return SetError($VECTOR_ERROR_INVALID_COMPARE_FUNCTION, 0, 0)
    EndIf

    $aVector[$__VECTOR_COMPARE] = $fuCompare

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_IsVector
; Description ...: Checks whether the argument is a valid Vector.
; Syntax ........: _Vector_IsVector(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: 1 if the parameter is a Vector, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_IsVector(Const ByRef $aVector)
    If Not IsArray($aVector) Then
        Return SetError($VECTOR_ERROR_INVALID_VECTOR, 0, 0)
    EndIf

    If UBound($aVector) <> $__VECTOR_PARAMS Then
        Return SetError($VECTOR_ERROR_INVALID_PARAMS, 0, 0)
    EndIf

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_IsValidIndex
; Description ...: Checks whether the index is a valid for the Vector.
; Syntax ........: _Vector_IsValidIndex(Const Byref $aVector, Const $nIndex)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
;                  $nIndex              - [const] a general number value.
; Return values .: 1 if the index is valid, 0 otherwise
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_IsValidIndex(Const ByRef $aVector, Const $nIndex)
    If Not __Vector_IsValidIndex($aVector, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_GetSize
; Description ...: Returns the number of elements in the Vector.
; Syntax ........: _Vector_GetSize(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: The number of elements.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_GetSize(Const ByRef $aVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $aVector[$__VECTOR_SIZE]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_GetCapacity
; Description ...: Returns the maximum possible number of elements.
; Syntax ........: _Vector_GetCapacity(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: The maximum possible number of elements.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_GetCapacity(Const ByRef $aVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $aVector[$__VECTOR_CAPACITY]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_GetDefaultValue
; Description ...: Returns the default value of the vector.
; Syntax ........: _Vector_GetDefaultValue(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: The default value of the vector.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_GetDefaultValue(Const ByRef $aVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, Null)
    EndIf

    Return $aVector[$__VECTOR_DEFAULT]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_GetModifier
; Description ...: Returns the Vector's Modifier.
; Syntax ........: _Vector_GetModifier(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: The Vector's Modifier.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_GetModifier(Const ByRef $aVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0.0)
    EndIf

    Return $aVector[$__VECTOR_MODIFIER]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_IsEmpty
; Description ...: Checks whether the Vector is empty.
; Syntax ........: _Vector_IsEmpty(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: True if the Vector is empty, False otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_IsEmpty(Const ByRef $aVector)
    Local $nSize = _Vector_GetSize($aVector)
    Return SetError(@error, @extended, $nSize = 0)
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Get
; Description ...: Return specified element with bounds checking.
; Syntax ........: _Vector_Get(Const Byref $aVector, Const $nIndex)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
;                  $nIndex              - [const] a general number value.
; Return values .: The value of the element, Null if the index doesn't exists
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Get(Const ByRef $aVector, Const $nIndex)
    If Not __Vector_IsValidIndex($aVector, $nIndex, False) Then
        Return SetError(@error, 0, Null)
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]

	If IsString($aContainer[$nIndex]) And $aContainer[$nIndex] == "" And Not ($aVector[$__VECTOR_DEFAULT] == "") Then
		Return $aVector[$__VECTOR_DEFAULT]
	EndIf

    Return $aContainer[$nIndex]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_GetBuffer
; Description ...: Return a copy of the values array of the Vector.
; Syntax ........: _Vector_GetBuffer(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: A copy of the values array of the Vector.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_GetBuffer(Const ByRef $aVector)
    Static Local $aEmptyContainer[0]

    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, $aEmptyContainer)
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
	If $aVector[$__VECTOR_SIZE] < $aVector[$__VECTOR_CAPACITY] Then
		ReDim $aContainer[$aVector[$__VECTOR_SIZE]]
	EndIf

    Return $aContainer
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Reserve
; Description ...: Requests that the vector's capacity be at least enough to contain $nCapacity elements.
; Syntax ........: _Vector_Reserve(Byref $aVector, Const $nCapacity)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $nCapacity           - [const] a general number value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Reserve(ByRef $aVector, Const $nCapacity)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    If $nCapacity <= $aVector[$__VECTOR_CAPACITY] Then
        Return 1
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
    Local $nNewCapacity = __Vector_CalculateCapacity($aVector[$__VECTOR_CAPACITY], $nCapacity, $aVector[$__VECTOR_MODIFIER])

    ReDim $aContainer[$nNewCapacity]

    $aVector[$__VECTOR_CAPACITY] = $nNewCapacity
    $aVector[$__VECTOR_BUFFER] = $aContainer

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Insert
; Description ...: Inserts elements at the specified location in the Vector.
; Syntax ........: _Vector_Insert(Byref $aVector, Const $nIndex, Const $vValue)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $nIndex              - [const] a general number value.
;                  $vValue              - [const] a variant value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Insert(ByRef $aVector, Const $nIndex, Const $vValue)
    If Not __Vector_IsValidIndex($aVector, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $nNextSize = $aVector[$__VECTOR_SIZE] + 1
    Local $aContainer = $aVector[$__VECTOR_BUFFER]

    If $nNextSize > $aVector[$__VECTOR_CAPACITY] Then
        Local $nNewSize = __Vector_CalculateCapacity($aVector[$__VECTOR_CAPACITY], $nNextSize, $aVector[$__VECTOR_MODIFIER])
        ReDim $aContainer[$nNewSize]
        $aVector[$__VECTOR_CAPACITY] = $nNewSize
    EndIf


    For $i = $aVector[$__VECTOR_SIZE] To $nIndex Step -1
        $aContainer[$i] = $aContainer[$i - 1]
    Next

    $aContainer[$nIndex] = $vValue
    $aVector[$__VECTOR_SIZE] += 1

    $aVector[$__VECTOR_BUFFER] = $aContainer

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Push
; Description ...: Appends the given element value to the end of the Vector.
; Syntax ........: _Vector_Push(Byref $aVector, Const $vValue)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $vValue              - [const] a variant value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Push(ByRef $aVector, Const $vValue)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $nNextSize  = $aVector[$__VECTOR_SIZE] + 1
    Local $aContainer = $aVector[$__VECTOR_BUFFER]

    If $nNextSize > $aVector[$__VECTOR_CAPACITY] Then
        Local $nNewCapacity = __Vector_CalculateCapacity($aVector[$__VECTOR_CAPACITY], $nNextSize, $aVector[$__VECTOR_MODIFIER])
        ReDim $aContainer[$nNewCapacity]
        $aVector[$__VECTOR_CAPACITY] = $nNewCapacity
    EndIf

    $aContainer[$aVector[$__VECTOR_SIZE]] = $vValue
    $aVector[$__VECTOR_SIZE] = $nNextSize
    $aVector[$__VECTOR_BUFFER] = $aContainer

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Pop
; Description ...: Removes the last element of the container and returns it.
; Syntax ........: _Vector_Pop(Byref $aVector)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
; Return values .: The value of the removed element.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Pop(ByRef $aVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, Null)
    EndIf

    If $aVector[$__VECTOR_SIZE] <= 0 Then
        Return SetError($VECTOR_ERROR_EMTPY_VECTOR, 0, $aVector[$__VECTOR_DEFAULT])
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
    $aVector[$__VECTOR_SIZE] -= 1

    Local $vValue = $aContainer[$aVector[$__VECTOR_SIZE]]
    $aContainer[$aVector[$__VECTOR_SIZE]] = Null

    Return $vValue
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_PopFirst
; Description ...: Removes the first element of the container and returns it.
; Syntax ........: _Vector_PopFirst(Byref $aVector)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
; Return values .: The value of the removed element.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_PopFirst(ByRef $aVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, Null)
    EndIf

    If $aVector[$__VECTOR_SIZE] <= 0 Then
        Return SetError($VECTOR_ERROR_EMTPY_VECTOR, 0, $aVector[$__VECTOR_DEFAULT])
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
    $aVector[$__VECTOR_SIZE] -= 1
    Local $vValue = $aContainer[0]

    For $i = 0 To $aVector[$__VECTOR_SIZE] - 1
        $aContainer[$i] = $aContainer[$i + 1]
    Next

    $aVector[$__VECTOR_BUFFER] = $aContainer

    Return $vValue
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Set
; Description ...: Changes the value of the element at the given index.
; Syntax ........: _Vector_Set(Byref $aVector, Const $nIndex, Const $vValue)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $nIndex              - [const] a general number value.
;                  $vValue              - [const] a variant value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Set(ByRef $aVector, Const $nIndex, Const $vValue)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    If $nIndex < 0 Or $nIndex >= $aVector[$__VECTOR_CAPACITY] Then
        Return SetError($VECTOR_ERROR_INDEX_OUT_OF_BOUNDS, 0, 0)
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
    $aContainer[$nIndex] = $vValue
    $aVector[$__VECTOR_BUFFER] = $aContainer

	If $nIndex >= $aVector[$__VECTOR_SIZE] Then
		$aVector[$__VECTOR_SIZE] = $nIndex + 1
	EndIf

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_AddVector
; Description ...: Adds the values of the second vector to the first vector.
; Syntax ........: _Vector_AddVector(Byref $aVector, Const Byref $aFromVector)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $aFromVector         - [in/out and const] an array of unknowns.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_AddVector(ByRef $aVector, Const ByRef $aFromVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aValuesToAdd = _Vector_GetBuffer($aFromVector) ;~ Contains IsVector Check
	If @error                    Then Return SetError(@error, 0, 0)
	If UBound($aValuesToAdd) = 0 Then Return 1

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
	Local $nSize      = $aVector[$__VECTOR_SIZE]
	Local $nFromSize  = $aFromVector[$__VECTOR_SIZE]

	;~ Eesize if needed
	If Not __Vector_HasSpace($aVector, $nFromSize, True) Then
		Local $nNewCapacity = __Vector_CalculateCapacity($aVector[$__VECTOR_CAPACITY], $nSize + $nFromSize, $aVector[$__VECTOR_MODIFIER])

		ReDim $aContainer[$nNewCapacity]
		$aVector[$__VECTOR_CAPACITY] = $nNewCapacity
	EndIf

	;~ add
	Local $i = $nSize
	For $vValue In $aValuesToAdd
		$aContainer[$i] = $vValue
		$i += 1
	Next

    $aVector[$__VECTOR_SIZE] += $nSize
    $aVector[$__VECTOR_BUFFER] = $aContainer

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Erase
; Description ...: Erases the specified element from the Vector.
; Syntax ........: _Vector_Erase(Byref $aVector, Const $nIndex)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $nIndex              - [const] a general number value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Erase(ByRef $aVector, Const $nIndex)
    If Not __Vector_IsValidIndex($aVector, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
    $aVector[$__VECTOR_SIZE] -= 1

    For $i = $nIndex To $aVector[$__VECTOR_SIZE] - 1
        $aContainer[$i] = $aContainer[$i + 1]
    Next

    $aVector[$__VECTOR_BUFFER] = $aContainer

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_EraseRange
; Description ...: Erases the specified elements from the Vector.
; Syntax ........: _Vector_EraseRange(Byref $aVector, Const $nIndexStart, Const $nIndexEnd)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $nIndexStart         - [const] a general number value.
;                  $nIndexEnd           - [const] a general number value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_EraseRange(ByRef $aVector, Const $nIndexStart, Const $nIndexEnd)
    If $nIndexStart = $nIndexEnd Then
        Return _Vector_Erase($aVector, $nIndexStart)
    EndIf

    If Not __Vector_IsValidIndex($aVector, $nIndexStart, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not __Vector_IsValidIndex($aVector, $nIndexEnd, True) Then
        Return SetError(@error, 1, 0)
    EndIf

    Local $nDiff      = Abs($nIndexStart - $nIndexEnd) + 1
    Local $aContainer = $aVector[$__VECTOR_BUFFER]

    Local $nStart = ($nIndexStart > $nIndexEnd) ? ($nIndexEnd) : ($nIndexStart)

    $aVector[$__VECTOR_SIZE] -= $nDiff

    For $i = $nStart To $aVector[$__VECTOR_SIZE] - 1
        $aContainer[$i] = $aContainer[$i + $nDiff]
    Next

    $aVector[$__VECTOR_BUFFER] = $aContainer

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_EraseValue
; Description ...: Erases all of the elements with the specified value from the Vector.
; Syntax ........: _Vector_EraseValue(Byref $aVector, Const $vValue)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $vValue              - [const] a variant value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......: Nadav
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_EraseValue(ByRef $aVector, Const $vValue)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    ;~ Its harder to find every matching value and erase + reloop all over again
    ;~ so just copying the vector without matching values
    Local $aNewVector = _Vector_Init( _
                            $aVector[$__VECTOR_CAPACITY], _
                            $aVector[$__VECTOR_DEFAULT], _
                            $aVector[$__VECTOR_MODIFIER]  _
                        )

    Local $sValueType = VarGetType($vValue)

    For $v In _Vector_GetBuffer($aVector)
        If __Vector_Compare($aVector[$__VECTOR_COMPARE], $v, $vValue, $sValueType) = 0 Then
            ContinueLoop
        EndIf

        _Vector_Push($aNewVector, $v)
    Next

    $aVector = $aNewVector

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Swap
; Description ...: Swaps between the values of the specified elements in the Vector.
; Syntax ........: _Vector_Swap(Byref $aVector, Const $nIndex1, Const $nIndex2)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $nIndex1             - [const] a general number value.
;                  $nIndex2             - [const] a general number value.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Nadav
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Swap(ByRef $aVector, Const $nIndex1, Const $nIndex2)
    If Not __Vector_IsValidIndex($aVector, $nIndex1, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not __Vector_IsValidIndex($aVector, $nIndex2, True) Then
        Return SetError(@error, 0, 0)
    EndIf

    __Vector_SwapContainer($aVector[$__VECTOR_BUFFER], $nIndex1, $nIndex2)

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_SwapVectors
; Description ...: Swaps between the Vectors.
; Syntax ........: _Vector_SwapVectors(Byref $aVectorL, Byref $aVectorR)
; Parameters ....: $aVectorL            - [in/out] an array of unknowns.
;                  $aVectorR            - [in/out] an array of unknowns.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_SwapVectors(ByRef $aVectorL, ByRef $aVectorR)
    If Not _Vector_IsVector($aVectorL) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not _Vector_IsVector($aVectorR) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aTempVector = $aVectorR
    $aVectorR = $aVectorL
    $aVectorL = $aTempVector

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Clear
; Description ...: Erases all elements from the container.
; Syntax ........: _Vector_Clear(Byref $aVector)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......: After this call, size returns zero.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Clear(ByRef $aVector)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]

    For $i = 0 To $aVector[$__VECTOR_SIZE] - 1
        $aContainer[$i] = $aVector[$__VECTOR_DEFAULT]
    Next

    $aVector[$__VECTOR_BUFFER] = $aContainer
    $aVector[$__VECTOR_SIZE]   = 0

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Find
; Description ...: Checks whether the given value exists in the Vector.
; Syntax ........: _Vector_Find(Const Byref $aVector, Const $vValue)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
;                  $vValue              - [const] a variant value.
; Return values .: 1 if the value has been found, 0 otherwise.
; Author ........: Nadav
; Modified ......: Zvend
; Remarks .......: Searches the value from the beggining of the Vector.
; ...............: Sets @extended to the index of the first element contains the specified value, -1 otherwise.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Find(Const ByRef $aVector, Const $vValue)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

	If $aVector[$__VECTOR_SIZE] = 0 Then
		Return SetExtended(-1, 0)
	EndIf


    Local $aContainer = $aVector[$__VECTOR_BUFFER]

    For $i = 0 To $aVector[$__VECTOR_SIZE] - 1
        If $aContainer[$i] = $vValue Then
			Return SetExtended($i, 1)
		EndIf
    Next

	Return SetExtended(-1, 0)
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_FindBackwards
; Description ...: Checks whether the given value exists in the Vector.
; Syntax ........: _Vector_FindBackwards(Const Byref $aVector, Const $vValue)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
;                  $vValue              - [const] a variant value.
; Return values .: 1 if the value has been found, 0 otherwise.
; Author ........: Zvend
; Modified ......:
; Remarks .......: Searches the value from the end of the Vector.
; ...............: Sets @extended to the index of the last element contains the specified value, -1 otherwise.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_FindBackwards(Const ByRef $aVector, Const $vValue)
    If Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

	If $aVector[$__VECTOR_SIZE] = 0 Then
		Return SetExtended(-1, 0)
	EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]

    For $i = $aVector[$__VECTOR_SIZE] - 1 To 0 Step -1
        If $aContainer[$i] = $vValue Then
			Return SetExtended($i, 1)
		EndIf
    Next

	Return SetExtended(-1, 0)
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Sort
; Description ...: Sorts the Vector.
; Syntax ........: _Vector_Sort(ByRef $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: 1 for success, 0 otherwise.
; Author ........: Nadav
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Sort(ByRef $aVector)
    If _Vector_GetSize($aVector) <= 1 Then
        Return SetError(@error, 0, @error = $VECTOR_NO_ERROR)
    EndIf

    __Vector_QuickSort($aVector, $aVector[$__VECTOR_BUFFER], 0, $aVector[$__VECTOR_SIZE] - 1)
    Return 1
EndFunc



#Region Internal Only


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Vector_IsValidIndex
; Description ...: Checks whether the index is a valid for the Vector.
; Syntax ........: __Vector_IsValidIndex(Const Byref $aVector, Const $nIndex, Const $bSkipVectorCheck)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
;                  $nIndex              - [const] a general number value.
;                  $bSkipVectorCheck    - [const] a boolean value.
; Return values .: 1 if the index is valid, 0 otherwise.
; Author ........: Zvend
; Modified ......: Nadav
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Vector_IsValidIndex(Const ByRef $aVector, Const $nIndex, Const $bSkipVectorCheck)
    If Not $bSkipVectorCheck And Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    If $nIndex < 0 Or $nIndex >= $aVector[$__VECTOR_SIZE] Then
        Return SetError($VECTOR_ERROR_INDEX_OUT_OF_BOUNDS, 0, 0)
    EndIf

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: __Vector_HasSpace
; Description ...: Checks whether the vector has enough space for $nSize elements.
; Syntax ........: __Vector_HasSpace(Const Byref $aVector, Const $nSize, Const $bSkipVectorCheck)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
;                  $nSize               - [const] a general number value.
;                  $bSkipVectorCheck    - [const] a boolean value.
; Return values .: True if have enough space, False otherwise
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Vector_HasSpace(Const ByRef $aVector, Const $nSize, Const $bSkipVectorCheck)
    If Not $bSkipVectorCheck And Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $aVector[$__VECTOR_CAPACITY] - $aVector[$__VECTOR_SIZE] >= $nSize
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Vector_CalculateCapacity
; Description ...: Calculates the capacity for the specified required size and modifier.
; Syntax ........: __Vector_CalculateCapacity($nCapacity, Const $nRequiredSize, $nModifier)
; Parameters ....: $nCapacity           - a general number value.
;                  $nRequiredSize       - [const] a general number value.
;                  $nModifier           - a general number value.
; Return values .: The capacity.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Vector_CalculateCapacity($nCapacity, Const $nRequiredSize, $nModifier)
	If $nModifier < 1.5 Then $nModifier = 1.5
	If $nCapacity < 4   Then $nCapacity = 4

    While $nRequiredSize > $nCapacity
        $nCapacity = Floor($nCapacity * $nModifier)
    WEnd

    Return $nCapacity
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Vector_QuickSort
; Description ...: Sorts the Vector using Quicksort with HighIndex-Pivot.
; Syntax ........: __Vector_QuickSort(Byref $aVector, Byref $aContainer, Const $nLowIndex, Const $nHighIndex)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $aContainer          - [in/out] an array of unknowns.
;                  $nLowIndex           - [const] a general number value.
;                  $nHighIndex          - [const] a general number value.
; Return values .: None
; Author ........: Nadav
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Vector_QuickSort(ByRef $aVector, ByRef $aContainer, Const $nLowIndex, Const $nHighIndex)
    If $nLowIndex >= $nHighIndex Then Return

    Local $nPartitionIndex = __Vector_QuickSortPartition($aVector, $aContainer, $nLowIndex, $nHighIndex)

    __Vector_QuickSort($aVector, $aContainer, $nLowIndex, $nPartitionIndex - 1)
    __Vector_QuickSort($aVector, $aContainer, $nPartitionIndex + 1, $nHighIndex)
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Vector_QuickSortPartition
; Description ...: Moves all of the values that are smaller
; Syntax ........: __Vector_QuickSortPartition(Byref $aVector, Byref $aContainer, Const $nLowIndex, Const $nHighIndex)
; Parameters ....: $aVector             - [in/out] an array of unknowns.
;                  $aContainer          - [in/out] an array of unknowns.
;                  $nLowIndex           - [const] a general number value.
;                  $nHighIndex          - [const] a general number value.
; Return values .: Returns the Partition's pivot.
; Author ........: Nadav
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Vector_QuickSortPartition(ByRef $aVector, ByRef $aContainer, Const $nLowIndex, Const $nHighIndex)
    ;~ Choose the Pivot as the last index.
    Local $vPivot = $aContainer[$nHighIndex]

    Local $i = $nLowIndex - 1

    For $j = $nLowIndex To $nHighIndex - 1
        ;~ If the current element is smaller than the pivot
        If __Vector_Compare($aVector[$__VECTOR_COMPARE], $aContainer[$j], $vPivot) < 0 Then
            $i += 1
            __Vector_SwapContainer($aContainer, $i, $j)
        EndIf
    Next

    $i += 1
    __Vector_SwapContainer($aContainer, $i, $nHighIndex)

    Return $i
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Vector_SwapContainer
; Description ...: Swaps between the values of the specified elements.
; Syntax ........: __Vector_SwapContainer(Byref $aContainer, Const $nIndex1, Const $nIndex2)
; Parameters ....: $aContainer          - [in/out] an array of unknowns.
;                  $nIndex1             - [const] a general number value.
;                  $nIndex2             - [const] a general number value.
; Return values .: None
; Author ........: Nadav
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Vector_SwapContainer(ByRef $aContainer, Const $nIndex1, Const $nIndex2)
    Local $vTemp = $aContainer[$nIndex1]
    $aContainer[$nIndex1] = $aContainer[$nIndex2]
    $aContainer[$nIndex2] = $vTemp
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Vector_Compare
; Description ...: Compares the specified values.
; Syntax ........: __Vector_Compare(Const Byref $fuCompare, Const $vValue1, Const $vValue2)
; Parameters ....: $fuCompare           - [in/out and const] function (first class object).
;                  $vValue1             - [const] a variant value.
;                  $vValue2             - [const] a variant value.
; Return values .: A negative number if the first was smaller, 0 if the values are equal,
;                  and a positive number if the first was larger.
; Author ........: Nadav
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Vector_Compare(Const ByRef $fuCompare, Const $vValue1, Const $vValue2, $sValueType = Default)

    If $fuCompare <> Null Then
        Return Call($fuCompare, $vValue1, $vValue2)
    EndIf

    If $sValueType = Default Then
        $sValueType = VarGetType($vValue1)
    EndIf

    If $sValueType <> VarGetType($vValue2) Then
        Return SetError($VECTOR_ERROR_INVALID_COMPARISION, 0, 0)
    EndIf

    Switch $sValueType
        Case "Array"
            ;~ CLEANUP: also check array contents?
            Return UBound($vValue1) - UBound($vValue2)

        Case "Function"
            If FuncName($vValue1) == FuncName($vValue2) Then
                Return 0
            ElseIf FuncName($vValue1) < FuncName($vValue2) Then
                Return -1
            Else
                Return 1
            EndIf

        Case "DLLStruct"
            ;~ CLEANUP: Should use memcmp instead?
            Return DllStructGetPtr($vValue1) - DllStructGetPtr($vValue2)

        Case Else
            Return $vValue1 - $vValue2
    EndSwitch
EndFunc

#EndRegion Internal Only


