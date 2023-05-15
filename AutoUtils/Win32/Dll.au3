#cs Header
#
#   A 32Bit Dll loader that only needs the binarystrings of your dll file. I
#   suggest to compress them before embedding them in AutoIt.
#
#   @author     [Zvend](Zvend#6666)
#   @link       [Zvendson](https://github.com/Zvendson)
#
#   @func       _Dll_IsInitialized()
#   @func       _Dll_Open(Const $dDllBinary)
#   @func       _Dll_GetProcAddrress(Const ByRef $hDllHandle, Const $sProcName)
#   @func       _Dll_Close(Const ByRef $hDllHandle)
#   @func       _Dll_CloseAll()
#
#   @version     3.3.16.1
#
#   Saturday 14 May 2023
#
#ce

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#cs
    @include ApiErrorCodes.au3  Global AutoUtilsAPI error codes with an errorcode2string converter
#ce
#include ".\..\ApiErrorCodes.au3"

#cs
    @include StructTags.au3     Structures that reveal some of the in-depths of PE File Formats
#ce
#include ".\StructTags.au3"

#cs
    @include Constants.au3      Win32 "Magic Values" for using the Windows API
#ce
#include ".\Constants.au3"

#cs
    @include Memory.au3         Win32 Memory toolset
#ce
#include ".\Memory.au3"

#cs
    @include Vector.au3         A C++ Vector implementation written in AutoIt
#ce
#include ".\..\Arrays\Vector.au3"



#cs
    @private    Holding state if Dll API is initialized or not.
#ce
Global $__g_bWindowsDllSetup = 0

#cs
    @private    Vector storing Module References through using _Dll_Open.
#ce
Global $__g_vecWindowsDllHandles = 0

#cs
    @private    Allocated Address range storing the assembly payload.
#ce
Global $__g_pWindowsDllLoadBase = 0

#cs
    @private    Address within the LoadBase to internally call LoadLibrary.
#ce
Global $__g_pWindowsDllLoad      = 0

#cs
    @private    Address within the LoadBase to internally call GetProcAddress.
#ce
Global $__g_pWindowsDllGetAddr   = 0

#cs
    @private    Address within the LoadBase to internally call FreeLibrary.
#ce
Global $__g_pWindowsDllFree      = 0

#cs
    @private    Address from the original LoadLibraryA function.
#ce
Global $__g_pKernelLoadLib       = 0

#cs
    @private    Address from the original GetProcAddress function.
#ce
Global $__g_pKernelGetProcAddr   = 0



