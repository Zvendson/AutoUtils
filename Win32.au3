#cs════════════════╦═══════════════════╗
║ AutoIt Version   ║ 3.3.16.1          ║
╠══════════════════╬═══════════════════╣═══════════════════════════════════════╗
║ Author(s)        ║ Discord(s)        ║ E-Mail(s)                             ║
╠══════════════════╬═══════════════════╬═══════════════════════════════════════╣
║ Zvend            ║ zvend             ║ svendganske@hotmail.com               ║
╠═════════════╤════╩═══════════════════╩═══════════════════════════════════════╣
│ Description │ This is just a simplified wrapper for windows process          │
├─────────────┘ interactions with lightweight error handling. It requires that │
│ AutoIt runs as Admin when using those functions. I focus on its simplicity   │
│ here a lot to make it run faster in general since i am trying to push the    │
│ limits with my scripts but still keep everything in an API style.            │
#ce────────────────────────────────────────────────────────────────────────────┘

#include-once
#RequireAdmin
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#include ".\Integer.au3"



Global Const $__g_hWin32_Advapi32 = DllOpen("advapi32.dll")
Global Const $__g_hWin32_Kernel32 = DllOpen("kernel32.dll")

Global Const $tagWin32_SystemInfo = StringStripWS("" _ ;~ Data Index
    & "DWORD     dwOemId;"                           _ ;~ 1
    & "DWORD     dwPageSize;"                        _ ;~ 2
    & "PTR       lpMinimumApplicationAddress;"       _ ;~ 3
    & "PTR       lpMaximumApplicationAddress;"       _ ;~ 4
    & "DWORD_PTR dwActiveProcessorMask;"             _ ;~ 5
    & "DWORD     dwNumberOfProcessors;"              _ ;~ 6
    & "DWORD     dwProcessorType;"                   _ ;~ 7
    & "DWORD     dwAllocationGranularity;"           _ ;~ 8
    & "WORD      wProcessorLevel;"                   _ ;~ 9
    & "WORD      wProcessorRevision;"             , 4) ;~ 10



#cs────────────────────────────────────────────────────────────────────────────┐
│ Creates a buffer to store data that has been replaced by a x86 jmp           │
│ instruction, so it can be restored later.                                    │
│                                                                              │
│ Parameter:                                                                   │
│   Integer  $nAsmLength = 5                                                   │
│   Ptr      $pAddress   = Default                                             │
│                                                                              │
│ Returns:                                                                     │
│   Struct<JmpBuffer>                                                          │
│                                                                              │
│ Errors:                                                                      │
│   1 to 4  See 'DllStructCreate'                                              │
│   5       $nAsmLength is not an Int or lesser than 5.                        │
│                                                                              │
│ Remarks:                                                                     │
│   $nAsmLength  The length in BYTZES of the opcode it can store.              │
│   $pAddress    If provided it will create a struct at that address without   │
│                allocating extra memory.                                      │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_CreateHookBuffer($nAsmLength = 5, $pAddress = Default)
    If Not IsInt($nAsmLength) Or $nAsmLength < 5 Then
        Return SetError(5, 0, 0)
    EndIf

    Local $tBuffer = 0

    If $pAddress = Default Or $pAddress = 0 Then
        $tBuffer = DllStructCreate("ALIGN 1;BYTE Code[" & $nAsmLength & "];PTR Address;")
    Else
        $tBuffer = DllStructCreate("ALIGN 1;BYTE Code[" & $nAsmLength & "];PTR Address;", $pAddress)
    EndIf

    Return SetError(@error, @extended, $tBuffer)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Retrieves SystemInfo into an existing or new buffer.                         │
