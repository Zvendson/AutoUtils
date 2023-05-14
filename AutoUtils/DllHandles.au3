#cs
#   Global wide useful DllHandles-References
#
#   @author     [Zvend](Zvend#6666)
#   @link       [Zvendson](https://github.com/Zvendson)
#
#   Saturday 14 May 2023
#
#ce



#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



#cs
#   @protected  Kernerl32.dll referenz for calling WinAPI functions
#ce
Global $__g_hKernelDll = DllOpen("kernel32.dll")

#cs
#   @protected  AdvAPI.dll referenz for calling security based functions
#ce
Global $__g_hAdvapiDll = DllOpen("advapi32.dll")