#cs
    Checks if the Dll API is initialized.

    @return (Bool)  1 or 0

    @author         [Zvend](Zvend#6666)
    @version        3.3.16.1
    @since          3.3.16.1
    @see            _Dll_Open
    @see            _Dll_Close
#ce
Func _Dll_IsInitialized()
    Return $__g_bWindowsDllSetup
EndFunc



#cs
    Loads a 32Bit Dll from an embedded autoit Binary String.

    @param  (Binary) Const $dDllBinary  Binary data of a Dll

    @return (Handle)    DllModule Handle or 0

    @error              $AU_ERR_DLLAPI_STARTUP, $AU_ERR_DLLAPI_STARTUP
    @extended           Detailed error infos

    @remarks            If you have a string of opcodes. make sure that it starts with a '0x' and is converted with Binary().

    @author             [Zvend](Zvend#6666)
    @version            3.3.16.1
    @since              3.3.16.1
    @see                _AU_ConvertErorr
    @see                _Dll_GetProcAddrress
    @see                _Dll_Close
    @see                _Dll_CloseAll
    @link               [PE File Format - In-Depth Look](https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail)
#ce
Func _Dll_Open(Const $dDllBinary)
    If Not _Dll_IsInitialized() Then
        ;Dynamic load StartUp. It will auto shutdown on AutoIt Exit.
        ;Will also auto free libraries
        __Dll_StartUp()
        If @error Then
            Return SetError(@error, @extended, 0)
        EndIf
    EndIf

    ; Check Param Type
    If Not IsBinary($dDllBinary) Then
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_INVALID_BINARY, 0)
    EndIf

    ;Check Binary Magic
    If Not __Dll_IsDosMagic($dDllBinary) Then
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_BINARY_NOT_MZ, 0)
    EndIf

    Local $nSize = BinaryLen($dDllBinary)
    ;No reason to read the whole DosHeader, we just need the value at 0x003C: e_lfanew
    Local $nNtHeaderOffset = Int(BinaryMid($dDllBinary, $sizeDOS_HEADER - 3, 4), 1)

    ;If i researched it correctly, nt headers must be bigger than DOS Header
    ;and should end before 0x400, which is usually .text section
    If $nNtHeaderOffset > 0x400 Or $nNtHeaderOffset < 0x40 Then
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_INVALID_BINARY, 0)
    EndIf

    ;Allocate memory for the full binary, we need it all anyway for LoadLibrary
    Local $pDllBinaryAddr = VirtualAlloc(0, $nSize, $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
    If @error Then
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_ALLOC_MEMORY, 0)
    EndIf

    ;Storing binary into recent malloc
    Local $tDll = DllStructCreate("BYTE[" & $nSize & "];", $pDllBinaryAddr)
                  DllStructSetData($tDll, 1, $dDllBinary)

    ;Creating the NtHeader struct for easier access
    $tDll = DllStructCreate($tagNT_HEADER, $pDllBinaryAddr + $nNtHeaderOffset)

    ;Characteristics keep some infos about the file. e.g. if its 32/64bit or exe/dll (and more)
    Local $nCharacteristics = DllStructGetData($tDll,"Characteristics")
    Select
        ;Check for executable file
        Case Not BitAnd($nCharacteristics, $__IMAGE_FILE_EXECUTABLE_IMAGE)
            VirtualFree($pDllBinaryAddr, 0, $MEM_RELEASE)
            Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_BINARY_NOT_MZ, 0)

        ;Check for 32Bit file
        Case Not BitAnd($nCharacteristics, $__IMAGE_FILE_32BIT_MACHINE)
            VirtualFree($pDllBinaryAddr, 0, $MEM_RELEASE)
            Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_BINARY_NOT_32BIT, 0)

        ;Check for dll file
        Case Not BitAnd($nCharacteristics, $__IMAGE_FILE_DLL)
            VirtualFree($pDllBinaryAddr, 0, $MEM_RELEASE)
            Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_BINARY_NOT_DLL, 0)

    EndSelect

    ;Load binary as module
    Local $hModule = __Dll_LoadLibraryA($pDllBinaryAddr)

    If @error Or $hModule = 0 Then
        VirtualFree($pDllBinaryAddr, 0, $MEM_RELEASE)
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_LOAD_LIBRARY, 0)
    EndIf

    ;free previous allocated address, which is no longer needed
    VirtualFree($pDllBinaryAddr, 0, $MEM_RELEASE)

    If @error Then
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_FREE_MEMORY, 0)
    EndIf

    ;Push module handle in the vector if it doesnt already exist.
    ;To keep a reference for _Dll_Close And _Dll_CloseAll
    If Not __Dll_GetModuleExist($hModule) Then
        _Vector_Push($__g_vecWindowsDllHandles, $hModule)
    EndIf

    ;Return module handle
    Return $hModule
EndFunc



