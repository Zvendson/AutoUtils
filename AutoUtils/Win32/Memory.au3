#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author(s):       Zvend
 Discord(s):      Zvend#6666

 Script Functions:

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#include ".\..\DllHandles.au3"
#include ".\..\ApiErrorCodes.au3"
#include ".\Constants.au3"



; #FUNCTION# ====================================================================================================================
; Name ..........: GetModuleHandle
; Description ...: Retrieves a module handle for the specified module. The module must have been loaded by the calling process.
; Syntax ........: GetModuleHandle(Const $sModuleName)
; Parameters ....: $sModuleName         - [const] Name of module or Null
; Return values .: Success - Handle
;                : Failure - 0. Sets the @error to $AU_ERR_DLLCALL_FAILED.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: LoadLibrary, FreeLibrary
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc
; Example .......: No
; ===============================================================================================================================
Func GetModuleHandle(Const $sModuleName)
	Local $aCall = DllCall($__g_hKernelDll, "HANDLE", "GetModuleHandleW", "WSTR", $sModuleName)

	If @error Then
        Return SetError($AU_ERR_DLLCALL_FAILED, @error, 0)
	EndIf

	Return $aCall[0]
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: GetProcAddress
; Description ...: Retrieves the address of an exported function or variable from the specified dynamic-link library (DLL).
; Syntax ........: GetProcAddress()
; Parameters ....: $hModule             - [const] A handle to the DLL module that contains the function or variable.
;                  $sProcName           - [const] The function or variable name, or the function's ordinal value.
; Return values .: Success - Ptr(address of ProcName)
;                : Failure - 0. Sets the @error to $AU_ERR_DLLCALL_FAILED.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: GetModuleHandle, LoadLibrary
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getprocaddress
; Example .......: No
; ===============================================================================================================================

Func GetProcAddress(Const $hModule, Const $sProcName)
	Local $aCall = DllCall($__g_hKernelDll, "PTR", "GetProcAddress", "HANDLE", $hModule, "STR", $sProcName)

	If @error Then
        Return SetError($AU_ERR_DLLCALL_FAILED, @error, 0)
	EndIf

	Return $aCall[0]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: VirtualAlloc
; Description ...: Reserves, commits, or changes the state of a region of pages in the virtual address space of the calling
;                : process. Memory allocated by this function is automatically initialized to zero
; Syntax ........: VirtualAlloc(Const $pAddress, Const $nSize, Const $nAllocation, Const $nProtect)
; Parameters ....: $pAddress            - [const] a pointer value.
;                  $nSize               - [const] a general number value.
;                  $nAllocation         - [const] pass: $MEM_COMMIT, $MEM_RESERVE, $MEM_TOP_DOWN or $MEM_SHARED
;                  $nProtect            - [const] a general number value.
; Return values .: Success - Ptr(base address of the allocated region)
;                : Failure - 0. Sets the @error to $AU_ERR_DLLCALL_FAILED.
; Author ........: Zvend
; Modified ......:
; Remarks .......:
; Related .......: VirtualFree, VirtualAllocEx
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc
; Example .......: No
; ===============================================================================================================================
Func VirtualAlloc(Const $pAddress, Const $nSize, Const $nAllocation, Const $nProtect)
	Local $aCall = DllCall($__g_hKernelDll, "PTR", "VirtualAlloc", "PTR", $pAddress, "ULONG_PTR", $nSize, "DWORD", $nAllocation, "DWORD", $nProtect)

	If @error Then
        Return SetError($AU_ERR_DLLCALL_FAILED, @error, 0)
    EndIf

	Return $aCall[0]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: VirtualFree
; Description ...: Releases, decommits, or releases and decommits a region of pages within the virtual address space of the
;                : calling process.
; Syntax ........: VirtualFree(Const $pAddress, Const $nSize, Const $nFreeType)
; Parameters ....: $pAddress            - [const] a pointer value.
;                  $nSize               - [const] a general number value.
;                  $nFreeType           - [const] pass: $MEM_DECOMMIT or $MEM_RELEASE
; Return values .: Success - 1.
;                : Failure - 0. Sets the @error to $AU_ERR_DLLCALL_FAILED.
; Author ........: Zvend
; Modified ......:
; Remarks .......: When using $MEM_RELEASE, this parameter can additionally specify one of the following values:
;                : $nFreeType = BitOr($MEM_RELEASE, $MEM_COALESCE_PLACEHOLDERS)
;                : $nFreeType = BitOr($MEM_RELEASE, MEM_PRESERVE_PLACEHOLDER)
; Related .......: VirtualAllocEx, VirtualFreeEx
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualfree
; Example .......: No
; ===============================================================================================================================
Func VirtualFree(Const $pAddress, Const $nSize, Const $nFreeType)
	Local $aCall = DllCall($__g_hKernelDll, "BOOL", "VirtualFree", "PTR", $pAddress, "ULONG_PTR", $nSize, "DWORD", $nFreeType)

	If @error Then
        Return SetError($AU_ERR_DLLCALL_FAILED, @error, 0)
    EndIf

	Return $aCall[0]
EndFunc






