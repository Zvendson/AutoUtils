#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:       Zvend
 Discord:      Zvend#6666

 Script Function:
	_Vector_Init(Const $nCapacity = 32)                                      -> Vector
	_Vector_GetSize(Const ByRef $aVector)                                    -> UInt
	_Vector_GetCapacity(Const ByRef $aVector)                                -> UInt
	_Vector_IsEmpty(Const ByRef $aVector)                                    -> Bool
	_Vector_Get(Const ByRef $aVector, Const $nIndex)                         -> Variant
	_Vector_GetValues(Const ByRef $aVector)                                  -> Array
	_Vector_Reserve(ByRef $aVector, Const $nCapacity)                        -> Bool
	_Vector_Insert(ByRef $aVector, Const $nIndex, Const $vValue)             -> Bool
	_Vector_Push(ByRef $aVector, Const $vValue)                              -> Bool
	_Vector_Pop(ByRef $aVector)                                              -> Variant / Null
	_Vector_PopFirst(ByRef $aVector)                                         -> Variant / Null
	_Vector_Set(ByRef $aVector, Const $nIndex, Const $vValue)                -> Bool
	_Vector_Erase(ByRef $aVector, Const $nIndex)                             -> Bool
	_Vector_EraseRange(ByRef $aVector, Const $nIndexStart, Const $nIndexEnd) -> Bool
	_Vector_EraseByValue(ByRef $aVector, Const $vValue)                      -> Bool
	_Vector_Clear(ByRef $aVector)                                            -> Bool

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



Func _Vector_Init(Const $nCapacity = 32)
	Local $aContainer[$nCapacity]
	For $i = 0 To $nCapacity - 1
		$aContainer[$i] = Null
	Next
Global Enum _
    $__VECTOR_SIZE     , _
    $__VECTOR_CAPACITY , _
    $__VECTOR_DEFAULT  , _
    $__VECTOR_MODIFIER , _
    $__VECTOR_BUFFER   , _
    $__VECTOR_PARAMS

    Local $aVector[3] = [0, $nCapacity, $aContainer]

    Return $aVector
EndFunc



Func _Vector_GetSize(Const ByRef $aVector)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

    Return $aVector[0]
EndFunc



Func _Vector_GetCapacity(Const ByRef $aVector)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

    Return $aVector[1]
EndFunc



Func _Vector_IsEmpty(Const ByRef $aVector)
	Local $nSize = _Vector_GetSize($aVector)
    Return SetError(@error, @extended, $nSize = 0)
EndFunc



Func _Vector_Get(Const ByRef $aVector, Const $nIndex)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, Null)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, Null)
	EndIf

    If $nIndex < 0 Or $nIndex >= $aVector[0] Then
		Return SetError(3, 0, Null)
    EndIf

	Local $aContainer = $aVector[2]

	Return $aContainer[$nIndex]
EndFunc



Func _Vector_GetValues(Const ByRef $aVector)
	Static Local $aEmptyContainer[0]

	If Not IsArray($aVector) Then
		Return SetError(1, 0, $aEmptyContainer)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, $aEmptyContainer)
	EndIf

	Local $aContainer = $aVector[2]
	ReDim $aContainer[$aVector[0]]

	Return $aContainer
EndFunc



Func _Vector_Reserve(ByRef $aVector, Const $nCapacity)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

	If $nCapacity <= $aVector[1] Then
		Return 1
	EndIf

	Local $aContainer = $aVector[2]
	Local $nNewCapacity = __Vector_CalculateSize($aVector[1], $nCapacity)

	ReDim $aContainer[$nNewCapacity]

	$aVector[1] = $nNewCapacity
	$aVector[2] = $aContainer

	Return 1
EndFunc



Func _Vector_Insert(ByRef $aVector, Const $nIndex, Const $vValue)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

    If $nIndex < 0 Or $nIndex >= $aVector[0] Then
		Return SetError(3, 0, 0)
    EndIf

	Local $nNextSize = $aVector[0] + 1
	Local $aContainer = $aVector[2]

	If $nNextSize > $aVector[1] Then
        Local $nNewSize = __Vector_CalculateSize($aVector[1], $nNextSize)
		ReDim $aContainer[$nNewSize]
		$aVector[1] = $nNewSize
	EndIf


	For $i = $aVector[0] To $nIndex Step -1
		$aContainer[$i] = $aContainer[$i - 1]
	Next

	$aContainer[$nIndex] = $vValue
	$aVector[0] += 1

	$aVector[2] = $aContainer

	Return 1
EndFunc



