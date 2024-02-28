#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author(s):       Zvend
 Discord(s):      zvend

 Script Functions:
    Int8(Const $nInt)
    Int16(Const $nInt)
    Int32(Const $nInt)
    Int64(Const $nInt)
    UInt8(Const $nInt)
    UInt16(Const $nInt)
    UInt32(Const $nInt)
    UInt64(Const $nInt)
    BYTE(Const $nInt)
    WORD(Const $nInt)
    DWORD(Const $nInt)
    QWORD(Const $nInt)
    LoBYTE(Const $nInt16)
    HiBYTE(Const $nInt16)
    LoWORD(Const $nInt32)
    HiWORD(Const $nInt32)
    LoDWORD(Const $nInt64)
    HiDWORD(Const $nInt64)

 Description:
    Simple and very readable Integer to Integer Converter.

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include <WinAPIConv.au3>



Func Int8($nInt)
    $nInt = LoBYTE($nInt)
    Return $nInt - 0x100 * BitShift($nInt, 7)
EndFunc



Func Int16($nInt)
    $nInt = LoWORD($nInt)
    Return $nInt - 0x10000 * BitShift($nInt, 15)
EndFunc



Func Int32(Const $nInt)
    Return Int($nInt, 1)
EndFunc



Func Int64(Const $nInt)
    Return Int($nInt, 2)
EndFunc



Func UInt8(Const $nInt)
    Static Local $tData = DllStructCreate('BYTE;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func UInt16(Const $nInt)
    Static Local $tData = DllStructCreate('USHORT;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func UInt32(Const $nInt)
    Static Local $tData = DllStructCreate('UINT;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func UInt64(Const $nInt)
    Static Local $tData = DllStructCreate('UINT64;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func BYTE(Const $nInt)
    Return UInt8($nInt)
EndFunc



Func WORD(Const $nInt)
    Static Local $tData = DllStructCreate('WORD;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func DWORD(Const $nInt)
    Static Local $tData = DllStructCreate('DWORD;')
    DllStructSetData($tData, 1, $nInt)

    Return DllStructGetData($tData, 1)
EndFunc



Func QWORD(Const $nInt)
    Return UInt64($nInt)
EndFunc



Func LoBYTE(Const $nInt16)
    Return BitAND($nInt16, 0xFF)
EndFunc



Func HiBYTE(Const $nInt16)
    Return BitAND(BitShift($nInt16, 8), 0xFF)
EndFunc



Func LoWORD(Const $nInt32)
    Return BitAND($nInt32, 0xFFFF)
EndFunc



Func HiWORD(Const $nInt32)
    Return BitShift($nInt32, 16)
EndFunc



Func LoDWORD(Const $nInt64)
    Static Local $tInt64 = DllStructCreate('INT64;')
    Static Local $tQWord = DllStructCreate('DWORD;DWORD;',DllStructGetPtr($tInt64))
    DllStructSetData($tInt64, 1, $nInt64)

    Return DllStructGetData($tQWord, 1)
EndFunc



Func HiDWORD(Const $nInt64)
    Static Local $tInt64 = DllStructCreate('INT64;')
    Static Local $tQWORD = DllStructCreate('DWORD;DWORD;', DllStructGetPtr($tInt64))
    DllStructSetData($tInt64, 1, $nInt64)

    Return DllStructGetData($tQWORD, 2)
EndFunc


