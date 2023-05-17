#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

;For storing loaded modules (Internal use)
#include ".\Vector.au3"



; #INDEX# =======================================================================================================================
; Title .........: Dll
; TAutoIt Version: 3.3.16.1
; Description ...: A 32Bit Dll loader that only needs the binarystrings of your dll file. Isuggest to compress them before
; ...............: embedding them in AutoIt.
; Author(s) .....: Zvend
; Dll ...........: kernel32.dll
; Discord .......: Zvend#6666
; AutoIt Profile : https://www.autoitscript.com/forum/profile/116023-zvend/
; Created .......: Saturday 14 May 2023
; ===============================================================================================================================



; #CURRENT# =====================================================================================================================
; _Dll_Close
; _Dll_CloseAll
; _Dll_GetModuleExist
; _Dll_GetProcAddress
; _Dll_IsInitialized
; _Dll_Open
; _Dll_Shutdown
; _Dll_StartUp
; ===============================================================================================================================



; #INTERNAL_USE_ONLY# ===========================================================================================================
Global Const $tagINTERNAL_DOS_HEADER = "" _
    & "WORD  e_magic;" _
    & "WORD  e_cblp;" _
    & "WORD  e_cp;" _
    & "WORD  e_crlc;" _
    & "WORD  e_cparhdr;" _
    & "WORD  e_minalloc;" _
    & "WORD  e_maxalloc;" _
    & "WORD  e_ss;" _
    & "WORD  e_sp;" _
    & "WORD  e_csum;" _
    & "WORD  e_ip;" _
    & "WORD  e_cs;" _
    & "WORD  e_lfarlc;" _
    & "WORD  e_ovno;" _
    & "WORD  e_res;" _
    & "WORD  unk0022[3];" _
    & "WORD  e_oemid;" _
    & "WORD  e_oeminfo;" _
    & "WORD  e_res2;" _
    & "WORD  unk002A[9];" _
    & "DWORD e_lfanew;"



Global Const $tagINTERNAL_NT_HEADER = "" _
    & "DWORD Signature;" _
    & "WORD  Machine;" _
    & "WORD  NumberOfSections;" _
    & "DWORD TimeDateStamp;" _
    & "DWORD PointerToSymbolTable;" _
    & "DWORD NumberOfSymbols;" _
    & "WORD  SizeOfOptionalHeader;" _
    & "WORD  Characteristics;" _
    & "WORD  Magic;" _
    & "BYTE  MajorLinkerVersion;" _
    & "BYTE  MinorLinkerVersion;" _
    & "DWORD SizeOfCode;" _
    & "DWORD SizeOfInitializedData;" _
    & "DWORD SizeOfUninitializedData;" _
    & "DWORD AddressOfEntryPoint;" _
    & "DWORD BaseOfCode;" _
    & "DWORD BaseOfData;" _
    & "DWORD ImageBase;" _
    & "DWORD SectionAlignment;" _
    & "DWORD FileAlignment;" _
    & "WORD  MajorOperatingSystemVersion;" _
    & "WORD  MinorOperatingSystemVersion;" _
    & "WORD  MajorImageVersion;" _
    & "WORD  MinorImageVersion;" _
    & "WORD  MajorSubsystemVersion;" _
    & "WORD  MinorSubsystemVersion;" _
    & "DWORD Win32VersionValue;" _
    & "DWORD SizeOfImage;" _
    & "DWORD SizeOfHeaders;" _
    & "DWORD CheckSum;" _
    & "WORD  Subsystem;" _
    & "WORD  DllCharacteristics;" _
    & "DWORD SizeOfStackReserve;" _
    & "DWORD SizeOfStackCommit;" _
    & "DWORD SizeOfHeapReserve;" _
    & "DWORD SizeOfHeapCommit;" _
    & "DWORD LoaderFlags;" _
    & "DWORD NumberOfRvaAndSizes;" _
    & "DWORD ExportDirectory[2];" _ ;=> DWORD VirtualAddress;DWORD Size;
    & "DWORD ImportDirectory[2];" _
    & "DWORD ResourceDirectory[2];" _
    & "DWORD ExceptionDirectory[2];" _
    & "DWORD SecurityDirectory[2];" _
    & "DWORD RelocationDirectory[2];" _
    & "DWORD DebugDirectory[2];" _
    & "DWORD ArchitectureDirectory[2];" _
    & "DWORD Reserved[2];" _
    & "DWORD TLSDirectory[2];" _
    & "DWORD ConfigurationDirectory[2];" _
    & "DWORD BoundDirectory[2];" _
    & "DWORD ImportAddressDirectory[2];" _
    & "DWORD DelayImportDirectory[2];" _
    & "DWORD NETMetaDataDirectory[2];" _
    & "DWORD[2];"
; ===============================================================================================================================





; #VARIABLES# ===================================================================================================================

;Internal Use Only

;Kernerl32.dll reference for calling WinAPI functions
Global $__g_hDll_KernelDll = DllOpen("kernel32.dll")

;@private    Holding state if Dll API is initialized or not.
Global $__g_bDll_DllSetup     = 0

;Vector storing Module References through using _Dll_Open.
Global $__g_vecDll_DllHandles = 0

;Allocated Address range storing the assembly payload.
Global $__g_pDll_DllLoadBase  = 0

;Address within the LoadBase to internally call __Dll_LoadLibrary.
Global $__g_pDll_DllLoad      = 0

