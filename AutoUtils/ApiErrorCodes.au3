#cs
#   Global error codes for AutoUtils with an error interpreter.
#   <<Know where your errors come from>>
#
#   @author     [Zvend](Zvend#6666)
#   @link       [Zvendson](https://github.com/Zvendson)
#
#   Saturday 14 May 2023
#
#   @Todos:
#       [ ] Sort Enums alphabetically including function switches
#
#   @Enhancement
#       Giving every module a range error?
#       Like $AU_ERR_DLL_STARTUP = 500, $AU_ERR_DLLCALL = 600, etc
#
#ce



#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7


#cs
#   @include DllHandles.au3     Global wide useful DllHandles-References
#ce
#include ".\DllHandles.au3"



#cs
#   @enum   Defines AU global Error Codes, alphabetically sorted by module.
#ce
Global Enum _
    $AU_ERR_SUCCESS              , _
    $AU_ERR_DLLCALL_FAILED       , _ ;Sets @extended to AutoIt3 DllCall error.
    $AU_ERR_DLLAPI_UNIT          , _
    $AU_ERR_DLLAPI_STARTUP       , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_DLLAPI_SHUTDOWN      , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_DLLAPI_OPEN          , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_DLLAPI_GETPROC       , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_DLLAPI_CLOSE         , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_VECTOR_INVALID       , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_VECTOR_BAD_MODIFIER  , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_VECTOR_INVALID_PARAMS, _ ;Sets @extended to $AU_ERREX
    $AU_ERR_VECTOR_INVALID_FUNC  , _ ;Sets @extended to param index 1-based
    $AU_ERR_VECTOR_INVALID_INDEX , _ ;Sets @extended to param index 1-based
    $AU_ERR_VECTOR_EMTPY         , _
    $AU_ERR_VECTOR_BAD_COMPARE   , _ ;Sets @extended to $AU_ERREX
    $AU_ERR_COUNT



Global Enum _
    $AU_ERREX_NONE                , _
    $AU_ERREX_ALLOC_MEMORY        , _
    $AU_ERREX_FREE_MEMORY         , _
    $AU_ERREX_INVALID_MODULE, _
    $AU_ERREX_GET_LOADLIBRARY     , _
    $AU_ERREX_GET_GETPROCADDRRESS , _
    $AU_ERREX_LOAD_LIBRARY        , _
    $AU_ERREX_INVALID_BINARY      , _
    $AU_ERREX_BINARY_NOT_MZ       , _
    $AU_ERREX_BINARY_NOT_32BIT    , _
    $AU_ERREX_BINARY_NOT_DLL      , _
    $AU_ERREX_INVALID_HANDLE      , _
    $AU_ERREX_BAD_VECTOR          , _
    $AU_ERREX_NOT_ARRAY           , _
    $AU_ERREX_INVALID_ARRAY_SIZE  , _
    $AU_ERREX_FLOAT_TOO_SMALL     , _
    $AU_ERREX_INDEX_RANGE         , _
    $AU_ERREX_COMPARING_DIFF_TYPES, _
    $AU_ERREX_COUNT



Global Enum _
    $AUFUNC_NONE    , _
    $AUFUNC_DLLAPI_OPEN    , _
    $AUFUNC_DLLAPI_GETPROC , _
    $AUFUNC_DLLAPI_CLOSE   , _
    $AUFUNC_DLLAPI_CLOSEALL, _
    $AUFUNC_COUNT



#cs
#   Loads a 32Bit Dll from an embedded autoit Binary String.
#
#   @param Const $nErrorCode    Error code returned by @error from previous AutoUtils function call
#   @param Const $nExtendedErr  Extra Error code returned by @extended from previous AutoUtils function call
#   @return                     String
#
#   @author     [Zvend](Zvend#6666)
#   @version    3.3.16.1
#   @since      3.3.16.1
#
#ce
Func _AU_ConvertErorr(Const $nErrorCode, Const $nExtendedErr = @extended)
    Switch ($nErrorCode)
        Case $AU_ERR_SUCCESS
            Return "Success"

        Case $AU_ERR_DLLCALL_FAILED
            Return __AU_ConvertDllCallError($nExtendedErr)

        Case $AU_ERR_DLLAPI_STARTUP , _
             $AU_ERR_DLLAPI_SHUTDOWN, _
             $AU_ERR_DLLAPI_OPEN    , _
             $AU_ERR_DLLAPI_GETPROC , _
             $AU_ERR_DLLAPI_CLOSE
            Return __Au_ConvertErrorEx($nExtendedErr)

        Case $AU_ERR_VECTOR_INVALID       , _
             $AU_ERR_VECTOR_BAD_MODIFIER  , _
             $AU_ERR_VECTOR_INVALID_PARAMS, _
             $AU_ERR_VECTOR_INVALID_FUNC  , _
             $AU_ERR_VECTOR_EMTPY         , _
             $AU_ERR_VECTOR_BAD_COMPARE
            Return

        Case $AU_ERR_VECTOR_INVALID_INDEX
            Return StringFormat("Param %d is out of bounds", $nExtendedErr)

        Case $AU_ERR_VECTOR_INVALID_FUNC
            Return StringFormat("Param %d is not a function type", $nExtendedErr)

        Case $AU_ERR_DLLAPI_UNIT
            Return __AU_ConvertDllFunc($nExtendedErr)

    EndSwitch

    Return __Au_UnknownError($nErrorCode, "ConvertErorr")