│                                                                              │
│ Parameter:                                                                   │
│   Struct<SystemInfo>  $tBuffer = Default                                     │
│                                                                              │
│ Returns:                                                                     │
│   Struct<SystemInfo>  // Success                                             │
│   0                   // Failure                                             │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│                                                                              │
│ Remarks:                                                                     │
│   $tBuffer  If 'Default' it will create its own buffer using                 │
│             '$tagWin32_SystemInfo'.                                          │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_GetSystemInfo($tBuffer = Default)
    If $tBuffer = Default Then
        $tBuffer = DllStructCreate($tagWin32_SystemInfo)
    EndIf

    DllCall($__g_hWin32_Kernel32, "NONE", "GetSystemInfo", "STRUCT*", $tBuffer)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    Return $tBuffer
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Opens a process with specified access rights and returns a handle to the     │
│ process.                                                                     │
│                                                                              │
│ Parameter:                                                                   │
│   Integer  $nProcessId                                                       │
│   Integer  $nAccess    = Default                                             │
│                                                                              │
│ Returns:                                                                     │
│   Handle                                                                     │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       $nProcessId is not an id of a process.                             │
│   7       $nAccess is not an integer.                                        │
│                                                                              │
│ Remarks:                                                                     │
│   $nAccess       If 'Default' it will be set to 'PROCESS_ALL_ACCESS'.        │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_OpenProcess($nProcessId, $nAccess = Default)
    If $nAccess = Default Then
        $nAccess = 0x1F0FFF ;~ PROCESS_ALL_ACCESS
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "HANDLE", "OpenProcess", "DWORD", $nAccess, "BOOL", 0, "DWORD", $nProcessId)
    If @error Or $aDllCall[0] = 0 Then
         ;~ Handles are returned as Ptr types. Just being consistent here.
        Return SetError(@error, 0, Ptr(0))
    EndIf

    Return $aDllCall[0]
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Closes an open object handle.                                                │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hHandle                                                           │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       $hHandle is invalid.                                               │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_CloseHandle($hHandle)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "CloseHandle", "HANDLE", $hHandle)

    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return True
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Retrieves the process identifier of the targeted process.                    │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer   // ProcessId of $hProcess                                        │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       $hProcess is not a handle.                                         │
│   7       $hProcess is invalid.                                              │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_GetProcessId($hProcess)
    If $hProcess = 0 Then
        Return SetError(6, 0, 0)
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "DWORD", "GetProcessId", "HANDLE", $hProcess)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = 0 Then
        Return SetError(7, 0, 0)
    EndIf

    Return $aDllCall[0]
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Terminates the targeted process and all of its threads.                      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Integer  $nExitCode  = 0                                                   │
│   Integer  $nWait      = 0                                                   │
│   Integer  $nProcessId = Default                                             │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       Failed to retrieve ProcessId from $hProcess.                       │
│                                                                              │
│ Remarks:                                                                     │
│   $nWait       The time in ms to wait for the process to terminate.          │
│   $nProcessId  If 'Default' will call '_Win32_GetProcessId' to get the PID.  │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_TerminateProcess($hProcess, $nExitCode = 0, $nWait = 0, $nProcessId = Default)
    If $nWait > 0 And $nProcessId = Default Then
        $nProcessId = _Win32_GetProcessId($hProcess)

        If @error Or $nProcessId = 0 Then
            Return SetError(6, 0, False)
        EndIf
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "TerminateProcess", "HANDLE", $hProcess, "UINT", $nExitCode)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $nWait > 0 Then
        ProcessWaitClose($nProcessId, $nWait)
    EndIf

    Return $aDllCall[0]
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads a Pointer from the targeted process at the specified address.          │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Ptr                                                                        │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadPointer($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "PTR*", 0, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, Ptr(0))
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, Ptr(0))
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 1 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an 8 bit Integer.                                   │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer   // Containing value will be an Int8. Means 0xFF in an AutoIt     │
│             // Integer will become -1.                                       │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadInt8($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "BYTE*", 0, "DWORD", 0x1, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0)
    EndIf

    Return SetExtended($aDllCall[5], _Integer_Int8($aDllCall[3]))
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 2 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an 16 bit Integer.                                  │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer   // Containing value will be an Int16. Means 0xFFFF in an AutoIt  │
│             // Integer will become -1.                                       │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadInt16($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "SHORT*", 0, "DWORD", 0x2, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0)
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 4 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an 32 bit Integer.                                  │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer                                                                    │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadInt32($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "INT*", 0, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0)
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 8 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an 64 bit Integer.                                  │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer                                                                    │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadInt64($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "INT64*", 0, "DWORD", 0x8, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, Int(0, 2))
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, Int(0, 2))
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 1 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an unsigned 8 bit Integer.                          │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer   // Containing value will be an UInt8. Means -1 in an AutoIt      │
│             // Integer will become 0xFF.                                     │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadUInt8($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "BYTE*", 0, "DWORD", 0x1, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0)
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 2 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an unsigned 16 bit Integer.                         │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer   // Containing value will be an UInt16. Means -1 in an AutoIt     │
│             // Integer will become 0xFFFF.                                   │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadUInt16($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "WORD*", 0, "DWORD", 0x2, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0)
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 4 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an unsigned 32 bit Integer.                         │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer                                                                    │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadUInt32($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "UINT*", 0, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0)
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 8 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an unsigned 64 bit Integer.                         │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Integer                                                                    │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadUInt64($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "UINT64*", 0, "DWORD", 0x8, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, Int(0, 2))
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, Int(0, 2))
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 4 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as a Float.                                            │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Double   // Value is a Float - Native AutoIt has no 4 BYTES Float type.    │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadFloat($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "FLOAT*", 0, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0.0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0.0)
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads 8 BYTE from the targeted process at the specified address and returns  │
│ the value interpreted as an Double.                                          │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Double                                                                     │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadDouble($hProcess, $mAddress)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "DOUBLE*", 0, "DWORD", 0x8, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0.0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0.0)
    EndIf

    Return SetExtended($aDllCall[5], $aDllCall[3])
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads any length of BYTES from the targeted process at the specified address │
│ and returns it as Binary.                                                    │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nLength                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Binary                                                                     │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│   7       $nLength is not an integer.                                        │
│   8       $nLength is not bigger than 0.                                     │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadBuffer($hProcess, $mAddress, $nLength)
    If Not IsInt($nLength) Then
        Return SetError(7, 0, Binary(0x0))
    EndIf

    If $nLength < 1 Then
        Return SetError(8, 0, Binary(0x0))
    EndIf

    Local $tBuffer = DllStructCreate("BYTE[" & $nLength & "];")

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nLength, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, DllStructGetData($tBuffer, 1))
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, DllStructGetData($tBuffer, 1))
    EndIf

    Return SetExtended($aDllCall[5], DllStructGetData($tBuffer, 1))
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads a Struct from the targeted process at the specified address.           │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   String   $tagSTRUCT                                                        │
│   Integer  $nSize     = Default                                              │
│                                                                              │
│ Returns:                                                                     │
│   Struct   // Success                                                        │
│   0        // Failure                                                        │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│   7       Could not create a Struct from $tagSTRUCT.                         │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
│   $nSize     If 'Default' it will call 'DllStructGetSize' to get the size.   │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadStruct($hProcess, $mAddress, $tagSTRUCT, $nSize = Default)
    Local $tBuffer = DllStructCreate($tagSTRUCT)
    If @error Then
        Return SetError(7, 0, 0)
    EndIf

    If $nSize = Default Then
        $nSize = DllStructGetSize($tBuffer)
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nSize, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, 0)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, 0)
    EndIf

    Return SetExtended($aDllCall[5], $tBuffer)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads from the targeted process at the specified address and copies the data │