;Address within the LoadBase to internally call __Dll_GetProcAddress.
Global $__g_pDll_DllGetAddr   = 0

;Address within the LoadBase to internally call __Dll_FreeLibrary.
Global $__g_pDll_DllFree      = 0

;Address from the original WinAPI LoadLibraryA function.
Global $__g_pDll_LoadLib      = 0

;Address from the original WinAPI GetProcAddress function.
Global $__g_pDll_GetProcAddr  = 0
; ===============================================================================================================================



; #CONSTANTS# ===================================================================================================================

;@Error codes used
Global Enum _
    $DLLERR_NONE            , _
    $DLLERR_INVALID_BINARY  , _
    $DLLERR_BINARY_NOT_MZ   , _
    $DLLERR_BINARY_NOT_32BIT, _
    $DLLERR_BINARY_NOT_DLL  , _
    $DLLERR_ALLOC_MEMORY    , _
    $DLLERR_FREE_MEMORY     , _
    $DLLERR_LOAD_LIBRARY    , _
    $DLLERR_GETPROCADDRESS  , _
    $DLLERR_NOT_INITIALIZED , _
    $DLLERR_INVALID_HANDLE  , _
    $DLLERR_INVALID_STRING  , _
    $DLLERR_DLLCALL_FAILED  , _ ;Sets @extended to the DllCall() error
    $DLLERR_COUNT


;Internal Use Only

Global Const $__DLL_DOSHEADER_SIZE = DllStructGetSize(DllStructCreate($tagINTERNAL_DOS_HEADER))

Global Const $__DLL_IMAGEFILE_EXECUTABLE_IMAGE = 0x0002
Global Const $__DLL_IMAGEFILE_32BIT_MACHINE    = 0x0100
Global Const $__DLL_IMAGEFILE_DLL              = 0x2000
Global Const $__DLL_MEMCOMMIT                  = 0x00001000
; ===============================================================================================================================






; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_Close
; Description ...: Closes a DllHandle previously opened by _Dll_Open.
; Syntax ........: _Dll_Close($hDllHandle)
; Parameters ....: $hDllHandle          - [in/out and const]  DllModule Handle
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: The DllHandle must be a handle obtained by _Dll_Open.
; ...............: Errors: $DLLERR_NOT_INITIALIZED - If _Dll_StartUp hasnt been executed at all.
; ...............:         $DLLERR_INVALID_HANDLE  - If the provided hDllHandle hasnt been opened through _Dll_Open.
; ...............:         $DLLERR_DLLCALL_FAILED  - When an internal function failed to use DllCallAddress.
; Related .......: _Dll_Open
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dll_Close(Const ByRef $hDllHandle)
    If Not _Dll_IsInitialized() Then
        Return SetError($DLLERR_NOT_INITIALIZED, 0, 0)
    EndIf

    ;Loops through the vector to check if the module exist. to not accidentally
    ;call the FreeLibrary on an invalid handle to prevent DllCallAddress to cause
    ;a crash
    If Not _Dll_GetModuleExist($hDllHandle) Then
        Return SetError($DLLERR_INVALID_HANDLE, 0, 0)
    EndIf

    ;Could use _Vector_GetBuffer here but erasing by value can be costly.
    ;So we better loop by index.
    For $i = 0 To _Vector_GetSize($__g_vecDll_DllHandles) - 1
        If _Vector_Get($__g_vecDll_DllHandles, $i) = $hDllHandle Then

            ;Remove module from vector
            _Vector_Erase($__g_vecDll_DllHandles, $i)

            ;Free module
            __Dll_FreeLibrary($hDllHandle)

            Return 1
        EndIf
    Next

    ;Module not found. this should never be called, so just in case.
    Return SetError($DLLERR_INVALID_HANDLE, 0, 0)
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_CloseAll
; Description ...: Closes every Dll previously loaded by _Dll_Open.
; Syntax ........: _Dll_CloseAll()
; Parameters ....:
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: Errors: $DLLERR_NOT_INITIALIZED - If _Dll_StartUp hasnt been executed at all.
; Related .......: _Dll_Close, _Dll_Open
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dll_CloseAll()
    If Not _Dll_IsInitialized() Then
        Return SetError($DLLERR_NOT_INITIALIZED, 0, 0)
    EndIf

    Local $nModuleCount = _Vector_GetSize($__g_vecDll_DllHandles)

    If $nModuleCount Then
        ;Creating a Vector to store already freed modules, just in case the same
        ;handle happened to be twice in the vector. It shouldnt happen but we
        ;never know + the simple 2 liner check prevents interpreting 6 lines.
        Local $vecFreedModules = _Vector_Init($nModuleCount)

        ;Gets the last module added to the vector and frees it.
        ;Note: Vector Pop removes the last entry from the vector.
        Local $hDllHandle = _Vector_Pop($__g_vecDll_DllHandles)
        While $hDllHandle <> Null
            ;Check if module is already freed and if yes jump back to loop start
            If _Vector_Find($vecFreedModules, $hDllHandle) Then
                ContinueLoop
            EndIf

            ;Adding module to the already freed list
            _Vector_Push($vecFreedModules, $hDllHandle)

            ;Freeing the module
            __Dll_FreeLibrary($hDllHandle)

            ;Getting the next module or Null
            $hDllHandle = _Vector_Pop($__g_vecDll_DllHandles)
        WEnd

        ;I did it this way in case of dll dependencies. So when Module B needs Module A
        ;and Module A gets closed first, that will cause unknown behaviour, so better
        ;make a proper cleanup. Note: It does not prevent crashes from dlls that didnt
        ;add propper close handlings!
    EndIf


    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_GetModuleExist