#cs
    Retrieves the address of an exported function or variable from the specified dynamic-link library (DLL).

    @param  (Handle) Const ByRef $hDllHandle    DllModule Handle
    @param  (String) Const       $sProcName     The function or variable name, or the function's ordinal value.

    @return (Pointer)   Address of the ProcName or 0

    @error              $AU_ERR_DLLAPI_UNIT, $AU_ERR_DLLAPI_GETPROC
    @extended           Detailed error infos

    @author             [Zvend](Zvend#6666)
    @version            3.3.16.1
    @since              3.3.16.1
    @see                _AU_ConvertErorr
    @see                DllCallAddress
    @link               [PE File Format - In-Depth Look](https://learn.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail)
#ce
Func _Dll_GetProcAddrress(Const ByRef $hDllHandle, Const $sProcName)
    If Not _Dll_IsInitialized() Then
        Return SetError($AU_ERR_DLLAPI_UNIT, $AUFUNC_DLLAPI_GETPROC, 0)
    EndIf

    ;Loops through the vector to check if the module exist. Additional safetly to NOT use this with
    ;different handles, since DllCallAddress can crash your AutoIt when you dont know how to use it!
    If Not __Dll_GetModuleExist($hDllHandle) Then
        Return SetError($AU_ERR_DLLAPI_GETPROC, $AU_ERREX_INVALID_HANDLE, 0)
    EndIf

    ;Calls custom assembly
    Local $aCall = DllCallAddress("PTR", $__g_pWindowsDllGetAddr, "HANDLE", $hDllHandle, "STR", $sProcName)

	If @error Or $aCall[0] = 0 Then
        Return SetError($AU_ERR_DLLAPI_GETPROC, @error, 0)
	EndIf

    ;Return Handle
	Return $aCall[0]
EndFunc



#cs
    Closes a handle previously opened by _Dll_Call.

    @param (Handle) Const ByRef $hDllHandle     DllModule Handle

    @return (Bool)  1 on success, 0 on failure

    @error          $AU_ERR_DLLAPI_UNIT, $AU_ERR_DLLAPI_CLOSE
    @extended       Detailed error infos

    @author         [Zvend](Zvend#6666)
    @version        3.3.16.1
    @since          3.3.16.1
    @see            _AU_ConvertErorr
    @see            _Dll_CloseAll
#ce
Func _Dll_Close(Const ByRef $hDllHandle)
    If Not _Dll_IsInitialized() Then
        Return SetError($AU_ERR_DLLAPI_UNIT, $AUFUNC_DLLAPI_CLOSE, 0)
    EndIf

    ;Loops through the vector to check if the module exist. to not accidentally
    ;call the FreeLibrary on an invalid handle to prevent DllCallAddress to cause
    ;a crash
    If Not __Dll_GetModuleExist($hDllHandle) Then
        Return SetError($AU_ERR_DLLAPI_CLOSE, $AU_ERREX_INVALID_HANDLE, 0)
    EndIf

    ;Could use _Vector_GetBuffer here but erasing by value can be costly.
    ;So we better loop by index.
    For $i = 0 To _Vector_GetSize($__g_vecWindowsDllHandles) - 1
        If _Vector_Get($__g_vecWindowsDllHandles, $i) = $hDllHandle Then

            ;Remove module from vector
            _Vector_Erase($__g_vecWindowsDllHandles, $i)

            ;Free module
            __Dll_FreeLibrary($hDllHandle)

            Return 1
        EndIf
    Next

    ;Module not found. this should never be called, so just in case.
    Return SetError($AU_ERR_DLLAPI_CLOSE, $AU_ERREX_INVALID_HANDLE, 0)
EndFunc



#cs
    Frees every Dll previously loaded via _Dll_Open.

    @return (Bool)  1 on success, 0 on failure

    @error          $AU_ERR_DLLAPI_UNIT
    @extended       Detailed error infos

    @remarks        Gets called on __Dll_ShutDown().

    @author         [Zvend](Zvend#6666)
    @version        3.3.16.1
    @since          3.3.16.1
    @see            _AU_ConvertErorr
    @see            _Dll_Open
    @see            _Dll_Close
#ce
Func _Dll_CloseAll()
    If Not _Dll_IsInitialized() Then
        Return SetError($AU_ERR_DLLAPI_UNIT, $AUFUNC_DLLAPI_CLOSE, 0)
    EndIf

    Local $nModuleCount = _Vector_GetSize($__g_vecWindowsDllHandles)

    If $nModuleCount Then
        ;Creating a Vector to store already freed modules, just in case the same
        ;handle happened to be twice in the vector. It shouldnt happen but we
        ;never know + the simple 2 liner check prevents interpreting 6 lines.
        Local $vecFreedModules = _Vector_Init($nModuleCount)

        ;Gets the last module added to the vector and frees it.
        ;Note: Vector Pop removes the last entry from the vector.
        Local $hDllHandle = _Vector_Pop($__g_vecWindowsDllHandles)
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
            $hDllHandle = _Vector_Pop($__g_vecWindowsDllHandles)
        WEnd
    EndIf

    ;I did it this way in case of dll dependencies. So when Module B needs Module A
    ;and Module A gets closed first, that will cause unknown behaviour, so better
    ;make a proper cleanup. Note: It does not prevent crashes from dlls that didnt
    ;add propper close handlings!

    Return 1
EndFunc



#cs Internal Only
    Checks if the BinaryString has the DosMagic set.

    @param (Binary) Const ByRef $dDllBinary     Binary to be checked

    @return     1 on success, 0 on failure

    @author     [Zvend](Zvend#6666)
    @version    3.3.16.1
    @since      3.3.16.1
#ce
Func __Dll_IsDosMagic(Const ByRef $dDllBinary)
    ;Checks the first 2 bytes for 4D 5A which is represented as 'MZ'.
    Return BinaryMid($dDllBinary, 1, 2) == "0x4D5A"
EndFunc



#cs Internal Only
    Initializes the assembly and sets up internal variables.
    Gets called when using _Dll_Open and registers a shutdown callback when AutoIt exit.

    @return (Bool)  1 on success, 0 on failure

    @error          $AU_ERR_DLLAPI_STARTUP
    @extended       Detailed error infos

    @author         [Zvend](Zvend#6666)
    @version        3.3.16.1
    @since          3.3.16.1
    @see            _AU_ConvertErorr
    @see            __Dll_Shutdown
    @see            __Dll_Open
#ce
Func __Dll_StartUp()
    If _Dll_IsInitialized() Then
        Return 1
    EndIf

    ;Gets the Binary of embedded machine code in a string
    Local $dPayLoad = __Dll_GetDllLoaderPayload()
    If @error Or $dPayLoad == "" Then
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_INVALID_BINARY, 0)
    EndIf

    ;Reserve Space for the machine code
    Local $nSize = BinaryLen($dPayLoad)
    $__g_pWindowsDllLoadBase = VirtualAlloc(0, $nSize, $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)

    If @error Then
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_ALLOC_MEMORY, 0)
    EndIf

    ;Write payload to the allocated address
    Local $tPayload = DllStructCreate("BYTE Payload[" & $nSize & "]", $__g_pWindowsDllLoadBase)
    DllStructSetData($tPayload, "Payload", $dPayLoad)

    ;Getting a correct Handle for kernel32.dll. Inbuilt DllOpen does not work.
    Local $hKernelModule = GetModuleHandle("kernel32")

    If @error Then
        ;Free Memory on fail, to prevent Memory leak
        VirtualFree($__g_pWindowsDllLoadBase, 0, $MEM_RELEASE)
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_INVALID_MODULE, 0)
    EndIf

    ;Getting Address of LoadLibraryA, which is needed for the setup
    $__g_pKernelLoadLib = GetProcAddress($hKernelModule, "LoadLibraryA")

    If @error Then
        ;Free Memory on fail, to prevent Memory leak
        $__g_pKernelLoadLib = 0
        VirtualFree($__g_pWindowsDllLoadBase, 0, $MEM_RELEASE)
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_GET_LOADLIBRARY, 0)
    EndIf

    ;Getting Address of GetProcAddress, which is also needed for the setup
    $__g_pKernelGetProcAddr = GetProcAddress($hKernelModule, "GetProcAddress")

    If @error Then
        ;Free Memory on fail, to prevent Memory leak
        $__g_pKernelLoadLib = 0
        $__g_pKernelGetProcAddr = 0
        VirtualFree($__g_pWindowsDllLoadBase, 0, $MEM_RELEASE)
        Return SetError($AU_ERR_DLLAPI_STARTUP, $AU_ERREX_GET_GETPROCADDRRESS, 0)
    EndIf

    ;Finally setup API vars and initialize Vector to store all loaded Handles, to free them later
    $__g_vecWindowsDllHandles = _Vector_Init()
    $__g_pWindowsDllLoad    = $__g_pWindowsDllLoadBase + 0x00A1
    $__g_pWindowsDllGetAddr = $__g_pWindowsDllLoadBase + 0x0590
    $__g_pWindowsDllFree    = $__g_pWindowsDllLoadBase + 0x059F

    ;Setting initialized to True and a Shutdown callback for the AutoIt Exit to free everything properly
    $__g_bWindowsDllSetup = 1
    OnAutoItExitRegister("__Dll_Shutdown")

    Return 1
EndFunc



#cs Internal Only
    Frees the previous loaded dlls, deallocates assembly and internal variables.
    Gets auto called when AutoIt exits if initialized.

    @return (Bool)  1 on success, 0 on failure

    @error          $AU_ERR_DLLAPI_UNIT, $AU_ERR_DLLAPI_SHUTDOWN
    @extended       Detailed error infos

    @author         [Zvend](Zvend#6666)
    @version        3.3.16.1
    @since          3.3.16.1
    @see            _AU_ConvertErorr
    @see            __Dll_StartUp
    @see            __Dll_Close
#ce
Func __Dll_Shutdown()
    If Not _Dll_IsInitialized() Then
        Return SetError($AU_ERR_DLLAPI_UNIT, $AUFUNC_DLLAPI_CLOSEALL, 0)
    EndIf

    ;In case this is getting called manually, so it wont run on shutdown if it does not have to
    OnAutoItExitUnregister("__Dll_Shutdown")

    ;No need to error check this one, since the check has already been done in this function
    _Dll_CloseAll()

    ;Free DllLoaderPayload
    VirtualFree($__g_pWindowsDllLoadBase, 0, $MEM_RELEASE)
    If @error Then
        Return SetError($AU_ERR_DLLAPI_SHUTDOWN, $AU_ERREX_FREE_MEMORY, 0)
    EndIf

    $__g_bWindowsDllSetup     = 0
    $__g_vecWindowsDllHandles = 0
    $__g_pWindowsDllLoadBase  = 0
    $__g_pWindowsDllLoad      = 0
    $__g_pWindowsDllGetAddr   = 0
    $__g_pWindowsDllFree      = 0
    $__g_pKernelLoadLib       = 0
    $__g_pKernelGetProcAddr   = 0

    Return 1
EndFunc



#cs Internal Only
    Loads a dll module from an address in memory.

    @param (Pointer) Const $pBinaryAddress  Memory address of the binary data

    @return (Handle)    DllModule Handle, 0 if failed

    @error              $AU_ERR_DLLCALL_FAILED
    @extended           Detailed error infos

    @author             [Zvend](Zvend#6666)
    @version            3.3.16.1
    @since              3.3.16.1
    @see                _AU_ConvertErorr
    @see                __Dll_FreeLibrary
    @see                __Dll_GetModuleExist
#ce
Func __Dll_LoadLibraryA(Const $pBinaryAddress)
    ;Calls a function from the custom assembly to load the library from a pointer
    Local $aCall = DllCallAddress("HANDLE", $__g_pWindowsDllLoad, "PTR", $__g_pKernelLoadLib, "PTR", $__g_pKernelGetProcAddr, "PTR", $pBinaryAddress)

	If @error Then
        Return SetError($AU_ERR_DLLCALL_FAILED, @error, 0)
	EndIf

    ;Returns the handle of the loaded dll
	Return $aCall[0]
EndFunc



#cs Internal Only
    Frees a previously loaded dll module.

    @param (Handle) Const ByRef $hDllHandle     DllModule Handle to be freed

    @return (Bool)  1 on success, 0 on failure

    @error          $AU_ERR_DLLCALL_FAILED
    @extended       Detailed error infos

    @author         [Zvend](Zvend#6666)
    @version        3.3.16.1
    @since          3.3.16.1
    @see            _AU_ConvertErorr
    @see            __Dll_FreeLibrary
    @see            __Dll_GetModuleExist
#ce
Func __Dll_FreeLibrary(Const ByRef $hDllHandle)
    ;Calls a function from the custom assembly to free a library
    DllCallAddress("PTR", $__g_pWindowsDllFree, "HANDLE", $hDllHandle)

	If @error Then
        Return SetError($AU_ERR_DLLCALL_FAILED, @error, 0)
	EndIf

	Return 1
EndFunc



#cs Internal Only
    Checks if a module exist in the API vector.

    @param Const ByRef $hDllHandle  Handle to check if it exists
    @return                         1 on success, 0 on failure

    @author     [Zvend](Zvend#6666)
    @version    3.3.16.1
    @since      3.3.16.1
    @see        _Dll_Close
#ce
Func __Dll_GetModuleExist(Const ByRef $hDllHandle)
    For $i = 0 To _Vector_GetSize($__g_vecWindowsDllHandles) - 1
        If _Vector_Get($__g_vecWindowsDllHandles, $i) = $hDllHandle Then
            Return 1
        EndIf
    Next

    Return 0
EndFunc



#cs Internal Only
    Returns the assembly payload to load dlls from memory.

    @return     BinaryString of the assembly or empty string

    @error      Code 1 on fail

    @author     [Zvend](Zvend#6666)
    @version    3.3.16.1
    @since      3.3.16.1
    @see        __Dll_StartUp
#ce
Func __Dll_GetDllLoaderPayload()
    Static Local $dBinary = ""

    If $dBinary == "" Then
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

        $dBinary = Binary($dBinary)
    EndIf

    Return SetError(Int($dBinary == "", 1), 0, $dBinary)
EndFunc