│ to the provided struct.                                                      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle          $hProcess                                                  │
│   Ptr             $mAddress                                                  │
│   Struct   ByRef  $tBuffer                                                   │
│   Integer         $nSize    = Default                                        │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│   7       $tBuffer is not a Struct.                                          │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being read.                       │
│   $nSize     If 'Default' it will call 'DllStructGetSize' to get the size.   │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadToStruct($hProcess, $mAddress, ByRef $tBuffer, $nSize = Default)
    If Not IsDllStruct($tBuffer) Then
        Return SetError(7, 0, False)
    EndIf

    If $nSize = Default Then
        $nSize = DllStructGetSize($tBuffer)
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nSize, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads a CHAR[] (CHAR = 1 BYTES) from the targeted process at the specified   │
│ address.                                                                     │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nLength                                                          │
│                                                                              │
│ Returns:                                                                     │
│   String                                                                     │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│   7       $nLength is not an integer                                         │
│   8       $nLength is not bigger than 0.                                     │
│                                                                              │
│ Remarks:                                                                     │
│   $nLength  Should include termination char. E.g. "Hi!" = "Hi!\0" = 4 BYTES. │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadStringA($hProcess, $mAddress, $nLength)
    If Not IsInt($nLength) Then
        Return SetError(7, 0, "")
    EndIf

    If $nLength < 1 Then
        Return SetError(8, 0, "")
    EndIf

    Local $tBuffer = DllStructCreate("CHAR[" & $nLength & "];")
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nLength, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, "")
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, "")
    EndIf

    Return SetExtended($aDllCall[5], DllStructGetData($tBuffer, 1))