; Description ...: Checks if a module was already loaded with _Dll_Open().
; Syntax ........: _Dll_GetModuleExist($hDllHandle)
; Parameters ....: $hDllHandle          - [in/out and const]  DllModule Handle
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: Errors: $DLLERR_NOT_INITIALIZED - If _Dll_StartUp hasnt been executed at all.
; Related .......: _Dll_Open, _Dll_Close, _Dll_CloseAll
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dll_GetModuleExist(Const ByRef $hDllHandle)
    If Not _Dll_IsInitialized() Then
        Return SetError($DLLERR_NOT_INITIALIZED, 0, 0)
    EndIf

    ;Searches the vector for the DllModule Handle
    Return _Vector_Find($__g_vecDll_DllHandles, $hDllHandle)
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_GetProcAddress
; Description ...: Retrieves the address of an exported function or variable from the DllHandle.
; Syntax ........: _Dll_GetProcAddress($hDllHandle, $sProcName)
; Parameters ....: $hDllHandle          - [in/out and const] DllModule Handle
; ...............: $sProcName           - [const] The name you want to export
; Return values .: Success - Address(Ptr) of the exported sProcName.
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: Errors: $DLLERR_NOT_INITIALIZED - If _Dll_StartUp hasnt been executed at all.
; ...............:         $DLLERR_INVALID_HANDLE  - If the provided hDllHandle hasnt been opened through _Dll_Open.
; ...............:         $DLLERR_INVALID_STRING  - If the provided sProcName is not a string.
; ...............:         $DLLERR_DLLCALL_FAILED  - When an internal function failed to use DllCallAddress.
; Related .......: _Dll_Open, _Dll_Close
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dll_GetProcAddress(Const ByRef $hDllHandle, Const $sProcName)
    If Not _Dll_IsInitialized() Then
        Return SetError($DLLERR_NOT_INITIALIZED, 0, 0)
    EndIf

    ;Loops through the vector to check if the module exist. Additional safetly to NOT use this with
    ;different handles, since DllCallAddress can crash your AutoIt when you dont know how to use it!
    If Not _Dll_GetModuleExist($hDllHandle) Then
        Return SetError($DLLERR_INVALID_HANDLE, 0, 0)
    EndIf

    If Not IsString($sProcName) Then
        Return SetError($DLLERR_INVALID_STRING, 0, 0)
    EndIf

    ;Calls custom assembly
    Local $aCall = DllCallAddress("PTR", $__g_pDll_DllGetAddr, "HANDLE", $hDllHandle, "STR", $sProcName)

    If @error Or $aCall[0] = 0 Then
        Return SetError($DLLERR_DLLCALL_FAILED, @error, 0)
    EndIf

    ;Return Handle
    Return $aCall[0]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_IsInitialized
