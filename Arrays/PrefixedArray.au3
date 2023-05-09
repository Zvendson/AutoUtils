#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:       Zvend
 Discord:      Zvend#6666

 Script Function:
	_PrefixArray_Init(Const $nSize = 32) -> Array[Size + 1]
	_PrefixArray_Resize(ByRef $aArray, Const $nIndex) -> Bool
	_PrefixArray_Get(Const ByRef $aArray, Const $nIndex, Const $vDefaultValue = Null) -> Variant
	_PrefixArray_Set(ByRef $aArray, Const $nIndex, Const $vValue) -> Bool
	_PrefixArray_Reset(ByRef $aArray, Const $nSize = 32) -> Bool

 Description:
	Prefixed Arrays are meant to be index controlled. So instead of adding the new value to the end of the array it will always
	require where to write the array and if necessary it will resize the array accordingly.
	This is very useful for arrays with fixed IDs.
	Lets say you got a room full with students. You assign a number to each of them from 1-N.
	(Number 0 is reserved for the current size of the array.

	When your array can only hold 5 students and you get a 6th one, the Prefixed Array will auto increase the size by 1.5 of the
	array until it can hold the new student.

#ce ----------------------------------------------------------------------------

#cs - Guide --------------------------------------------------------------------

 How To Use:
	Initialize your global array like:

		Global $g_aMyArray = _PrefixArray_Init(4)

	This will create an array of size 4 indexes (1-4) and index 0 is always the current size of the array.
	Empty fields will always return Null.
	Now Set your values like:

		_PrefixArray_Set($g_aMyArray, 1, "I am a value")
		_PrefixArray_Set($g_aMyArray, 2, "Look another value!")
		_PrefixArray_Set($g_aMyArray, 4, "I am the end of this array!")
		_PrefixArray_Set($g_aMyArray, 8, "No you are not!")

	If you sharpened your eyes you see that setting on index 8 should not be possible, since we gave the array a size of 4.
	But it will auto resize the array by calculating the size like 'Floor(size * 1.5)' until the index 8 fits in the array.
	So 4 * 1.5 = 6 and 6 * 1.5 = 9. The array will be resized to size 9.

	You should always get the values by _PrefixArray_Get(). it will error check and prevent autoit from crashing if index is out of bounds.
	If you need to completely reset your array (Nulling all values) + resizing to a default value, you can use:
	    _PrefixArray_Reset($g_aMyArray, 4)

	All values will be Null again. You could also just call:
		$g_aMyArray = _PrefixArray_Init(4)

	Since it would do the exact same like Reset BUT using _PrefixArray_Reset() is by far more readable.

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

Func _PrefixArray_Init(Const $nSize = 32)
	Local $aArray[$nSize + 1]
	$aArray[0] = $nSize

	For $i = 1 To $nSize
		$aArray[$i] = Null
	Next

    Return $aArray
EndFunc



Func _PrefixArray_Resize(ByRef $aArray, Const $nIndex)
	If Not IsArray($aArray) Then
		Return SetError(1, 0, 0)
	EndIf

	If $nIndex < $aArray[0] Then
		Return 1
	EndIf

	Local $nNewSize = $aArray[0]
	Local $nOldSize = $aArray[0]

	While $nIndex >= $nNewSize
		$nNewSize = Floor($nNewSize * 1.5)
	WEnd

	$aArray[0] = $nNewSize

    ReDim $aArray[$nNewSize + 1]
	For $i = $nOldSize To $aArray[0]
		$aArray[$i] = Null
	Next

    Return 1
EndFunc



Func _PrefixArray_Get(Const ByRef $aArray, Const $nIndex, Const $vDefaultValue = Null)
	If Not IsArray($aArray) Then
		Return SetError(1, 0, $vDefaultValue)
	EndIf

    If $nIndex >= 0 And $nIndex < $aArray[0] Then
        Return $aArray[$nIndex]
    EndIf

	Return SetError(2, 0, $vDefaultValue)
EndFunc



Func _PrefixArray_Set(ByRef $aArray, Const $nIndex, Const $vValue)
	If Not IsArray($aArray) Then
		Return SetError(1, 0, 0)
	EndIf

	If $nIndex < 1 Then
		Return SetError(2, 0, 0)
	EndIf

	_PrefixArray_Resize($aArray, $nIndex)

    If $nIndex < $aArray[0] Then
        $aArray[$nIndex] = $vValue
		Return 1
    EndIf

	Return SetError(2, 0, 0)
EndFunc



Func _PrefixArray_Reset(ByRef $aArray, Const $nSize = 32)
	If Not IsArray($aArray) Then
		Return SetError(1, 0, 0)
	EndIf

	$aArray = _PrefixArray_Init($nSize)

	Return 1
EndFunc


