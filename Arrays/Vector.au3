#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author(s):       Zvend       Nadav
 Discord(s):      Zvend#6666  Abaddon#9048

 Script Functions:
    _Vector_Init(Const $nCapacity = 32, Const $vDefaultValue = Null, Const $nModifier = 1.5) -> Vector
    _Vector_IsVector(Const ByRef $aVector)                                                   -> Bool
    _Vector_IsValidIndex(Const ByRef $aVector, Const $nIndex, Const $bSkipVectorCheck)       -> Bool
    _Vector_GetSize(Const ByRef $aVector)                                                    -> UInt
    _Vector_GetCapacity(Const ByRef $aVector)                                                -> UInt
    _Vector_GetDefaultValue(Const ByRef $aVector)                                            -> DefaultValue / Null
    _Vector_GetModifier(Const ByRef $aVector)                                                -> Float
    _Vector_IsEmpty(Const ByRef $aVector)                                                    -> Bool
    _Vector_Get(Const ByRef $aVector, Const $nIndex)                                         -> Variant / Null
    _Vector_GetValues(Const ByRef $aVector)                                                  -> Array
    _Vector_Reserve(ByRef $aVector, Const $nCapacity)                                        -> Bool
    _Vector_Insert(ByRef $aVector, Const $nIndex, Const $vValue)                             -> Bool
    _Vector_Push(ByRef $aVector, Const $vValue)                                              -> Bool
    _Vector_Pop(ByRef $aVector)                                                              -> Variant / DefaultValue / Null
    _Vector_PopFirst(ByRef $aVector)                                                         -> Variant / DefaultValue / Null
    _Vector_Set(ByRef $aVector, Const $nIndex, Const $vValue)                                -> Bool
    _Vector_AddVector(ByRef $aVector, Const ByRef $aFromVector)                              -> Bool
    _Vector_Erase(ByRef $aVector, Const $nIndex)                                             -> Bool
    _Vector_EraseValue(ByRef $aVector, Const $vValue)                                        -> Bool
    _Vector_Swap(ByRef $aVectorL, ByRef $aVectorR)                                           -> Bool
    _Vector_Clear(ByRef $aVector)                                                            -> Bool
    _Vector_Find(Const ByRef $aVector, Const $vValue)                                        -> Bool @extended = index
    _Vector_FindBackwards(Const ByRef $aVector, Const $vValue)                               -> Bool @extended = index

 Internal Functions:
    __Vector_CalculateSize($nCapacity, Const $nRequiredSize, $nModifier)                     -> UInt

 Description:
    This Vector "Class" implementation acts exactly like the stdlib vector from C++ just without typesafe values.
    Of course this will have massive struggle to actually go head to head with the c++ version and was never
    meant to.
    So this vector is kind of "intelligent" in using the ReDim keyword wisely. You init the vector with a
    capacity and as soon the size of the vector will be bigger than its capacity, the vector will auto
    increase the capacity by 1.5 of it current capcity.

#ce ----------------------------------------------------------------------------

#cs - Guide --------------------------------------------------------------------

 How To Use:
    Initialize your vector like:

        Local $aVector = _Vector_Init(4)

    This will create an vector of size 4 and a current size of 0.
    Empty fields are always set to Null as default.
    Now Set your values like:

        _Vector_Push($aVector, "Test 1")
        _Vector_Push($aVector, "Test 2")
        _Vector_Push($aVector, "Test 3")
        _Vector_Push($aVector, "Test")
        _Vector_Push($aVector, "Test 4")
        _Vector_Push($aVector, "Test")
        _Vector_Push($aVector, "Test 5")
        _Vector_Set($aVector, 2, "Ops!")
        _Vector_Set($aVector, 50, "Not gonna happen") ;~ Sets the error flag
        _Vector_Insert($aVector, 3, "Get outta here!")

    If you sharpened your eyes you see that the vector got filled with way more values that it could actually fit in.
    as soon "Test 4" got pushed to the vector, the vector's capacity increased to 6 and then took the "Test 4" in.
    After the 6th value it will increase its capacity again to 9. _Vector_Set should be self explanatory.
    Using _Vector_Set above its capacity will cause an error and wont affect the vector at all.
    _Vector_Insert does what it says. it puts "Get outta here!" at index 3 and every value from index 3 gets set one
    place behind. so Index 3 will be moved to index 4 and then "Get outta here!" is set to index 3. It also increases
    the capacity if needed.

    Now you can loop through your values like:

        For $vValue In _Vector_GetValues($aVector)
            ConsoleWrite($vValue & @LF)
        Next

    Or like:

        For $i = 0 To _Vector_GetSize($aVector) - 1
            ConsoleWrite($i & " = " & _Vector_Get($aVector, $i) & @LF)
        Next

    And delete values with:

        _Vector_EraseValue($aVector, "Test") ;~ Will remove all entries with the value "Test"!
        _Vector_Erase($aVector, 1)
        _Vector_Clear($aVector)
        _Vector_EraseRange($aVector, 2, 4) ;~ Removes index 2, 3 and 4