EndFunc



#cs Internal Only
#   Generates an unknown error message customizable with a Tag
#
#   @param Const $nErrorCode    Error code returned by @error from previous AutoUtils function call
#   @param $sTag                String. Defaults to "". When specified adds brackets around the tag.
#   @return                     String
#
#   @author     [Zvend](Zvend#6666)
#   @version    3.3.16.1
#   @since      3.3.16.1
#
#ce
Func __Au_UnknownError(Const $nErrorCode, $sTag = "")
    If Not($sTag == "") Then
        $sTag = StringFormat("[%s] ", $sTag)
    EndIf

    Return StringFormat("%sUnknown error: %d - please report to the devs", $sTag, $nErrorCode)
EndFunc



#cs Internal Only
#   Generates a string from error codes of DllCall.
#
#   @param Const $nErrorCode    Error code returned by AutoIts DllCall function
#   @return                     String
#
#   @author     [Zvend](Zvend#6666)
#   @version    3.3.16.1
#   @since      3.3.16.1
#
#ce
Func __Au_ConvertDllCallError(Const $nErrorCode)
    Switch ($nErrorCode)
        Case 0
            Return "Success"

        Case 1
            Return "Unable to use the DLL file"

        Case 2
            Return "Unknown 'return type'"

        Case 3
            Return "'Function' not found in the DLL file"

        Case 4
            Return "Bad number of parameters"

        Case 5
            Return "Bad Parameter"

    EndSwitch

    Return __Au_UnknownError($nErrorCode, "DllCall")
EndFunc



#cs Internal Only
#   Generates the @extended error info
#
#   @param Const $nErrorCode    @extended Error code
#   @return                     String
#
#   @author     [Zvend](Zvend#6666)
#   @version    3.3.16.1
#   @since      3.3.16.1
#
#ce
Func __Au_ConvertErrorEx(Const $nErrorCode)
    Switch ($nErrorCode)
        Case $AU_ERREX_NONE
            Return "Success"

        Case $AU_ERREX_ALLOC_MEMORY
            Return "Could not allocated memory for the payload"

        Case $AU_ERREX_FREE_MEMORY
            Return "Could not allocated memory for the payload"

        Case $AU_ERREX_INVALID_MODULE
            Return "Failed to get a module handle"

        Case $AU_ERREX_GET_LOADLIBRARY
            Return "Failed to get the function pointer of 'LoadLibraryA'"

        Case $AU_ERREX_GET_GETPROCADDRRESS
            Return "Failed to get the function pointer of 'GetProcAddress'"

        Case $AU_ERREX_LOAD_LIBRARY
            Return "Failed to load the library"

        Case $AU_ERREX_INVALID_BINARY
            Return "Given Binary is invalid"

        Case $AU_ERREX_BINARY_NOT_MZ
            Return "Given Binary is not in DOS MZ executable format"

        Case $AU_ERREX_BINARY_NOT_32BIT
            Return "Given Binary is not in 32 bit"

        Case $AU_ERREX_BINARY_NOT_DLL
            Return "Given Binary is not a Dynamic Link Library (.dll)"

        Case $AU_ERREX_INVALID_HANDLE
            Return "Given Module has not been loaded by _Dll_Open"

        Case $AU_ERREX_NOT_ARRAY
            Return "Given param is not an array"

        Case $AU_ERREX_INVALID_ARRAY_SIZE
            Return "Array has an invalid size"

        Case $AU_ERREX_FLOAT_TOO_SMALL
            Return "Given float is too small"

    EndSwitch

    Return __Au_UnknownError($nErrorCode, "Dll")
EndFunc



#cs Internal Only
#   Returns the function name by enum id
#
#   @param Const $nFuncCode     Enum Id
#   @return                     String
#
#   @author     [Zvend](Zvend#6666)
#   @version    3.3.16.1
#   @since      3.3.16.1
#
#ce
Func __AU_ConvertDllFunc(Const $nFuncCode)
    Switch ($nFuncCode)
        Case $AUFUNC_NONE
            Return "None"

        Case $AUFUNC_DLLAPI_OPEN
            Return "_Dll_Open"

        Case $AUFUNC_DLLAPI_GETPROC
            Return "_Dll_GetProcAddress"

        Case $AUFUNC_DLLAPI_CLOSE
            Return "_Dll_Close"

        Case $AUFUNC_DLLAPI_CLOSEALL
            Return "_Dll_CloseAll"

    EndSwitch

    Return "Unknown Function"
EndFunc


