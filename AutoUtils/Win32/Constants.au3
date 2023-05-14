#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.16.1
 Author(s):       Zvend
 Discord(s):      Zvend#6666

 Script Functions:

#ce ----------------------------------------------------------------------------

#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7



; VirtualAlloc Allocation Types

Global Const $MEM_COMMIT      = 0x00001000
Global Const $MEM_RESERVE     = 0x00002000
Global Const $MEM_RESET       = 0x00080000
Global Const $MEM_TOP_DOWN    = 0x00100000
Global Const $MEM_WRITE_WATCH = 0x00200000
Global Const $MEM_PHYSICAL    = 0x00400000
Global Const $MEM_RESET_UNDO  = 0x01000000
Global Const $MEM_LARGE_PAGES = 0x20000000



; VirtualAlloc Protection

Global Const $PAGE_NOACCESS          = 0x00000001
Global Const $PAGE_READONLY          = 0x00000002
Global Const $PAGE_READWRITE         = 0x00000004
Global Const $PAGE_WRITECOPY         = 0x00000008
Global Const $PAGE_EXECUTE           = 0x00000010
Global Const $PAGE_EXECUTE_READ      = 0x00000020
Global Const $PAGE_EXECUTE_READWRITE = 0x00000040
Global Const $PAGE_EXECUTE_WRITECOPY = 0x00000080
Global Const $PAGE_GUARD             = 0x00000100
Global Const $PAGE_NOCACHE           = 0x00000200
Global Const $PAGE_WRITECOMBINE      = 0x00000400
Global Const $PAGE_TARGETS_INVALID   = 0x40000000
Global Const $PAGE_TARGETS_NO_UPDATE = 0x40000000



; VirtualFree Free Type

Global Const $MEM_DECOMMIT = 0x00004000
Global Const $MEM_RELEASE = 0x00008000