#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



Global Enum _
    $__VECTOR_SIZE     , _
    $__VECTOR_CAPACITY , _
    $__VECTOR_DEFAULT  , _
    $__VECTOR_MODIFIER , _
    $__VECTOR_BUFFER   , _
    $__VECTOR_PARAMS



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Init
; Description ...: Creates a new Vector.
; Syntax ........: _Vector_Init([$nCapacity = 32[, $vDefaultValue = Null[, $nModifier = 1.5]]])
; Parameters ....: $nCapacity           - [optional] a general number value. Default is 32.
;                  $vDefaultValue       - [optional] a variant value. Default is Null.
;                  $nModifier           - [optional] a general number value. Default is 1.5.
; Return values .: The new Vector.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_Init($nCapacity = 32, Const $vDefaultValue = Null, $nModifier = 1.5)
    If $nModifier < 1.5 Then
        Return SetError(1, 0, Null)
    EndIf

    Local $aContainer[$nCapacity]
    Local $aNewVector[$__VECTOR_PARAMS]
    $aNewVector[$__VECTOR_SIZE]     = 0
    $aNewVector[$__VECTOR_CAPACITY] = $nCapacity
    $aNewVector[$__VECTOR_DEFAULT]  = $vDefaultValue
    $aNewVector[$__VECTOR_MODIFIER] = $nModifier
    $aNewVector[$__VECTOR_BUFFER]   = $aContainer


    Return $aNewVector
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
        Return SetError(1, 0, 0)
    EndIf

    If UBound($aVector) <> $__VECTOR_PARAMS Then
        Return SetError(2, 0, 0)
    EndIf

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_IsValidIndex
; Description ...: Checks whether the index is a valid for the Vector.
; Syntax ........: _Vector_IsValidIndex(Const Byref $aVector, Const $nIndex, Const $bSkipVectorCheck)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
;                  $nIndex              - [const] a general number value.
;                  $bSkipVectorCheck    - [const] a boolean value.
; Return values .: 1 if the index is valid, 0 otherwise
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_IsValidIndex(Const ByRef $aVector, Const $nIndex, Const $bSkipVectorCheck)
    If Not $bSkipVectorCheck And Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    If $nIndex < 0 Or $nIndex >= $aVector[$__VECTOR_SIZE] Then
        Return SetError(3, 0, 0)
    EndIf

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_HasSpace
; Description ...: Checks whether the vector has enough space for $nSize elements.
; Syntax ........: _Vector_HasSpace(Const Byref $aVector, Const $nSize, Const $bSkipVectorCheck)
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
Func _Vector_HasSpace(Const ByRef $aVector, Const $nSize, Const $bSkipVectorCheck)
    If Not $bSkipVectorCheck And Not _Vector_IsVector($aVector) Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $aVector[$__VECTOR_CAPACITY] - $aVector[$__VECTOR_SIZE] >= $nSize
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
    If Not _Vector_IsValidIndex($aVector, $nIndex, False) Then
        Return SetError(@error, 0, Null)
    EndIf

    Local $aContainer = $aVector[$__VECTOR_BUFFER]

	If IsString($aContainer[$nIndex]) And $aContainer[$nIndex] == "" And Not ($aVector[$__VECTOR_DEFAULT] == "") Then
		Return $aVector[$__VECTOR_DEFAULT]
	EndIf

    Return $aContainer[$nIndex]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_GetValues
