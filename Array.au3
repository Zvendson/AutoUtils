#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author:          Zvend
 Discord(s):      zvend

 Description:
	Easily creates autoit arrays but hides all the stuff about ReDim and let's
	you worry about different things. It also allows you to use negative
	indecies for a backwards lookup. Invalid indecies wont break the script
	and will just shoot an error, causing the script to run more 'saver'.

	Although it only covers 1D arrays you can nest arrays.
	Example:
		$g_aArray = _Array_New(3, _Array_New(3))

	This will result in following array:
		[ [0, 0, 0],  [0, 0, 0],  [0, 0, 0] ]

	And to get a subarray you simply do as usual:
		_Array_Get($g_aArray, 0)
		_Array_Get($g_aArray, 1)
		_Array_Get($g_aArray, 2)

	Modifying those will be a bit more 'complicated':
		$aSubarray = _Array_Get($g_aArray, 1)
		_Array_Set($aSubarray, 2, 42)
		_Array_Set($g_aArray, 1, $aSubarray)

	This will result in following array:
		[ [0, 0, 0],  [0, 0, 42],  [0, 0, 0] ]


 Script Function:
	_Array_New($nArraySize = 0, Const $vInitValue = 0)				-> Array
	_Array_Resize(ByRef $avArray, $nNewSize)						-> Bool
	_Array_GetSize(Const ByRef $avArray)							-> UInt
	_Array_GetInitValue(Const ByRef $avArray)						-> Variant
	_Array_Get(Const ByRef $avArray, $nIndex, Const $vValue = 0)	-> Variant
	_Array_Set(ByRef $avArray, $nIndex, Const $vValue)				-> Bool

 Internal Functions:
	__Array_GetIndex(Const ByRef $avArray, $nIndex)              	-> UInt
	__Array_IsSizeValid(Const $nSize)                            	-> Bool


#ce ----------------------------------------------------------------------------

#include-once
#RequireAdmin
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7


Global Const $ARRAYERR_NO_ARRAY      = 1
Global Const $ARRAYERR_INVALID_SIZE  = 2
Global Const $ARRAYERR_INVALID_INDEX = 3

Global Enum $__AU_ARRAY_SIZE, _
			$__AU_ARRAY_INITVALUE, _
			$__AU_ARRAY_RESERVED
Global Const $__AU_ARRAY_EMPTY = [0, 0]


; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_New
; Description ...: Initializes a 1D array.
; Syntax ........: _Array_New($nArraySize, Const $vInitValue)
; Parameters ....: $nArraySize          - [optional] The size of the new array. Default is 0.
;                  $vInitValue          - [optional] A Variant to set a default value on init and resize. Default is 0.
; Return values .: The new array on Success, empty array on Failure and sets the errorcode to $ARRAYERR_INVALID_SIZE.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: _Array_Resize, _Array_GetSize, _Array_GetInitValue, _Array_Get, _Array_Set
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Array_New($nArraySize = 0, Const $vInitValue = 0)
	$nArraySize = Int(Abs($nArraySize))

	If Not __Array_IsSizeValid($nArraySize) Then
		Return SetError($ARRAYERR_INVALID_SIZE, 0, $__AU_ARRAY_EMPTY)
	EndIf

	Local $avArray[$__AU_ARRAY_RESERVED + $nArraySize]
	$avArray[$__AU_ARRAY_SIZE]      = $nArraySize
	$avArray[$__AU_ARRAY_INITVALUE] = $vInitValue

	For $i = $__AU_ARRAY_RESERVED To $nArraySize + $__AU_ARRAY_RESERVED - 1
		$avArray[$i] = $vInitValue
	Next

	Return $avArray
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_Resize
; Description ...: Resizes an array created through _Array_New.
; Syntax ........: _Array_Resize(ByRef $avArray, $nNewSize)
; Parameters ....: $avArray             - [in/out] The array.
;                  $nNewSize            - A general number value.
; Return values .: 1 on Success, 0 on Failure and sets the errorcode to $ARRAYERR_NO_ARRAY or $ARRAYERR_INVALID_SIZE.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: _Array_New, _Array_GetSize, _Array_GetInitValue, _Array_Get, _Array_Set
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Array_Resize(ByRef $avArray, $nNewSize)
	If Not IsArray($avArray) Then
		Return SetError($ARRAYERR_NO_ARRAY, 0, 0)
	EndIf

	$nNewSize = Int(Abs($nNewSize))

	If Not __Array_IsSizeValid($nNewSize) Then
		Return SetError($ARRAYERR_INVALID_SIZE, 0, 0)
	EndIf

	Local $nOldSize = $avArray[$__AU_ARRAY_SIZE]

	If $nOldSize = $nNewSize Then
		Return 1
	EndIf

	ReDim $avArray[$__AU_ARRAY_RESERVED + $nNewSize]
	$avArray[$__AU_ARRAY_SIZE] = $nNewSize

	If $nOldSize < $nNewSize Then

		For $i = $nOldSize + $__AU_ARRAY_RESERVED To $nNewSize + $__AU_ARRAY_RESERVED - 1
			$avArray[$i] = $avArray[$__AU_ARRAY_INITVALUE]
		Next

	EndIf

	Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_GetSize