Func _Vector_Push(ByRef $aVector, Const $vValue)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, Null)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, Null)
	EndIf

	Local $nNextSize = $aVector[0] + 1
	Local $aContainer = $aVector[2]

	If $nNextSize > $aVector[1] Then
        Local $nNewSize = __Vector_CalculateSize($aVector[1], $nNextSize)
		ReDim $aContainer[$nNewSize]
		$aVector[1] = $nNewSize
	EndIf

    $aContainer[$aVector[0]] = $vValue
	$aVector[0] = $nNextSize
	$aVector[2] = $aContainer

	Return 1
EndFunc



Func _Vector_Pop(ByRef $aVector)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, Null)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, Null)
	EndIf

	If $aVector[0] <= 0 Then
		Return SetError(3, 0, Null)
	EndIf

	Local $aContainer = $aVector[2]
	$aVector[0] -= 1

	Local $vValue = $aContainer[$aVector[0]]
	$aContainer[$aVector[0]] = Null

	Return $vValue
EndFunc



Func _Vector_PopFirst(ByRef $aVector)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, Null)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, Null)
	EndIf

	If $aVector[0] <= 0 Then
		Return SetError(3, 0, Null)
	EndIf

	Local $aContainer = $aVector[2]
	$aVector[0] -= 1
	Local $vValue = $aContainer[0]

	For $i = 0 To $aVector[0] - 1
		$aContainer[$i] = $aContainer[$i + 1]
	Next

	$aVector[2] = $aContainer

	Return $vValue
EndFunc



Func _Vector_Set(ByRef $aVector, Const $nIndex, Const $vValue)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, Null)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, Null)
	EndIf

    If $nIndex < 0 Or $nIndex >= $aVector[0] Then
		Return SetError(3, 0, Null)
    EndIf

	Local $aContainer = $aVector[2]
	$aContainer[$nIndex] = $vValue
	$aVector[2] = $aContainer

	Return 1
EndFunc



Func _Vector_Erase(ByRef $aVector, Const $nIndex)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

    If $nIndex < 0 Or $nIndex >= $aVector[0] Then
		Return SetError(3, 0, 0)
    EndIf

	Local $aContainer = $aVector[2]
	$aVector[0] -= 1

	For $i = $nIndex To $aVector[0] - 1
		$aContainer[$i] = $aContainer[$i + 1]
	Next

	$aVector[2] = $aContainer

	Return 1
EndFunc



Func _Vector_EraseRange(ByRef $aVector, Const $nIndexStart, Const $nIndexEnd)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

    If $nIndexStart < 0 Or $nIndexStart >= $aVector[0] Then
		Return SetError(3, 0, 0)
    EndIf

    If $nIndexEnd < 0 Or $nIndexEnd >= $aVector[0] Then
		Return SetError(4, 0, 0)
    EndIf

	If $nIndexStart = $nIndexEnd Then
		Return _Vector_Erase($aVector, $nIndexStart)
	EndIf

	Local $nDiff      = Abs($nIndexStart - $nIndexEnd) + 1
	Local $nStart     = ($nIndexStart > $nIndexEnd) ? ($nIndexEnd) : ($nIndexStart)
	Local $aContainer = $aVector[2]
	$aVector[0] -= $nDiff

	For $i = $nStart To $aVector[0] - 1
		$aContainer[$i] = $aContainer[$i + $nDiff]
	Next

	$aVector[2] = $aContainer

	Return 1
EndFunc



Func _Vector_EraseValue(ByRef $aVector, Const $vValue)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

	;~ Its harder to find every matching value and erase + reloop all over again
	;~ so just copying the vector without matching values
	Local $aNewVector = _Vector_Init($aVector[1])

	For $v In _Vector_GetValues($aVector)
		Select
			Case IsString($v) And IsString($vValue) And $v == $vValue
				ContinueLoop

			Case IsArray($v) And IsArray($vValue) And UBound($v) = UBound($vValue)
				ContinueLoop ;~ TODO: check array contents

			Case IsFunc($v) And IsFunc($vValue) And FuncName($v) == FuncName($vValue)
				ContinueLoop

			Case IsDllStruct($v) And IsDllStruct($vValue) And DllStructGetPtr($v) = DllStructGetPtr($vValue)
				ContinueLoop

			Case $v = $vValue
				ContinueLoop

		EndSelect

		_Vector_Push($aNewVector, $v)
	Next

	$aVector = $aNewVector

	Return 1
EndFunc



Func _Vector_Clear(ByRef $aVector)
	If Not IsArray($aVector) Then
		Return SetError(1, 0, 0)
	EndIf

	If UBound($aVector) <> 3 Then
		Return SetError(2, 0, 0)
	EndIf

    $aVector = _Vector_Init($aVector[1])

	Return 1
EndFunc



Func __Vector_CalculateSize(Const $nCurrentSize, Const $nRequiredSize)
	Local $nCapacity = $nCurrentSize

	While $nRequiredSize > $nCapacity
		$nCapacity = Floor($nCapacity * 1.5)
	WEnd

	Return $nCapacity
EndFunc