; Description ...: Return the value's array of the Vector.
; Syntax ........: _Vector_GetValues(Const Byref $aVector)
; Parameters ....: $aVector             - [in/out and const] an array of unknowns.
; Return values .: The value's array of the Vector.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Vector_GetValues(Const ByRef $aVector)
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
    Local $nNewCapacity = __Vector_CalculateSize($aVector[$__VECTOR_CAPACITY], $nCapacity, $aVector[$__VECTOR_MODIFIER])

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
    If Not _Vector_IsValidIndex($aVector, $nIndex, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    Local $nNextSize = $aVector[$__VECTOR_SIZE] + 1
    Local $aContainer = $aVector[$__VECTOR_BUFFER]

    If $nNextSize > $aVector[$__VECTOR_CAPACITY] Then
        Local $nNewSize = __Vector_CalculateSize($aVector[$__VECTOR_CAPACITY], $nNextSize, $aVector[$__VECTOR_MODIFIER])
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
        Local $nNewCapacity = __Vector_CalculateSize($aVector[$__VECTOR_CAPACITY], $nNextSize, $aVector[$__VECTOR_MODIFIER])
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
        Return SetError(3, 0, $aVector[$__VECTOR_DEFAULT])
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
        Return SetError(3, 0, $aVector[$__VECTOR_DEFAULT])
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
        Return SetError(3, 0, 0)
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

    Local $aValuesToAdd = _Vector_GetValues($aFromVector) ;~ Contains IsVector Check
	If @error                    Then Return SetError(@error, 0, 0)
	If UBound($aValuesToAdd) = 0 Then Return SetError(3, 0, 0)

    Local $aContainer = $aVector[$__VECTOR_BUFFER]
	Local $nSize      = $aVector[$__VECTOR_SIZE]
	Local $nFromSize  = $aFromVector[$__VECTOR_SIZE]

	;~ Eesize if needed
	If Not _Vector_HasSpace($aVector, $nFromSize, True) Then
		Local $nNewCapacity = __Vector_CalculateSize($aVector[$__VECTOR_CAPACITY], $nSize + $nFromSize, $aVector[$__VECTOR_MODIFIER])

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
    If Not _Vector_IsValidIndex($aVector, $nIndex, False) Then
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

    If Not _Vector_IsValidIndex($aVector, $nIndexStart, False) Then
        Return SetError(@error, 0, 0)
    EndIf

    If Not _Vector_IsValidIndex($aVector, $nIndexEnd, True) Then
        Return SetError(4, 0, 0)
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
; Modified ......:
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

    For $v In _Vector_GetValues($aVector)
        ;~ TODO: Overall specify better checking.
        ;~ CLEANUP: Add a custom callback for self handling?
        Select
            Case IsString($v) And IsString($vValue) And $v == $vValue
                ContinueLoop

            Case IsArray($v) And IsArray($vValue) And UBound($v) = UBound($vValue)
                ContinueLoop ;~ CLEANUP: also check array contents?

            Case IsFunc($v) And IsFunc($vValue) And FuncName($v) == FuncName($vValue)
                ContinueLoop

            Case IsDllStruct($v) And IsDllStruct($vValue) And DllStructGetPtr($v) = DllStructGetPtr($vValue)
                ContinueLoop ;~ CLEANUP: Should i do a memcmp instead?

            Case $v = $vValue
                ContinueLoop

        EndSelect

        _Vector_Push($aNewVector, $v)
    Next

    $aVector = $aNewVector

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Vector_Swap
; Description ...: Swaps between the Vectors.
; Syntax ........: _Vector_Swap(Byref $aVectorL, Byref $aVectorR)
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
Func _Vector_Swap(ByRef $aVectorL, ByRef $aVectorR)
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



#Region Internal Only

Func __Vector_CalculateSize($nCapacity, Const $nRequiredSize, $nModifier)
	If $nModifier < 1.5 Then $nModifier = 1.5
	If $nCapacity < 4   Then $nCapacity = 4

    While $nRequiredSize > $nCapacity
        $nCapacity = Floor($nCapacity * $nModifier)
    WEnd

    Return $nCapacity
EndFunc

#EndRegion Internal Only