; Description ...: Checks if the Dll API has setup the custom assembly.
; Syntax ........: _Dll_IsInitialized()
; Parameters ....:
; Return values .: Success - 1
; ...............: Failure - 0
; Author ........: Zvend
; Modified.......:
; Remarks .......:
; Related .......: _Dll_Open, _Dll_GetProcAddress, _Dll_Close
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dll_IsInitialized()
    Return $__g_bDll_DllSetup
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_Open
; Description ...: Loads a 32Bit Dll from an embedded autoit Binary String.
; Syntax ........: _Dll_Open($dDllBinary)
; Parameters ....: $dDllBinary          - [const] The binary data of a 32bit dll.
; Return values .: Success - The Dll Module(Handle)
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: If you have a string of opcodes. make sure that it starts with a '0x' and is converted with Binary().
; ...............: Binary Data of a dll could be achieved with FileOpen("Your.dll", $FO_BINARY) and FileRead($hFile)
; ...............: Errors: $DLLERR_INVALID_BINARY   - If $dDllBinary is not a binary type.
; ...............:         $DLLERR_BINARY_NOT_MZ    - If the binary hasn't set the DosHeader for PE files. ('MZ')
; ...............:         $DLLERR_ALLOC_MEMORY     - If it failed to allocate the memory buffer for the binary.
; ...............:         $DLLERR_FREE_MEMORY      - If it failed to free the memory buffer for the binary.
; ...............:         $DLLERR_BINARY_NOT_32BIT - If the binary holds a dll which is not 32 bit.
; ...............:         $DLLERR_BINARY_NOT_DLL   - If the binary is not the data of a dll.
; ...............:         $DLLERR_LOAD_LIBRARY     - If it fails to load the binary as a dll.
; Related .......: _Dll_Open, _Dll_Close
; Link ..........: https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail
; Example .......: No
; ===============================================================================================================================
Func _Dll_Open(Const $dDllBinary)
    If Not _Dll_IsInitialized() Then
        ;Dynamic load StartUp. It will auto shutdown on AutoIt Exit.
        ;Will also auto free libraries
        _Dll_StartUp()
        If @error Then
            Return SetError(@error, @extended, 0)
        EndIf
    EndIf

    ; Check Param Type
    If Not IsBinary($dDllBinary) Then
        Return SetError($DLLERR_INVALID_BINARY, 0, 0)
    EndIf

    ;Check Binary Magic
    If Not __Dll_IsDosMagic($dDllBinary) Then
        Return SetError($DLLERR_BINARY_NOT_MZ, 0, 0)
    EndIf

    Local $nSize = BinaryLen($dDllBinary)
    ;No reason to read the whole DosHeader, we just need the value at 0x003C: e_lfanew
    Local $nNtHeaderOffset = Int(BinaryMid($dDllBinary, $__DLL_DOSHEADER_SIZE - 3, 4), 1)

    ;If i researched it correctly, nt headers must be bigger than DOS Header
    ;and should end before 0x400, which is usually .text section
    If $nNtHeaderOffset > 0x400 Or $nNtHeaderOffset < 0x40 Then
        Return SetError($DLLERR_INVALID_BINARY, 0, 0)
    EndIf

    ;Allocate memory for the full binary, we need it all anyway for LoadLibrary
    Local $pDllBinaryAddr = __Dll_VirtualAlloc(0, $nSize, $__DLL_MEMCOMMIT, 0x00000004) ;, PAGE_EXECUTE_READWRITE
    If @error Then
        Return SetError($DLLERR_ALLOC_MEMORY, 0, 0)
    EndIf

    ;Storing binary into recent malloc
    Local $tDll = DllStructCreate("BYTE[" & $nSize & "];", $pDllBinaryAddr)
                  DllStructSetData($tDll, 1, $dDllBinary)

    ;Creating the NtHeader struct for easier access
    $tDll = DllStructCreate($tagINTERNAL_NT_HEADER, $pDllBinaryAddr + $nNtHeaderOffset)

    ;Characteristics keep some infos about the file. e.g. if its 32/64bit or exe/dll (and more)
    Local $nCharacteristics = DllStructGetData($tDll,"Characteristics")
    Select
        ;Check for executable file
        Case Not BitAnd($nCharacteristics, $__DLL_IMAGEFILE_EXECUTABLE_IMAGE)
            __Dll_VirtualFree($pDllBinaryAddr, 0, 0x00008000) ;MEM_RELEASE
            Return SetError($DLLERR_BINARY_NOT_MZ, 0, 0)

        ;Check for 32Bit file
        ;~ Case Not BitAnd($nCharacteristics, $__DLL_IMAGEFILE_32BIT_MACHINE)
        ;~     __Dll_VirtualFree($pDllBinaryAddr, 0, 0x00008000) ;MEM_RELEASE
        ;~     Return SetError($DLLERR_BINARY_NOT_32BIT, 0, 0)

        ;Check for dll file
        Case Not BitAnd($nCharacteristics, $__DLL_IMAGEFILE_DLL)
            __Dll_VirtualFree($pDllBinaryAddr, 0, 0x00008000) ;MEM_RELEASE
            Return SetError($DLLERR_BINARY_NOT_DLL, 0, 0)

    EndSelect

    ;Load binary as module
    Local $hModule = __Dll_LoadLibraryA($pDllBinaryAddr)

    If @error Or $hModule = 0 Then
        __Dll_VirtualFree($pDllBinaryAddr, 0, 0x00008000) ;MEM_RELEASE
        Return SetError($DLLERR_LOAD_LIBRARY, 0, 0)
    EndIf

    ;free previous allocated address, which is no longer needed
    __Dll_VirtualFree($pDllBinaryAddr, 0, 0x00008000) ;MEM_RELEASE

    If @error Then
        Return SetError($DLLERR_FREE_MEMORY, 0, 0)
    EndIf

    ;Push module handle in the vector if it doesnt already exist.
    ;To keep a reference for _Dll_Close And _Dll_CloseAll
    If Not _Dll_GetModuleExist($hModule) Then
        _Vector_Push($__g_vecDll_DllHandles, $hModule)
    EndIf

    ;Return module handle
    Return $hModule
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_Shutdown
; Description ...: Frees the loaded dlls, deallocates assembly and internal variables.
; Syntax ........: _Dll_Shutdown()
; Parameters ....:
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: Errors: $DLLERR_NOT_INITIALIZED   -  If _Dll_StartUp hasnt been executed at all.
; ...............:         $DLLERR_FREE_MEMORY       - If it failed to free the memory buffer for the assembly.
; Related .......: _Dll_StartUp, _Dll_Open, _Dll_Close, _Dll_CloseAll
; Link ..........: https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail
; Example .......: No
; ===============================================================================================================================
Func _Dll_Shutdown()
    If Not _Dll_IsInitialized() Then
        Return SetError($DLLERR_NOT_INITIALIZED, 0, 0)
    EndIf

    ;No need to error check this one, since the check has already been done in this function
    _Dll_CloseAll()
    ;Free DllLoaderPayload
    __Dll_VirtualFree($__g_pDll_DllLoadBase, 0, 0x00008000) ;$MEM_RELEASE
    If @error Then
        Return SetError($DLLERR_FREE_MEMORY, 0, 0)
    EndIf

    $__g_bDll_DllSetup     = 0
    $__g_vecDll_DllHandles = 0
    $__g_pDll_DllLoadBase  = 0
    $__g_pDll_DllLoad      = 0
    $__g_pDll_DllGetAddr   = 0
    $__g_pDll_DllFree      = 0
    $__g_pDll_LoadLib       = 0
    $__g_pDll_GetProcAddr   = 0

    Return 1
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _Dll_StartUp
; Description ...: Initializes the assembly and sets up internal variables.
; Syntax ........: _Dll_StartUp()
; Parameters ....:
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: Gets called when using _Dll_Open() the first time.
; ...............: Errors: $DLLERR_INVALID_BINARY - If the type of assembly payload is not binary.
; ...............:         $DLLERR_ALLOC_MEMORY   - If it failed to allocate memory for the assembly binary.
; ...............:         $DLLERR_INVALID_HANDLE - If it failed to load the Kernel32.dll.
; ...............:         $DLLERR_LOAD_LIBRARY   - If it failed to get the address of LoadLibraryA
; ...............:         $DLLERR_GETPROCADDRESS - If it failed to get the address of GetProcAddress
; Related .......: _Dll_Shutdown, _Dll_Open, _Dll_Close
; Link ..........: https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail
; Example .......: No
; ===============================================================================================================================
Func _Dll_StartUp()
    If _Dll_IsInitialized() Then
        Return 1
    EndIf

    ;Gets the Binary of embedded machine code in a string
    Local $dPayLoad = __Dll_GetDllLoaderPayload()
    If @error Or $dPayLoad == "" Then
        Return SetError($DLLERR_INVALID_BINARY, 0, 0)
    EndIf

    ;Reserve Space for the machine code
    Local $nSize = BinaryLen($dPayLoad)
    $__g_pDll_DllLoadBase = __Dll_VirtualAlloc(0, $nSize, $__DLL_MEMCOMMIT, 0x00000004) ;PAGE_EXECUTE_READWRITE

    If @error Then
        Return SetError($DLLERR_ALLOC_MEMORY, 0, 0)
    EndIf

    ;Write payload to the allocated address
    Local $tPayload = DllStructCreate("BYTE Payload[" & $nSize & "]", $__g_pDll_DllLoadBase)
    DllStructSetData($tPayload, "Payload", $dPayLoad)

    ;Getting a correct Handle for kernel32.dll. Inbuilt DllOpen does not work.
    Local $hKernelModule = __Dll_GetModuleHandleW("kernel32")

    If @error Then
        ;Free Memory on fail, to prevent Memory leak
        __Dll_VirtualFree($__g_pDll_DllLoadBase, 0, 0x00008000) ;MEM_RELEASE
        Return SetError($DLLERR_INVALID_HANDLE, 0, 0)
    EndIf

    ;Getting Address of LoadLibraryA, which is needed for the setup
    $__g_pDll_LoadLib = __Dll_GetProcAddress($hKernelModule, "LoadLibraryA")

    If @error Then
        ;Free Memory on fail, to prevent Memory leak
        $__g_pDll_LoadLib = 0
        __Dll_VirtualFree($__g_pDll_DllLoadBase, 0, 0x00008000) ;MEM_RELEASE
        Return SetError($DLLERR_LOAD_LIBRARY, 0, 0)
    EndIf

    ;Getting Address of GetProcAddress, which is also needed for the setup
    $__g_pDll_GetProcAddr = __Dll_GetProcAddress($hKernelModule, "GetProcAddress")

    If @error Then
        ;Free Memory on fail, to prevent Memory leak
        $__g_pDll_LoadLib = 0
        $__g_pDll_GetProcAddr = 0
        __Dll_VirtualFree($__g_pDll_DllLoadBase, 0, 0x00008000) ;MEM_RELEASE
        Return SetError($DLLERR_GETPROCADDRESS, 0, 0)
    EndIf

    ;Finally setup API vars and initialize Vector to store all loaded Handles, to free them later
    $__g_vecDll_DllHandles = _Vector_Init()
    $__g_pDll_DllLoad    = $__g_pDll_DllLoadBase + 0x00A1
    $__g_pDll_DllGetAddr = $__g_pDll_DllLoadBase + 0x0590
    $__g_pDll_DllFree    = $__g_pDll_DllLoadBase + 0x059F

    ;Setting initialized to True and a Shutdown callback for the AutoIt Exit to free everything properly
    $__g_bDll_DllSetup = 1

    Return 1
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_LoadLibraryA
; Description ...: Loads a dll module from an address in memory.
; Syntax ........: __Dll_LoadLibraryA($dDllBinary)
; Parameters ....: $dDllBinary          - [in/out and const] The binary data of a 32bit dll.
; Return values .: Success - Success - The Dll Module(Handle)
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: Errors: $DLLERR_DLLCALL_FAILED - When an internal function failed to use DllCallAddress.
; Related .......: __Dll_FreeLibrary, __Dll_GetModuleHandleW, __Dll_GetProcAddress
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Dll_LoadLibraryA(Const ByRef $dDllBinary)
    ;Calls a function from the custom assembly to load the library from a pointer
    Local $aCall = DllCallAddress("HANDLE", $__g_pDll_DllLoad, "PTR", $__g_pDll_LoadLib, "PTR", $__g_pDll_GetProcAddr, "PTR", $dDllBinary)

    If @error Then
        Return SetError($DLLERR_DLLCALL_FAILED, @error, 0)
    EndIf

    ;Returns the handle of the loaded dll
    Return $aCall[0]
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_FreeLibrary
; Description ...: Frees a dll module previously loaded from memory.
; Syntax ........: __Dll_FreeLibrary($hDllHandle)
; Parameters ....: $hDllHandle          - [in/out and const] DllModule Handle
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: Errors: $DLLERR_DLLCALL_FAILED - When an internal function failed to use DllCallAddress.
; Related .......: __Dll_LoadLibraryA, __Dll_GetModuleHandleW, __Dll_GetProcAddress
; Link ..........: https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail
; Example .......: No
; ===============================================================================================================================
Func __Dll_FreeLibrary(Const ByRef $hDllHandle)
    ;Calls a function from the custom assembly to free a library
    DllCallAddress("PTR", $__g_pDll_DllFree, "HANDLE", $hDllHandle)

    If @error Then
        Return SetError($DLLERR_DLLCALL_FAILED, @error, 0)
    EndIf

    Return 1
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_IsDosMagic
; Description ...: Checks if the BinaryString has the DosMagic set.
; Syntax ........: __Dll_IsDosMagic($dDllBinary)
; Parameters ....: $dDllBinary          - [in/out and const] The binary data of a 32bit dll.
; Return values .: Success - 1
; ...............: Failure - 0
; Author ........: Zvend
; Modified.......:
; Remarks .......:
; Related .......: __Dll_GetDllLoaderPayload
; Link ..........: https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail
; Example .......: No
; ===============================================================================================================================
Func __Dll_IsDosMagic(Const ByRef $dDllBinary)
    ;Checks the first 2 bytes for 4D 5A which is represented as 'MZ'.
    Return BinaryMid($dDllBinary, 1, 2) == "0x4D5A"
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_GetDllLoaderPayload
; Description ...: Get the assembly-binary that makes it possible to load and free dlls from memory and get their dllexports.
; Syntax ........: __Dll_GetDllLoaderPayload()
; Parameters ....:
; Return values .: Success - 1
; ...............: Failure - 0
; Author ........: Zvend
; Modified.......:
; Remarks .......: Errors: 1 - when Payload happens to be = "". Inform the dev that should happen.
; Related .......:
; Link ..........: https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail
; Example .......: No
; ===============================================================================================================================
Func __Dll_GetDllLoaderPayload()
    Static Local $dBinary = ""

    If $dBinary == "" Then
        ;Concatenates the machine code of the custom assembly in a string
        $dBinary &= "0xFFFFFFFFFFFFFFFFB800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000"
        $dBinary &= "FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE0B800000000FFE05589E55156"
        $dBinary &= "578B7D088B750C8B4D10FCF3A45F5E595DC35589E5578B7D088A450C8B4D10F3AA5F5DC359585A5153E8000000005B81EBAB11400089830011400089930411"
        $dBinary &= "4000E8000000005981E9C3114000518B9100114000E80B0000007573657233322E646C6C005850FFD2598B9104114000E80C0000004D657373616765426F78"
        $dBinary &= "4100595150FFD2898372114000E8000000005981E90D124000518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E80A"
        $dBinary &= "0000006C737472636D70694100595150FFD2898309114000E8000000005981E957124000518B9100114000E80D0000006B65726E656C33322E646C6C005850"
        $dBinary &= "FFD2598B9104114000E80D0000005669727475616C416C6C6F6300595150FFD2898310114000E8000000005981E9A4124000518B9100114000E80D0000006B"
        $dBinary &= "65726E656C33322E646C6C005850FFD2598B9104114000E80C0000005669727475616C4672656500595150FFD2898317114000E8000000005981E9F0124000"
        $dBinary &= "518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E80F0000005669727475616C50726F7465637400595150FFD28983"
        $dBinary &= "1E114000E8000000005981E93F134000518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E80E00000052746C5A6572"
        $dBinary &= "6F4D656D6F727900595150FFD2898325114000E8000000005981E98D134000518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B91"
        $dBinary &= "04114000E80D0000004C6F61644C6962726172794100595150FFD289832C114000E8000000005981E9DA134000518B9100114000E80D0000006B65726E656C"
        $dBinary &= "33322E646C6C005850FFD2598B9104114000E80F00000047657450726F634164647265737300595150FFD2898333114000E8000000005981E929144000518B"
        $dBinary &= "9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E80D00000049734261645265616450747200595150FFD289833A114000"
        $dBinary &= "E8000000005981E976144000518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E80F00000047657450726F63657373"
        $dBinary &= "4865617000595150FFD2898341114000E8000000005981E9C5144000518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B91041140"
        $dBinary &= "00E80A00000048656170416C6C6F6300595150FFD2898348114000E8000000005981E90F154000518B9100114000E80D0000006B65726E656C33322E646C6C"
        $dBinary &= "005850FFD2598B9104114000E809000000486561704672656500595150FFD289834F114000E8000000005981E958154000518B9100114000E80D0000006B65"
        $dBinary &= "726E656C33322E646C6C005850FFD2598B9104114000E80C000000476C6F62616C416C6C6F6300595150FFD2898356114000E8000000005981E9A415400051"
        $dBinary &= "8B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E80E000000476C6F62616C5265416C6C6F6300595150FFD289836411"
        $dBinary &= "4000E8000000005981E9F2154000518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E80B000000476C6F62616C4672"
        $dBinary &= "656500595150FFD289835D114000E8000000005981E93D164000518B9100114000E80D0000006B65726E656C33322E646C6C005850FFD2598B9104114000E8"
        $dBinary &= "0C000000467265654C69627261727900595150FFD289836B1140005B59585150E80E04000059C35990585A515250E8CC0500005A5AC35A585250E88E060000"
        $dBinary &= "59C35589E557565383EC1C8B45108B40048945EC8B55108B020FB750148D740218C745F00000000066837806000F84B0000000837E1000754C8B450C8B5838"
        $dBinary &= "85DB0F8E84000000C744240C04000000C744240800100000895C24048B45EC03460C890424E8FEF9FFFF83EC10894608895C2408C744240400000000890424"
        $dBinary &= "E864FAFFFFEB46C744240C04000000C7442408001000008B4610894424048B45EC03460C890424E8BDF9FFFF83EC1089C78B55080356148B46108944240889"
        $dBinary &= "542404893C24E808FAFFFF897E08FF45F083C6288B55108B020FB740063B45F00F8F50FFFFFF8D65F45B5E5F5DC35589E557565383EC1C8B55088B020FB750"
        $dBinary &= "148D5C0218BF0000000066837806000F84E80000008B432489C2C1EA1D89D683E60189C2C1EA1E83E20189C1C1E91FA9000000027422C7442408004000008B"
        $dBinary &= "4310894424048B4308890424E822F9FFFF83EC0CE99000000085F6741E85D2740D83F90119D283E2E083C240EB2983F90119D283E29083EA80EB1C85D2740D"
        $dBinary &= "83F90119D283E2FE83C204EB0B83F90119D283E2F983C208F6432704740681CA000200008B4B1085C97522F6432440740A8B4D088B018B4820EB0EF6432480"
        $dBinary &= "74088B4D088B018B482485C9741D8D45F08944240C89542408894C24048B4308890424E894F8FFFF83EC104783C3288B55088B020FB7400639F80F8F18FFFF"
        $dBinary &= "FF8D65F45B5E5F5DC35589E557565383EC048B45088B50048955F08B0083B8A400000000745789D30398A0000000833B00744A8B7DF0033B8D4B08BE000000"
        $dBinary &= "008B430483E808D1E883F80076280FB70189C2C1EA0C25FF0F000083FA0375068B550C0114074683C1028B430483E808D1E839F077D8035B04833B0075B683"
        $dBinary &= "C4045B5E5F5DC35589E557565383EC1CC745F0010000008B45088B40048945EC8B55088B0283B884000000000F84410100008B7DEC03B880000000E9120100"
        $dBinary &= "008B45EC03470C890424E8BFF7FFFF83EC048945E883F8FF750CC745F000000000E90E0100008B4D0883790800742EC7442408400000008B410C8D04850400"
        $dBinary &= "0000894424048B4108890424E8B6F7FFFF83EC0C8B550889420885C075268B4D088B410C8D04850400000089442404C7042440000000E87EF7FFFF83EC088B"
        $dBinary &= "55088942088B4D088B510C8B41088B4DE8890C908B4508FF400C833F0074168B5DEC031F8B75EC037710EB11C745F000000000EB578B5DEC035F1089DE833B"
        $dBinary &= "00744A833B0079190FB703894424048B55E8891424E8FEF6FFFF83EC088906EB1C8B45EC030383C002894424048B4DE8890C24E8E0F6FFFF83EC088906833E"
        $dBinary &= "0074AB83C30483C604833B0075B6837DF000742483C714C744240414000000893C24E8B9F6FFFF83EC0885C0750A837F0C000F85CDFEFFFF8B45F08D65F45B"
        $dBinary &= "5E5F5DC35589E557565383EC1C8B45088945F0B8000000008B550866813A4D5A0F85A20100008B75088B45F003703CB800000000813E504500000F85880100"
        $dBinary &= "00C744240C04000000C7442408002000008B4650894424048B4634890424E815F6FFFF83EC1089C785C07535C744240C04000000C7442408002000008B4650"
        $dBinary &= "89442404C7042400000000E8E9F5FFFF83EC1089C7B80000000085FF0F8428010000E803F6FFFFC744240814000000C744240400000000890424E8F2F5FFFF"
        $dBinary &= "83EC0C89C3897804C7400C00000000C7400800000000C7401000000000C744240C04000000C7442408001000008B465089442404893C24E87EF5FFFF83EC10"
        $dBinary &= "C744240C04000000C7442408001000008B465489442404893C24E85CF5FFFF83EC108945EC8B55F08B423C03465489442408895424048B45EC890424E8A3F5"
        $dBinary &= "FFFF8B45EC8B55F003423C8903897834895C2408897424048B4508890424E8B4FAFFFF89F82B4634740C89442404891C24E8A0FCFFFF891C24E814FDFFFF85"
        $dBinary &= "C0743E891C24E876FBFFFF8B0383782800742A89FA0350287427C744240800000000C744240401000000893C24FFD283EC0C85C0740BC743100100000089D8"
        $dBinary &= "EB0D891C24E8DB000000B8000000008D65F45B5E5F5DC35589E583EC28895DF48975F8897DFC8B45088B50048955F0C745ECFFFFFFFF8B1083C278B8000000"
        $dBinary &= "00837A04000F848E0000008B5DF0031A837B18007406837B1400750FB800000000EB760FB73F897DECEB458B75F00373208B7DF0037B24C745E80000000083"
        $dBinary &= "7B1800762C8B45F00306894424048B450C890424E820F4FFFF83EC0885C074C4FF45E883C60483C7028B55E839531877D4B800000000837DECFF741EB80000"
        $dBinary &= "00008B55EC3B531477118B45ECC1E00203431C8B55F003141089D08B5DF48B75F88B7DFC89EC5DC35589E5565383EC108B750885F60F84AC000000837E1000"
        $dBinary &= "742A8B068B56048B48288D040AC744240800000000C744240400000000891424FFD083EC0CC7461000000000837E08007436BB00000000837E0C007E1D8B46"
        $dBinary &= "08833C98FF740E8B0498890424E8CCF3FFFF83EC0443395E0C7FE38B4608890424E8AAF3FFFF83EC04837E0400741EC744240800800000C744240400000000"
        $dBinary &= "8B4604890424E840F3FFFF83EC0CE862F3FFFF89742408C744240400000000890424E85CF3FFFF83EC0C8D65F85B5E5DC30000000000000000000000000000"
    EndIf

    ;Converts and returns the binary data
    Return SetError(Int($dBinary == "", 1), 0, Binary($dBinary))
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_GetModuleHandleW
; Description ...: Retrieves a module handle for the specified module. The module must have been loaded by the calling process.
; Syntax ........: __Dll_GetModuleHandleW($sModuleName)
; Parameters ....: $sModuleName         - [const] The name of the module to get the handle from. E.g. "kernel32.dll".
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: The returned handle is not global or inheritable. It cannot be duplicated or used by another process.
; ...............: Errors: $DLLERR_DLLCALL_FAILED - When an internal function failed to use DllCallAddress.
; Related .......: __Dll_GetDllLoaderPayload
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandlew
; Example .......: No
; ===============================================================================================================================
Func __Dll_GetModuleHandleW(Const $sModuleName)
	Local $aCall = DllCall($__g_hDll_KernelDll, "HANDLE", "GetModuleHandleW", "WSTR", $sModuleName)

	If @error Then
        Return SetError($DLLERR_DLLCALL_FAILED, @error, 0)
	EndIf

	Return $aCall[0]
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_GetProcAddress
; Description ...: Retrieves the address of an exported function or variable from the specified dynamic-link library (DLL).
; Syntax ........: __Dll_GetProcAddress($hModule, $sProcName)
; Parameters ....: $hModule             - [const] A handle to the DLL module that contains the dllexport.
; ...............: $sProcName           - [const] The function or variable name, or the function's ordinal value.
; Return values .: Success - 1
; ...............: Failure - 0 and @error is set to non-zero.
; Author ........: Zvend
; Modified.......:
; Remarks .......: sProcName is Case-Sensitive. It must match exactly with the export name.
; ...............: Errors: $DLLERR_DLLCALL_FAILED - When an internal function failed to use DllCallAddress.
; Related .......: __Dll_GetModuleHandleW, __Dll_LoadLibrary
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getprocaddress
; Example .......: No
; ===============================================================================================================================
Func __Dll_GetProcAddress(Const $hModule, Const $sProcName)
	Local $aCall = DllCall($__g_hDll_KernelDll, "PTR", "GetProcAddress", "HANDLE", $hModule, "STR", $sProcName)

	If @error Then
        Return SetError($DLLERR_DLLCALL_FAILED, @error, 0)
	EndIf

	Return $aCall[0]
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_VirtualAlloc
; Description ...: Reserves, commits, or changes the state of a region of pages in the virtual address space of the calling
;                : process. Memory allocated by this function is automatically initialized to zero
; Syntax ........: __Dll_VirtualAlloc($pAddress, $nSize, $nAllocation, $nProtect)
; Parameters ....: $pAddress            - [const] a pointer value.
;                  $nSize               - [const] a general number value.
;                  $nAllocation         - [const] pass: $MEM_COMMIT, $MEM_RESERVE, $MEM_TOP_DOWN or $MEM_SHARED
;                  $nProtect            - [const] a general number value.
; Return values .: Success - Ptr(base address of the allocated region)
;                : Failure - 0. Sets the @error to $AU_ERR_DLLCALL_FAILED.
; Author ........: Zvend
; Modified ......:
; Remarks .......: Errors: $DLLERR_DLLCALL_FAILED - When an internal function failed to use DllCallAddress.
; Related .......: __Dll_VirtualFree, __Dll_VirtualAllocEx
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-__Dll_VirtualAlloc
; Example .......: No
; ===============================================================================================================================
Func __Dll_VirtualAlloc(Const $pAddress, Const $nSize, Const $nAllocation, Const $nProtect)
	Local $aCall = DllCall($__g_hDll_KernelDll, "PTR", "VirtualAlloc", "PTR", $pAddress, "ULONG_PTR", $nSize, "DWORD", $nAllocation, "DWORD", $nProtect)

	If @error Then
        Return SetError($DLLERR_DLLCALL_FAILED, @error, 0)
    EndIf

	Return $aCall[0]
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dll_VirtualFree
; Description ...: Releases, decommits, or releases and decommits a region of pages within the virtual address space of the
;                : calling process.
; Syntax ........: __Dll_VirtualFree(Const $pAddress, Const $nSize, Const $nFreeType)
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
; Related .......: __Dll_VirtualAllocEx, __Dll_VirtualFreeEx
; Link ..........: https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-__Dll_VirtualFree
; Example .......: No
; ===============================================================================================================================
Func __Dll_VirtualFree(Const $pAddress, Const $nSize, Const $nFreeType)
	Local $aCall = DllCall($__g_hDll_KernelDll, "BOOL", "VirtualFree", "PTR", $pAddress, "ULONG_PTR", $nSize, "DWORD", $nFreeType)

	If @error Then
        Return SetError($DLLERR_DLLCALL_FAILED, @error, 0)
    EndIf

	Return $aCall[0]
EndFunc