; Description ...: Returns the size of an array.
; Syntax ........: _Array_GetSize(Const ByRef $avArray)
; Parameters ....: $avArray             - [in/out and const] The array.
; Return values .: The size of the array on Success, 0 on Failure and sets the errorcode to $ARRAYERR_NO_ARRAY.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Array_GetSize(Const ByRef $avArray)
	If Not IsArray($avArray) Then
		Return SetError($ARRAYERR_NO_ARRAY, 0, 0)
	EndIf

	Return $avArray[$__AU_ARRAY_SIZE]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_GetInitValue
; Description ...: Returns the default init value of unset elements
; Syntax ........: _Array_GetInitValue(Const ByRef $avArray)
; Parameters ....: $avArray             - [in/out and const] The array.
; Return values .: The init value of an array element on Success, 0 on Failure and sets the errorcode to $ARRAYERR_NO_ARRAY.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: _Array_GetSize, _Array_Get, _Array_Set
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Array_GetInitValue(Const ByRef $avArray)
	If Not IsArray($avArray) Then
		Return SetError($ARRAYERR_NO_ARRAY, 0, 0)
	EndIf

	Return $avArray[$__AU_ARRAY_INITVALUE]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_Get
; Description ...: Returns the current value of the specified element. Negative index for backwards looking.
; Syntax ........: _Array_Get(Const ByRef $avArray, $nIndex, Const $vValue)
; Parameters ....: $avArray             - [in/out and const] The array.
;                  $nIndex              - A general number value.
;                  $vValue              - [optional] A variant value. Default is 0.
; Return values .: The current value of an array element on Success, 0 on Failure and sets the errorcode to $ARRAYERR_NO_ARRAY
;                  or $ARRAYERR_INVALID_INDEX.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: _Array_Set, _Array_GetSize, _Array_GetInitValue
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Array_Get(Const ByRef $avArray, $nIndex, Const $vValue = 0)
	$nIndex = __Array_GetIndex($avArray, $nIndex)
	If @error Then
		Return SetError(@error, 0, $vValue)
	EndIf

	Return $avArray[$__AU_ARRAY_RESERVED + $nIndex]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_Set
; Description ...: Modifies the current value of the specified element. Negative index for backwards looking.
; Syntax ........: _Array_Set(ByRef $avArray, $nIndex, Const $vValue)
; Parameters ....: $avArray             - [in/out] The array.
;                  $nIndex              - A general number value.
;                  $vValue              - A variant value.
; Return values .: 1 on Success, 0 on Failure and sets the errorcode to $ARRAYERR_NO_ARRAY or $ARRAYERR_INVALID_INDEX.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: _Array_Get, _Array_GetSize, _Array_GetInitValue
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Array_Set(ByRef $avArray, $nIndex, Const $vValue)
	$nIndex = __Array_GetIndex($avArray, $nIndex)
	If @error Then
		Return SetError(@error, 0, 0)
	EndIf

	$avArray[$__AU_ARRAY_RESERVED + $nIndex] = $vValue

	Return 1
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Array_GetIndex
; Description ...: Counterchecks if the index is correct and also converts the index if negative.
; Syntax ........: __Array_GetIndex(Const Byref $avArray, $nIndex)
; Parameters ....: $avArray             - [in/out and const] The array.
;                  $nIndex              - A general number value.
; Return values .: The new index.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Array_GetIndex(Const ByRef $avArray, $nIndex)
	If Not IsArray($avArray) Then
		Return SetError($ARRAYERR_NO_ARRAY, 0, 0)
	EndIf

	Local $nSize = _Array_GetSize($avArray)
	If $nIndex >= $nSize Then
		Return SetError($ARRAYERR_INVALID_INDEX, 0, 0)
	EndIf

	If $nIndex < 0 Then
		$nIndex = $nSize - Abs(Mod($nIndex, $nSize))
	EndIf

	Return $nIndex
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Array_IsSizeValid
; Description ...: Checks whether the size is valid or not.
; Syntax ........: __Array_IsSizeValid(Const $nSize)
; Parameters ....: $nSize               - [const] A general number value.
; Return values .: 1 on Success, 0 on Failure.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Array_IsSizeValid(Const $nSize)
	;AutoIt Arrays are limited to 16 million elements
	Return Int($nSize < (16000000 - $__AU_ARRAY_RESERVED))
EndFunc


