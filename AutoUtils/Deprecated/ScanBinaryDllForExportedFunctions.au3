#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author(s):       Zvend
 Discord(s):      Zvend#6666
 Created:         Sunday 14 May 2023

 Description:

 Script Functions:

 Internal Functions:

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7


#include ".\..\Vector.au3"
#include ".\..\Dll.au3"



Global $hFile = FileOpen("Test.dll", 16)
Global $dDllBinary = FileRead($hFile)
FileClose($hFile)

Global $hTestDll = _Dll_Open($dDllBinary)
If @error Then
    Exit 1
EndIf

Global $tHandle =  DllStructCreate("PTR;PTR ModuleBase;", $hTestDll)

Global $aExportTable = __Dll_GetNtHeader($dDllBinary)
If Not IsArray($aExportTable) Then
    ConsoleWrite("Couldnt load Export Table." & @CRLF)
    Exit 2
EndIf

For $i = 0 To UBound($aExportTable) - 1 Step 2
    $aExportTable[$i] = Ptr(DllStructGetData($tHandle, "ModuleBase") + $aExportTable[$i])
    ConsoleWrite($aExportTable[$i] & " = " & $aExportTable[$i + 1] & @CRLF)
Next



Func __Dll_GetNtHeader(Const $dDllBinary)
    ;Super dirty code but it was just for researching.
    ;My intention was to find out how to check if the file is really a dll.
    ;Stuff got me catched and this happened. Maybe someone can learn from it.
    ;Sorry for the var namings^^

    Local $sDllHex = Hex($dDllBinary)
    Local $nDllStart = StringInStr($sDllHex, "4D5A")
    $nDllStart = ($nDllStart + 1) / 2

    Local $tDllBinary = DllStructCreate("BYTE[" & BinaryLen($dDllBinary) & "]")
    DllStructSetData($tDllBinary, 1, BinaryMid($dDllBinary, $nDllStart))

    Local $tDosHeader = DllStructCreate($tagDOS_HEADER, DllStructGetPtr($tDllBinary))
    Local $nOffest = DllStructGetData($tDosHeader, "e_lfanew")

    Local $tNtFileHeader = DllStructCreate($tagNT_HEADER, DllStructGetPtr($tDosHeader) + $nOffest)
    Local $nNumberOfSections = DllStructGetData($tNtFileHeader, "NumberOfSections")
    Local $nCharacteristics = DllStructGetData($tNtFileHeader, "Characteristics")
    Local $nVBase = DllStructGetData($tNtFileHeader, "BaseOfData")
    Local $nExportDirRVA = DllStructGetData($tNtFileHeader, "ExportDirectory", 1)
    Local $nDataSec_ExportDirOffset = $nExportDirRVA
    ConsoleWrite("NumberOfSections = " & $nNumberOfSections & @CRLF)
    ConsoleWrite("Is Dll = " & (BitAND($nCharacteristics, 0x2000) <> 0) & @CRLF)
    ConsoleWrite("32 Bit = " & (BitAND($nCharacteristics, 0x100) <> 0) & @CRLF)

    Local $tQueueSectionHeader
    Local $bFound = 0
    Local $tSectionHeader = 0
    Local $sSectionName
    ConsoleWrite("Sections:" & @CRLF)
    For $i = 0 To $nNumberOfSections - 1
        $nOffest = DllStructGetPtr($tNtFileHeader) + DllStructGetSize($tNtFileHeader)
        $nOffest = $nOffest + $i * 0x0028 ;~ 0x0028 = SizeOf($tagSECTION_HEADER)
        $tQueueSectionHeader = DllStructCreate($tagSECTION_HEADER, $nOffest)
        $sSectionName =  DllStructGetData($tQueueSectionHeader, "Name")
        ConsoleWrite("    " & $sSectionName)
        If $sSectionName == ".rdata" Then
            $bFound = 1
            $tSectionHeader = $tQueueSectionHeader
        EndIf
    Next
    ConsoleWrite(@CRLF)

    If Not $bFound Then
        ConsoleWrite("Didnt find .rdata" & @CRLF)
        Return 0
    EndIf

    Local $nRawAddress = DllStructGetData($tSectionHeader, "PointerToRawData")

    If $nDataSec_ExportDirOffset <> 0 Then
        Local $tExportDirectory = DllStructCreate($tagEXPORT_DIRECTORY, DllStructGetPtr($tDllBinary) + $nDataSec_ExportDirOffset + $nRawAddress - $nVBase)
        Local $nDllNameRVA = $nRawAddress + DllStructGetData($tExportDirectory, "Name") - $nVBase
        Local $tDllName = DllStructCreate("CHAR Name[256]", DllStructGetPtr($tDllBinary) + $nDllNameRVA)
        ConsoleWrite("DllName = " & DllStructGetData($tDllName, 1) & @CRLF)

        Local $nAdressOfFunctions = $nRawAddress + DllStructGetData($tExportDirectory, "AddressOfFunctions") - $nVBase
        Local $nNumberOfNames        = DllStructGetData($tExportDirectory, "NumberOfNames")
        Local $nNumberOfFunctions    = DllStructGetData($tExportDirectory, "NumberOfFunctions")
        ConsoleWrite("NumberOfExports = " & $nNumberOfFunctions & @CRLF)

        Local $tagFUNC_EXPORT = "" _
            & "DWORD FunctionRVA[" & $nNumberOfFunctions &"];" _
            & "DWORD NameRVA[" & $nNumberOfNames &"];" _
            & "WORD  OrdinalRVA[" & $nNumberOfFunctions &"];"

        Local $tExportFunctions = DllStructCreate($tagFUNC_EXPORT, DllStructGetPtr($tDllBinary) + $nAdressOfFunctions)

        Local $nFuncRVA, $nFuncNameRVA, $nFuncOrdinal, $tFuncName
        Local $vecExportTable = _Vector_Init($nNumberOfFunctions * 2)
        For $i = 1 To $nNumberOfFunctions
            $nFuncRVA     = DllStructGetData($tExportFunctions, 1, $i)
            _Vector_Push($vecExportTable, $nFuncRVA)
            $nFuncNameRVA = $nRawAddress + DllStructGetData($tExportFunctions, 2, $i) - $nVBase
            $tFuncName    = DllStructCreate("CHAR[256]", $nFuncNameRVA + DllStructGetPtr($tDllBinary))
            _Vector_Push($vecExportTable, DllStructGetData($tFuncName, 1))
            ;~ For research stuff
            $nFuncOrdinal = DllStructGetData($tExportFunctions, 3, $i)
            #forceref $nFuncOrdinal
        Next

        Return _Vector_GetBuffer($vecExportTable)
    Else
        ConsoleWrite("No Exports" & @CRLF)
    EndIf
EndFunc


