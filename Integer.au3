#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author(s):       Zvend
 Discord(s):      zvend

 Script Functions:
    _Integer_Validate($nValue, Const $nMin, Const $nMax) -> Int32 | Int64 | UInt32 | UInt64
    _Integer_Int8(Const $nInt)                           -> Int32
    _Integer_Int16(Const $nInt)                          -> Int32
    _Integer_Int32(Const $nInt)                          -> Int32
    _Integer_Int64(Const $nInt)                          -> Int64
    _Integer_UInt8(Const $nInt)                          -> UInt32
    _Integer_UInt16(Const $nInt)                         -> UInt32
    _Integer_UInt32(Const $nInt)                         -> UInt32
    _Integer_UInt64(Const $nInt)                         -> UInt64
    _Integer_BYTE(Const $nInt)                           -> UInt32
    _Integer_WORD(Const $nInt)                           -> UInt32
    _Integer_DWORD(Const $nInt)                          -> UInt32
    _Integer_QWORD(Const $nInt)                          -> UInt64
    _Integer_LoBYTE(Const $nInt16)                       -> UInt32
    _Integer_HiBYTE(Const $nInt16)                       -> UInt32
    _Integer_LoWORD(Const $nInt32)                       -> UInt32
    _Integer_HiWORD(Const $nInt32)                       -> UInt32
    _Integer_LoDWORD(Const $nInt64)                      -> UInt32
    _Integer_HiDWORD(Const $nInt64)                      -> UInt32

 Description:
    Simple and very readable Integer Utils.

#ce ----------------------------------------------------------------------------

#include-once 



Func _Integer_IsInRange($nValue, Const $nMin, Const $nMax) ;-> Boolean
    If Not IsInt($nValue) Then
        Return SetError(1, 0, 0)
    EndIf
    
    Return $nValue <= $nMax And $nValue >= $nMin
EndFunc



Func _Integer_Validate($nValue, Const $nMin, Const $nMax) ;-> Int32 | Int64 | UInt32 | UInt64
    If $nValue > $nMax Then
        Return $nMax
    EndIf

    If $nValue < $nMin Then
        Return $nMin
    EndIf

    Return $nValue
EndFunc



Func _Integer_Int8($nInt) ;-> Int32
    $nInt = _Integer_LoBYTE($nInt)
    Return $nInt - 0x100 * BitShift($nInt, 7)
EndFunc



Func _Integer_Int16($nInt) ;-> Int32
    $nInt = _Integer_LoWORD($nInt)
    Return $nInt - 0x10000 * BitShift($nInt, 15)
EndFunc



Func _Integer_Int32(Const $nInt) ;-> Int32
    Return Int($nInt, 1)
EndFunc



Func _Integer_Int64(Const $nInt) ;-> Int64
    Return Int($nInt, 2)
EndFunc



Func _Integer_UInt8(Const $nInt) ;-> UInt32
    Static Local $tData = DllStructCreate('BYTE;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func _Integer_UInt16(Const $nInt) ;-> UInt32
    Static Local $tData = DllStructCreate('USHORT;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func _Integer_UInt32(Const $nInt) ;-> UInt32
    Static Local $tData = DllStructCreate('UINT;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func _Integer_UInt64(Const $nInt) ;-> UInt64
    Static Local $tData = DllStructCreate('UINT64;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func _Integer_BYTE(Const $nInt) ;-> UInt32
    Return _Integer_UInt8($nInt)
EndFunc



Func _Integer_WORD(Const $nInt) ;-> UInt32
    Static Local $tData = DllStructCreate('WORD;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func _Integer_DWORD(Const $nInt) ;-> UInt32
    Static Local $tData = DllStructCreate('DWORD;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func _Integer_QWORD(Const $nInt) ;-> UInt64
    Return _Integer_UInt64($nInt)
EndFunc



Func _Integer_LoBYTE(Const $nInt16) ;-> UInt32
    Return BitAND($nInt16, 0xFF)
EndFunc



Func _Integer_HiBYTE(Const $nInt16) ;-> UInt32
    Return BitAND(BitShift($nInt16, 8), 0xFF)
EndFunc



Func _Integer_LoWORD(Const $nInt32) ;-> UInt32
    Return BitAND($nInt32, 0xFFFF)
EndFunc



Func _Integer_HiWORD(Const $nInt32) ;-> UInt32
    Return BitShift($nInt32, 16)
EndFunc



Func _Integer_LoDWORD(Const $nInt64) ;-> UInt32
    Static Local $tInt64 = DllStructCreate('INT64;')
    Static Local $tQWord = DllStructCreate('DWORD;DWORD;',DllStructGetPtr($tInt64))
    DllStructSetData($tInt64, 1, $nInt64)

    Return DllStructGetData($tQWord, 1)
EndFunc



Func _Integer_HiDWORD(Const $nInt64) ;-> UInt32
    Static Local $tInt64 = DllStructCreate('INT64;')
    Static Local $tQWORD = DllStructCreate('DWORD;DWORD;', DllStructGetPtr($tInt64))
    DllStructSetData($tInt64, 1, $nInt64)

    Return DllStructGetData($tQWORD, 2)
EndFunc