EndFunc




#cs────────────────────────────────────────────────────────────────────────────┐
│ Reads a WCHAR[] (WCHAR = 2 BYTES) from the targeted process at the specified │
│ address.                                                                     │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nLength                                                          │
│                                                                              │
│ Returns:                                                                     │
│   String                                                                     │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'ReadProcessMemory' has failed.                                    │
│   7       $nLength is not an integer                                         │
│   8       $nLength is not bigger than 0.                                     │
│                                                                              │
│ Remarks:                                                                     │
│   $nLength  Should include termination char. $nLength gets multiplied by 2.  │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ReadStringW($hProcess, $mAddress, $nLength)
    If Not IsInt($nLength) Then
        Return SetError(7, 0, "")
    EndIf

    If $nLength < 1 Then
        Return SetError(8, 0, "")
    EndIf

    Local $tBuffer = DllStructCreate("WCHAR[" & $nLength & "];")
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "ReadProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nLength * 0x2, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, "")
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, "")
    EndIf

    Return SetExtended($aDllCall[5], DllStructGetData($tBuffer, 1))
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Pointer to the targeted process at the specified address.    │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│   Ptr     $mPointer                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WritePointer($hProcess, $mAddress, $mPointer)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "PTR*", $mPointer, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Int8 to the targeted process at the specified address.       │
│ The Integer will be cast to a 8 bit Integer.                                 │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteInt8($hProcess, $mAddress, $nValue = 0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "BYTE*", $nValue, "DWORD", 0x1, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Int16 to the targeted process at the specified address.      │
│ The Integer will be cast to a 16 bit Integer.                                │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteInt16($hProcess, $mAddress, $nValue = 0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "SHORT*", $nValue, "DWORD", 0x2, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Integer to the targeted process at the specified address.    │
│ The Integer will be cast to a 32 bit Integer.                                │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteInt32($hProcess, $mAddress, $nValue = 0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "INT*", $nValue, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Int64 to the targeted process at the specified address.      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteInt64($hProcess, $mAddress, $nValue = 0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "INT64*", $nValue, "DWORD", 0x8, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided UInt8 to the targeted process at the specified address.      │
│ The Integer will be cast to an unsigned 8 bit Integer.                       │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteUInt8($hProcess, $mAddress, $nValue = 0)
    Local $bCall = _Win32_WriteInt8($hProcess, $mAddress, $nValue)
    Return SetError(@error, @extended, $bCall)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided UInt16 to the targeted process at the specified address.     │
│ The Integer will be cast to an unsigned 16 bit Integer.                      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteUInt16($hProcess, $mAddress, $nValue = 0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "USHORT*", $nValue, "DWORD", 0x2, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Integer to the targeted process at the specified address.    │
│ The Integer will be cast to an unsigned 32 bit Integer.                      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteUInt32($hProcess, $mAddress, $nValue = 0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "UINT*", $nValue, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided UInt64 to the targeted process at the specified address.     │
│ The Integer will be cast to an unsigned 64 bit Integer.                      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nValue   = 0                                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteUInt64($hProcess, $mAddress, $nValue = 0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "UINT64*", $nValue, "DWORD", 0x8, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Float to the targeted process at the specified address.      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│   Double  $fValue   = 0.0                                                    │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteFloat($hProcess, $mAddress, $fValue = 0.0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "FLOAT*", $fValue, "DWORD", 0x4, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Double to the targeted process at the specified address.     │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│   Ptr     $mAddress                                                          │
│   Double  $fValue   = 0.0                                                    │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteDouble($hProcess, $mAddress, $fValue = 0.0)
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "DOUBLE*", $fValue, "DWORD", 0x8, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Binary to the targeted process at the specified address.     │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Binary   $dBinary                                                          │
│   Integer  $nBinLength = Default                                             │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│   7       $dBinary is not a Binary type.                                     │
│                                                                              │
│ Remarks:                                                                     │
│   @extended    Is set to the number of BYTES being written.                  │
│   $nBinLength  If 'Default' it will call 'BinaryLen' to get the length.      │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteBuffer($hProcess, $mAddress, $dBinary, $nBinLength = Default)
    If Not IsBinary($dBinary) Then
        Return SetError(7, 0, False)
    EndIf

    If $nBinLength = Default Then
        $nBinLength = BinaryLen($dBinary)
    EndIf

    Local $tBuffer = DllStructCreate("BYTE[" & $nBinLength & "];")
    DllStructSetData($tBuffer, 1, $dBinary)

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nBinLength, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided Struct to the targeted process at the specified address.     │
│                                                                              │
│ Parameter:                                                                   │
│   Handle                $hProcess                                            │
│   Ptr                   $mAddress                                            │
│   Struct   Const ByRef  $tBuffer                                             │
│   Integer               $nSize    = Default                                  │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│   7       $tBuffer is not a Struct type.                                     │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
│   $nSize     If 'Default' it will call 'DllStructGetSize' to get the size.   │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteStruct($hProcess, $mAddress, Const ByRef $tBuffer, $nSize = Default)
    If Not IsDllStruct($tBuffer) Then
        Return SetError(7, 0, False)
    EndIf

    If $nSize = Default Then
        $nSize = DllStructGetSize($tBuffer)
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nSize, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided data from the buffer address (AutoIt Memory) to the targeted │
│ process at the specified address.                                            │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Ptr      $pBuffer                                                          │
│   Integer  $nSize                                                            │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│   7       $pBuffer is not a Ptr.                                             │
│   8       $nSize is not an integer.                                          │
│   9       $nSize needs to be atleast 1 or bigger.                            │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteFromBuffer($hProcess, $mAddress, $pBuffer, $nSize)
    If Not ( IsInt($pBuffer) Or IsPtr($pBuffer) ) Then
        Return SetError(7, 0, False)
    EndIf

    If Not IsInt($nSize) Then
        Return SetError(8, 0, False)
    EndIf

    If $nSize < 1 Then
        Return SetError(9, 0, False)
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "PTR*", $pBuffer, "DWORD", $nSize, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided string to the targeted process at the specified address.     │
│ This function cares about zero termination if $bZeroTermination is 'True'.   │
│ The String will be interpreted in a Char Array (1 BYTE per char).            │
│                                                                              │
│ Parameter:                                                                   │
│   Handle                $hProcess                                            │
│   Ptr                   $mAddress                                            │
│   String   Const ByRef  $sString                                             │
│   Integer               $nStrLength       = Default                          │
│   Bool                  $bZeroTermination = True                             │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│   7       $sString is not a String.                                          │
│                                                                              │
│ Remarks:                                                                     │
│   @extended          Is set to the number of BYTES being written.            │
│   $nStrLength        If 'Default' it will call 'StringLen'.                  │
│   $bZeroTermination  If 'True' it will add +1 to length for \0 termination.  │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteStringA($hProcess, $mAddress, Const ByRef $sString, $nStrLength = Default, $bZeroTermination = True)
    If Not IsString($sString) Then
        Return SetError(7, 0, False)
    EndIf

    If $nStrLength = Default Then
        $nStrLength = StringLen($sString) + 1
    EndIf

    If $bZeroTermination Then
        $nStrLength += 1
    EndIf

    Local $tBuffer = DllStructCreate("CHAR[" & $nStrLength & "];")
    DllStructSetData($tBuffer, 1, $sString)

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nStrLength, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes provided string to the targeted process at the specified address.     │
│ This function cares about zero termination if $bZeroTermination is 'True'.   │
│ The String will be interpreted in a WChar Array (2 BYTE per char).           │
│                                                                              │
│ Parameter:                                                                   │
│   Handle                $hProcess                                            │
│   Ptr                   $mAddress                                            │
│   String   Const ByRef  $sString                                             │
│   Integer               $nStrLength       = Default                          │
│   Bool                  $bZeroTermination = True                             │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│   7       $sString is not a String.                                          │
│                                                                              │
│ Remarks:                                                                     │
│   @extended          Is set to the number of BYTES being written.            │
│   $nStrLength        If 'Default' it will call 'StringLen'.                  │
│   $bZeroTermination  If 'True' it will add +1 to length for \0 termination.  │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteStringW($hProcess, $mAddress, Const ByRef $sString, $nStrLength = Default, $bZeroTermination = True)
    If Not IsString($sString) Then
        Return SetError(7, 0, False)
    EndIf

    If $nStrLength = Default Then
        $nStrLength = StringLen($sString) + 1
    EndIf

    If $bZeroTermination Then
        $nStrLength += 1
    EndIf

    Local $tBuffer = DllStructCreate("WCHAR[" & $nStrLength & "];")
    DllStructSetData($tBuffer, 1, $sString)

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tBuffer, "DWORD", $nStrLength * 0x2, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes a block of memory to zero to the targeted process at the specified    │
│ address.                                                                     │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Ptr      $mAddress                                                         │
│   Integer  $nLength                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'WriteProcessMemory' has failed.                                   │
│   7       $nLength is not an integer.                                        │
│   8       $nLength needs to be atleast 1 or bigger.                          │
│                                                                              │
│ Remarks:                                                                     │
│   @extended  Is set to the number of BYTES being written.                    │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ZeroMemory($hProcess, $mAddress, $nLength)
    If Not IsInt($nLength) Then
        Return SetError(7, 0, False)
    EndIf

    If $nLength < 1 Then
        Return SetError(8, 0, False)
    EndIf

    Local $tZeroData = DllStructCreate("BYTE[" & $nLength & "];")
    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "WriteProcessMemory", "HANDLE", $hProcess, "PTR", $mAddress, "STRUCT*", $tZeroData, "DWORD", $nLength, "DWORD", 0)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return SetExtended($aDllCall[5], True)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes a block of memory to zero in this AutoIt process of the current       │
│ script.                                                                      │
│                                                                              │
│ Parameter:                                                                   │
│   Ptr/Struct  $vAddress                                                      │
│   Integer     $nLength                                                       │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       $nLength is not an integer.                                        │
│   7       $nLength needs to be atleast 1 or bigger.                          │
│   8       $vAddress is not a Struct nor a Ptr.                               │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_ZeroAutoItMemory($vAddress, $nLength)
    If Not IsInt($nLength) Then
        Return SetError(6, 0, False)
    EndIf

    If $nLength < 1 Then
        Return SetError(7, 0, False)
    EndIf

    If IsDllStruct($vAddress) Then
        DllCall($__g_hWin32_Kernel32, "NONE", "RtlSecureZeroMemory", "STRUCT*", $vAddress, "DWORD", $nLength)

    ElseIf IsInt($vAddress) Or IsPtr($vAddress) Then
        DllCall($__g_hWin32_Kernel32, "NONE", "RtlSecureZeroMemory", "PTR", $vAddress, "DWORD", $nLength)

    Else
        Return SetError(8, 0, False)

    EndIf

    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    Return True
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reserves, commits, or changes the state of a region of memory within the     │
│ virtual address space of a specified process. The function initializes the   │
│ memory it allocates to zero.                                                 │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Integer  $nLength                                                          │
│   Integer  $nAllocType = Default                                             │
│   Integer  $nProtect   = Default                                             │
│                                                                              │
│ Returns:                                                                     │
│   Ptr<$nLength>                                                              │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'VirtualAllocEx' has failed.                                       │
│   7       $nLength is not an integer.                                        │
│   8       $nLength needs to be atleast 1 or bigger.                          │
│                                                                              │
│ Remarks:                                                                     │
│   $nAllocType  If 'Default' it will be set to 'MEM_COMMIT'.                  │
│   $nProtect    If 'Default' it will be set to 'PAGE_EXECUTE_READWRITE'.      │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_VirtualAllocEx($hProcess, $nLength, $nAllocType = Default, $nProtect = Default)
    If Not IsInt($nLength) Then
        Return SetError(7, 0, Ptr(0))
    EndIf

    If $nLength < 1 Then
        Return SetError(8, 0, Ptr(0))
    EndIf

    If $nAllocType = Default Then
        $nAllocType = 0x1000 ;~ MEM_COMMIT
    EndIf

    If $nProtect = Default Then
        $nProtect = 0x40 ;~ PAGE_EXECUTE_READWRITE
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "PTR", "VirtualAllocEx", "HANDLE", $hProcess, "PTR", 0, "SIZE_T", $nLength, "DWORD", $nAllocType, "DWORD", $nProtect)
    If @error Then
        Return SetError(@error, 0, Ptr(0))
    EndIf

    If $aDllCall[0] = 0 Then
        Return SetError(6, 0, Ptr(0))
    EndIf

    Return $aDllCall[0]
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Reserves, commits, or changes the state of a region of memory within the     │
│ virtual address space of a specified process. The function initializes the   │
│ memory it allocates to zero.                                                 │
│                                                                              │
│ Parameter:                                                                   │
│   Handle   $hProcess                                                         │
│   Integer  $nLength                                                          │
│   Integer  $nFreeType = Default                                              │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1 to 5  See 'DllCall'                                                      │
│   6       'VirtualFreeEx' has failed.                                        │
│                                                                              │
│ Remarks:                                                                     │
│   $nFreeType  If 'Default' it will be set to 'MEM_RELEASE'.                  │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_VirtualFreeEx($hProcess, $mAddress, $nFreeType = Default)
    If $nFreeType = Default Then
        $nFreeType = 0x8000 ;~ MEM_RELEASE
    EndIf

    Local $aDllCall = DllCall($__g_hWin32_Kernel32, "BOOL", "VirtualFreeEx", "HANDLE", $hProcess, "PTR", $mAddress, "SIZE_T", 0, "DWORD", 0x8000)
    If @error Then
        Return SetError(@error, 0, False)
    EndIf

    If $aDllCall[0] = False Then
        Return SetError(6, 0, False)
    EndIf

    Return True
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Checks if targeted process is running in admin mode.                         │
│                                                                              │
│ Parameter:                                                                   │
│   Handle  $hProcess                                                          │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1  'OpenProcessToken' call failed.                                         │
│   2  Token is invalid.                                                       │
│   3  'GetTokenInformation' call failed.                                      │
│   4  Token type is not elevated.                                             │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_IsElevated($hProcess)
    Local $aDllCall = DllCall($__g_hWin32_Advapi32, 'BOOL', 'OpenProcessToken', 'HANDLE', $hProcess, 'dword', 0x0008, 'HANDLE*', 0)

    If @error Or Not $aDllCall[0] Then
        Return SetError(1, 0, False)
    EndIf

    Local $hToken = $aDllCall[3]
    If Not $hToken Then
        Return SetError(2, 0, False)
    EndIf

    $aDllCall = DllCall($__g_hWin32_Advapi32, 'BOOL', 'GetTokenInformation', 'HANDLE', $hToken, 'UINT', 20, 'UINT*', 0, 'UINT', 4, 'UINT*', 0) ; TOKEN_ELEVATION

    If @error Or Not $aDllCall[0] Then
        _Win32_CloseHandle($hToken)
        Return SetError(3, 0, False)
    EndIf

    Local $nElev = $aDllCall[3]

    $aDllCall = DllCall($__g_hWin32_Advapi32, 'BOOL', 'GetTokenInformation', 'HANDLE', $hToken, 'UINT', 18, 'UINT*', 0, 'UINT', 4, 'UINT*', 0) ; TOKEN_ELEVATION_TYPE

    If @error Or Not $aDllCall[0] Then
        _Win32_CloseHandle($hToken)
        Return SetError(4, 0, False)
    EndIf

    _Win32_CloseHandle($hToken)

    Return SetExtended($aDllCall[0] - 1, $nElev > 0)
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Writes a JMP instruction for the targeted process at the targeted address to │
│ the trampoline address. It will fill the rest of the overwritten opcodes     │
│ with NOP instructions. Untested in x64 bit environment.                      │
│                                                                              │
│ Parameter:                                                                   │
│   Handle          $hProcess                                                  │
│   Ptr             $mTarget                                                   │
│   Ptr             $mTrampoline                                               │
│   Struct   ByRef  $tHookBuffer                                               │
│   Integer         $nAsmLength  = Default                                     │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1   $tHookBuffer is not a hookbuffer.                                      │
│   2   '_Win32_ReadToStruct' failed to fill the $tHookBuffer                  │
│   3   Hook could not be written.                                             │
│                                                                              │
│ Remarks:                                                                     │
│   $nAsmLength  If 'Default' it will be set to suit the size of $tHookBuffer. │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_WriteHook($hProcess, $mTarget, $mTrampoline, ByRef $tHookBuffer, $nAsmLength = Default)
    If Not IsDllStruct($tHookBuffer) Then
        Return SetError(1, 0, False)
    EndIf

    If $nAsmLength = Default Then
        $nAsmLength = DllStructGetSize($tHookBuffer) - 0x4
    EndIf

    If Not _Win32_ReadToStruct($hProcess, $mTarget, $tHookBuffer, $nAsmLength) Then
        Return SetError(2, 0, False)
    EndIf

    DllStructSetData($tHookBuffer, 2, $mTarget)

    Local $nNops = $nAsmLength - 0x5

    Local $tagJMP = "ALIGN 1;BYTE jmp;PTR rva;"
    If $nNops > 0 Then
        $tagJMP &= "BYTE[" & $nNops & "];"
    EndIf

    Local $tJmpData = DllStructCreate($tagJMP)
    DllStructSetData($tJmpData, 1, 0xE9)
    DllStructSetData($tJmpData, 2, $mTrampoline - $mTarget - 0x0005)

    If $nNops > 0 Then

        For $i = 1 To $nNops
            DllStructSetData($tJmpData, 3, 0x90, $i)
        Next

    EndIf

    If Not _Win32_WriteStruct($hProcess, $mTarget, $tJmpData, $nAsmLength) Or @error Then
        Return SetError(3, 0, False)
    EndIf

    Return True
EndFunc



#cs────────────────────────────────────────────────────────────────────────────┐
│ Restores a previously installed Hook stored in $tHookBuffer.                 │
│ Untested in x64 bit environment.                                             │
│                                                                              │
│ Parameter:                                                                   │
│   Handle         $hProcess                                                   │
│   Struct  ByRef  $tHookBuffer                                                │
│                                                                              │
│ Returns:                                                                     │
│   Bool   // Success or Failure                                               │
│                                                                              │
│ Errors:                                                                      │
│   1  $tHookBuffer is not a hookbuffer.                                       │
│   2  '_Win32_ReadToStruct' failed to fill the $tHookBuffer                   │
│   3  Hook could not be written.                                              │
│                                                                              │
│ Remarks:                                                                     │
│   $nAsmLength  If 'Default' it will be set to suit the size of $tHookBuffer. │
#ce────────────────────────────────────────────────────────────────────────────┘
Func _Win32_RestoreHook($hProcess, ByRef $tHookBuffer)
    If Not IsDllStruct($tHookBuffer) Then
        Return SetError(1, 0, False)
    EndIf

    Local $mAddress = DllStructGetData($tHookBuffer, 2)
    If Not $mAddress And Not ( IsPtr($mAddress) Or IsInt($mAddress) ) Then
        Return SetError(2, 0, False)
    EndIf

    If Not _Win32_WriteBuffer($hProcess, $mAddress, DllStructGetData($tHookBuffer, 1)) Then
        Return SetError(3, 0, False)
    EndIf

    Return True
EndFunc



