#include ".\..\Dll.au3"



Example()



Func Example()

    ;Initializing the _Dll_ internals. This step can be skipped, it will auto init on the first _Dll_Open call.
    _Dll_StartUp()

    ;All the API core functions are now accessible
    Local $bIsInit = _Dll_IsInitialized()
    ConsoleWrite("Dll API initialized = " & $bIsInit & @CRLF)

    ;Deinitializing the Dll API
    _Dll_Shutdown()

    $bIsInit = _Dll_IsInitialized()
    ConsoleWrite("Dll API initialized = " & $bIsInit & @CRLF)
EndFunc



#cs Test.cpp

#include <Windows.h>
#include <vector>

#define EXPORT extern "C" __declspec(dllexport)

EXPORT std::vector<int>* __cdecl MakeVector();
EXPORT void              __cdecl KillVector(std::vector<int>* vector);
EXPORT void              __cdecl PushInt(std::vector<int>* vector, int val);
EXPORT int               __cdecl GetInt(std::vector<int>* vector, int index);

std::vector<int>* __cdecl MakeVector()
{
    return new std::vector<int>();
}

void __cdecl KillVector(std::vector<int>* vector)
{
    delete vector;
}

void __cdecl PushInt(std::vector<int>* vector, int val)
{
    vector->push_back(val);
}

int __cdecl GetInt(std::vector<int>* vector, int index)
{
    return vector->at(index);
}

#ce Test.cpp